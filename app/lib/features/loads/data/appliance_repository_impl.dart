import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../core/firebase/firestore_paths.dart';
import '../../../core/services/demo_household_asset.dart';
import '../domain/appliance_repository.dart';
import '../domain/entities/appliance.dart';
import 'models/appliance_dto.dart';

class FirestoreApplianceRepository implements ApplianceRepository {
  FirestoreApplianceRepository(this._db, this._auth, this._loadDemo);

  final FirebaseFirestore _db;
  final FirebaseAuth _auth;
  final DemoHouseholdLoader _loadDemo;

  CollectionReference<Map<String, dynamic>> _col(String uid) =>
      _db.collection(FirestorePaths.appliances(uid));

  String get _uid =>
      _auth.currentUser?.uid ?? (throw StateError('Not signed in'));

  @override
  Stream<List<Appliance>> watchAll() => _auth.authStateChanges().asyncExpand(
    (user) => user == null
        ? Stream.value(const <Appliance>[])
        // A household has tens of appliances, not thousands; the limit is
        // the §7.3 guard for growing collections.
        : _col(user.uid)
              .orderBy('order')
              .limit(200)
              .snapshots()
              .map(
                (snap) => [
                  for (final d in snap.docs)
                    ApplianceDto.fromMap(d.id, d.data()),
                ],
              ),
  );

  @override
  Future<void> setOn(String id, {required bool isOn}) =>
      _col(_uid)
          .doc(id)
          .update({'isOn': isOn, 'updatedAt': FieldValue.serverTimestamp()});

  @override
  Future<void> addAll(
    List<Appliance> appliances, {
    Set<String> removing = const {},
  }) async {
    final col = _col(_uid);
    // A batch, not a transaction: transactions need the server and this
    // must work offline (TECH_STACK.md §7.2).
    final batch = _db.batch();
    // Deletes first: a re-added id (same preset) ends up written, not gone.
    for (final id in removing) {
      batch.delete(col.doc(id));
    }
    for (final appliance in appliances) {
      batch.set(col.doc(appliance.id), {
        ...ApplianceDto.toMap(appliance),
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }
    await batch.commit();
  }

  @override
  Future<void> loadDemo() async {
    final demo = await _loadDemo();
    await addAll([
      for (final (i, raw)
          in (demo['appliances'] as List).cast<Map<String, dynamic>>().indexed)
        ApplianceDto.fromMap(raw['id'] as String, {...raw, 'order': i}),
    ]);
  }
}
