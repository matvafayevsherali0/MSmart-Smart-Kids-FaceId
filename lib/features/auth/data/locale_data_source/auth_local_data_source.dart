import '../../../../core/storage/storage.dart';
import '../../../../core/storage/store_keys.dart';

abstract class AuthLocalDataSource {
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  });

  Future<void> clearSession();
}

class AuthLocalDataSourceImpl extends AuthLocalDataSource {
  final StorageRepository _storage;

  AuthLocalDataSourceImpl(this._storage);

  @override
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await _storage.putString(StoreKeys.accessToken, value: accessToken);
    await _storage.putString(StoreKeys.refreshToken, value: refreshToken);
  }

  @override
  Future<void> clearSession() async {
    await _storage.clearAll();
  }
}
