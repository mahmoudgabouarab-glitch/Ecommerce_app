import '../../features/auth/data/models/auth_model.dart';
import '../network/cache_helper.dart';
import '../network/cache_keys.dart';

class UserCache {
  static Future<void> save(UserModel user, {String? token}) async {
    if (token != null) {
      await CacheHelper.saveData(key: CacheKeys.token, value: token);
      // A real session ends guest mode.
      await CacheHelper.saveData(key: CacheKeys.isGuest, value: false);
    }
    await CacheHelper.saveData(key: CacheKeys.userName, value: user.name);
    await CacheHelper.saveData(key: CacheKeys.userEmail, value: user.email);
    await CacheHelper.saveData(key: CacheKeys.userRole, value: user.role);
    await CacheHelper.saveData(
      key: CacheKeys.userPhone,
      value: user.phone ?? '',
    );
    await CacheHelper.saveData(
      key: CacheKeys.userShowPhone,
      value: user.showPhone,
    );
    await CacheHelper.saveData(
      key: CacheKeys.userAvatar,
      value: user.avatar ?? '',
    );
    await CacheHelper.saveData(
      key: CacheKeys.userGender,
      value: user.gender ?? '',
    );
    await CacheHelper.saveData(
      key: CacheKeys.userBirthDate,
      value: user.birthDate ?? '',
    );
    await CacheHelper.saveData(key: CacheKeys.userBio, value: user.bio ?? '');
  }
}
