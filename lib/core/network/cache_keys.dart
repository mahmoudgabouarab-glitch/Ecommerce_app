class CacheKeys {
  static const String token = "userToken";
  static const String isGuest = "isGuest";
  static const String userName = "userName";
  static const String userEmail = "userEmail";
  static const String userRole = "userRole";
  static const String userPhone = "userPhone";
  static const String userShowPhone = "userShowPhone";
  static const String userAvatar = "userAvatar";
  static const String userGender = "userGender";
  static const String userBirthDate = "userBirthDate";
  static const String userBio = "userBio";
  static const String themeMode = "themeMode";
  static const String onboardingSeen = "onboardingSeen";
  static const String recentSearches = "recentSearches";
  // Last successful sign-in email, pre-filled on the login screen after logout.
  // (The password is kept in encrypted SecureStore, not here.)
  static const String lastEmail = "lastEmail";
}
