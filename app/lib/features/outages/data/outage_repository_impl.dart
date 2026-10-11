import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:energy_engine/energy_engine.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../core/firebase/firestore_paths.dart';
import '../domain/outage_repository.dart';

class FirestoreOutageRepository implements OutageRepository {
  FirestoreOutageRepository(this._db, this._auth);

  final FirebaseFirestore _db;
  final FirebaseAuth _auth;

  /// Two weeks of pattern plus some margin; daily cuts stay well under it.
  static const _recentLimit = 200;

  CollectionReference<Map<String, dynamic>> _outages(String uid) =>
      _db.collection(FirestorePaths.outages(uid));

  CollectionReference<Map<String, dynamic>> _schedule(String uid) =>
      _db.collection(FirestorePaths.schedule(uid));

  String get _uid =>
      _auth.currentUser?.uid ?? (throw StateError('Not signed in'));

  @override
  Stream<List<OutageEvent>> watchRecent() =>
      _auth.authStateChanges().asyncExpand(
        (user) => user == null
            ? Stream.value(const <OutageEvent>[])
            : _outages(user.uid)
                  .orderBy('startedAt', descending: true)
                  .limit(_recentLimit)
                  .snapshots()
                  .map(
                    (snap) => [
                      for (final d in snap.docs) _event(d.id, d.data()),
                    ],
                  ),
      );

  // The tap time, not a server timestamp: a pending server timestamp reads
  // as null offline, which would make a finished outage look ongoing.
  @override
  Future<void> start({required double soc, required double loadW}) =>
      _outages(_uid).doc().set({
        'startedAt': Timestamp.now(),
        'source': 'manual',
        'startSoC': soc,
        'avgLoadW': loadW,
      });

  @override
  Future<void> end(String id, {required double soc}) => _outages(_uid)
      .doc(id)
      .update({
        'endedAt': Timestamp.now(),
        'endSoC': soc,
        'endSoCSource': 'estimate',
      });

  @override
  Future<void> recordEndSoc(String id, double soc) =>
      _outages(_uid).doc(id).update({'endSoC': soc, 'endSoCSource': 'user'});

  @override
  Stream<List<ScheduleEntry>> watchSchedule() =>
      _auth.authStateChanges().asyncExpand(
        (user) => user == null
            ? Stream.value(const <ScheduleEntry>[])
            : _schedule(user.uid)
                  .limit(50)
                  .snapshots()
                  .map(
                    (snap) => [
                      for (final d in snap.docs)
                        ScheduleEntry(
                          d.id,
                          ScheduleSlot(
                            weekday: (d['weekday'] as num).toInt(),
                            startMinute: (d['startMinute'] as num).toInt(),
                            endMinute: (d['endMinute'] as num).toInt(),
                          ),
                        ),
                    ]..sort(_byWeekThenTime),
                  ),
      );

  @override
  Future<void> addSlot(ScheduleSlot slot) => _schedule(_uid).doc().set({
    'weekday': slot.weekday,
    'startMinute': slot.startMinute,
    'endMinute': slot.endMinute,
  });

  @override
  Future<void> removeSlot(String id) => _schedule(_uid).doc(id).delete();

  static OutageEvent _event(String id, Map<String, dynamic> d) => OutageEvent(
    id: id,
    startedAt: (d['startedAt'] as Timestamp).toDate(),
    endedAt: (d['endedAt'] as Timestamp?)?.toDate(),
    startSoc: (d['startSoC'] as num?)?.toDouble(),
    endSoc: (d['endSoC'] as num?)?.toDouble(),
    endSocMeasured: d['endSoCSource'] == 'user',
    avgLoadW: (d['avgLoadW'] as num?)?.toDouble(),
  );

  static int _byWeekThenTime(ScheduleEntry a, ScheduleEntry b) {
    final byDay = a.slot.weekday.compareTo(b.slot.weekday);
    return byDay != 0
        ? byDay
        : a.slot.startMinute.compareTo(b.slot.startMinute);
  }
}
