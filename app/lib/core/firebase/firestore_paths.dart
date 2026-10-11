/// Every Firestore path in the app (TECH_STACK.md §4 and §7.3). No string
/// paths anywhere else.
abstract final class FirestorePaths {
  /// F5 market prices; written only by the admin SDK.
  static const pricingConfig = 'config/pricing_pk';

  /// MVP: one system per user.
  static const mainSystemId = 'main';

  static String user(String uid) => 'users/$uid';

  static String system(String uid, [String systemId = mainSystemId]) =>
      '${user(uid)}/systems/$systemId';

  static String appliances(String uid, [String systemId = mainSystemId]) =>
      '${system(uid, systemId)}/appliances';

  /// "Light gayi / aa gayi" events (F8).
  static String outages(String uid, [String systemId = mainSystemId]) =>
      '${system(uid, systemId)}/outages';

  /// The user's area load-shedding schedule, one doc per weekly slot (F8).
  static String schedule(String uid, [String systemId = mainSystemId]) =>
      '${system(uid, systemId)}/schedule';

  /// One trimmed Open-Meteo forecast per day, keyed `yyyy-MM-dd`.
  static String weatherCache(String uid, [String systemId = mainSystemId]) =>
      '${system(uid, systemId)}/weatherCache';
}
