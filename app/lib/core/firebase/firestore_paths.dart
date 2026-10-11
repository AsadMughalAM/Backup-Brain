/// Every Firestore path in the app (TECH_STACK.md §4 and §7.3). No string
/// paths anywhere else.
abstract final class FirestorePaths {
  /// MVP: one system per user.
  static const mainSystemId = 'main';

  static String user(String uid) => 'users/$uid';

  static String system(String uid, [String systemId = mainSystemId]) =>
      '${user(uid)}/systems/$systemId';

  static String appliances(String uid, [String systemId = mainSystemId]) =>
      '${system(uid, systemId)}/appliances';
}
