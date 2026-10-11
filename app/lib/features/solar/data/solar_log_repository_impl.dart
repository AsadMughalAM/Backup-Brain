import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../core/firebase/firestore_paths.dart';
import '../domain/solar_log_repository.dart';

class FirestoreSolarLogRepository implements SolarLogRepository {
  FirestoreSolarLogRepository(this._db, this._auth);

  final FirebaseFirestore _db;
  final FirebaseAuth _auth;

  /// A month of days: the trend and the 7-day check both fit.
  static const _limit = 31;

  CollectionReference<Map<String, dynamic>> _col(String uid) =>
      _db.collection(FirestorePaths.solarLogs(uid));

  @override
  Stream<List<SolarLog>> watchRecent() => _auth.authStateChanges().asyncExpand(
    (user) => user == null
        ? Stream.value(const <SolarLog>[])
        : _col(user.uid)
              .orderBy('date', descending: true)
              .limit(_limit)
              .snapshots()
              .map((snap) => [for (final d in snap.docs) _log(d.data())]),
  );

  @override
  Future<void> save(SolarLog log) {
    final uid = _auth.currentUser?.uid ?? (throw StateError('Not signed in'));
    final key = dayKey(log.day);
    return _col(uid).doc(key).set({
      'date': key,
      'actualKWh': log.actualKWh,
      'expectedKWh': log.expectedKWh,
      'clearShare': log.clearShare,
    });
  }

  /// `yyyy-MM-dd`, the doc id (TECH_STACK §4).
  static String dayKey(DateTime day) =>
      '${day.year}-${day.month.toString().padLeft(2, '0')}-'
      '${day.day.toString().padLeft(2, '0')}';

  static SolarLog _log(Map<String, dynamic> d) {
    final parts = (d['date'] as String).split('-').map(int.parse).toList();
    return SolarLog(
      day: DateTime.utc(parts[0], parts[1], parts[2]),
      actualKWh: (d['actualKWh'] as num).toDouble(),
      expectedKWh: (d['expectedKWh'] as num).toDouble(),
      clearShare: (d['clearShare'] as num?)?.toDouble() ?? 1,
    );
  }
}
