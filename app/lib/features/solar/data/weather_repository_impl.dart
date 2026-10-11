import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:energy_engine/energy_engine.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../core/firebase/firestore_paths.dart';
import '../../../core/utils/fire_and_forget.dart';
import '../domain/entities/weather_forecast.dart';
import '../domain/weather_repository.dart';
import 'models/weather_dto.dart';
import 'sources/open_meteo_source.dart';

/// Fetches from Open-Meteo and keeps the latest copy in Firestore, whose
/// offline cache shows the forecast in airplane mode (TECH_STACK.md §7.2
/// rule 5).
class FirestoreWeatherRepository implements WeatherRepository {
  FirestoreWeatherRepository(this._db, this._auth, this._source);

  final FirebaseFirestore _db;
  final FirebaseAuth _auth;
  final OpenMeteoSource _source;

  CollectionReference<Map<String, dynamic>> _cache(String uid) =>
      _db.collection(FirestorePaths.weatherCache(uid));

  String get _uid =>
      _auth.currentUser?.uid ?? (throw StateError('Not signed in'));

  @override
  Stream<WeatherForecast?> watchLatest() =>
      _auth.authStateChanges().asyncExpand(
        (user) => user == null
            ? Stream.value(null)
            : _cache(user.uid)
                  .orderBy('fetchedAt', descending: true)
                  .limit(1)
                  .snapshots()
                  .map(
                    (snap) => snap.docs.isEmpty
                        ? null
                        : WeatherDto.fromMap(snap.docs.first.data()),
                  ),
      );

  @override
  Future<void> refresh(SiteLocation site) async {
    final forecast = WeatherDto.fromOpenMeteo(
      await _source.fetchForecast(site),
      site: site,
      fetchedAt: DateTime.now().toUtc(),
    );
    // The local cache (and so the screen) updates at once; the server copy
    // syncs in the background.
    fireAndForget(
      _cache(_uid).doc(WeatherDto.docId(forecast)).set({
        ...WeatherDto.toMap(forecast),
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      }),
      'weather cache',
    );
  }
}
