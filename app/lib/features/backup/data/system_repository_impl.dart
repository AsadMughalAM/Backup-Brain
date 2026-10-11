import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../core/firebase/firestore_paths.dart';
import '../../../core/services/demo_household_asset.dart';
import '../domain/entities/household_system.dart';
import '../domain/system_repository.dart';
import 'models/system_dto.dart';

class FirestoreSystemRepository implements SystemRepository {
  FirestoreSystemRepository(this._db, this._auth, this._loadDemo);

  final FirebaseFirestore _db;
  final FirebaseAuth _auth;
  final DemoHouseholdLoader _loadDemo;

  DocumentReference<Map<String, dynamic>> _doc(String uid) =>
      _db.doc(FirestorePaths.system(uid));

  String get _uid =>
      _auth.currentUser?.uid ?? (throw StateError('Not signed in'));

  @override
  Stream<HouseholdSystem?> watch() => _auth.authStateChanges().asyncExpand(
    (user) => user == null
        ? Stream.value(null)
        : _doc(user.uid).snapshots().map((snap) {
            final data = snap.data();
            return data == null ? null : SystemDto.fromMap(data);
          }),
  );

  @override
  Future<void> save(HouseholdSystem system) => _doc(_uid).set({
    ...SystemDto.toMap(system),
    'createdAt': FieldValue.serverTimestamp(),
    'updatedAt': FieldValue.serverTimestamp(),
  });

  @override
  Future<void> setSoc(double soc) =>
      _doc(_uid)
          .update({'soc': soc, 'updatedAt': FieldValue.serverTimestamp()});

  @override
  Future<bool> existsOnServer() async =>
      (await _doc(_uid).get(const GetOptions(source: Source.server))).exists;

  @override
  Future<void> loadDemo() async {
    final demo = await _loadDemo();
    await save(SystemDto.fromMap(demo['system'] as Map<String, dynamic>));
  }
}
