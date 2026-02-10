import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:remote_zfs_unlock/models/server_secrets.dart';

class SecureStorageService {
  SecureStorageService(this._storage);

  final FlutterSecureStorage _storage;

  String _key(String profileId, String suffix) => 'profile.$profileId.$suffix';

  Future<void> saveSecrets({
    required String profileId,
    required ServerSecrets secrets,
  }) async {
    await _writeNullable(_key(profileId, 'password'), secrets.password);
    await _writeNullable(_key(profileId, 'privateKeyPem'), secrets.privateKeyPem);
    await _writeNullable(
      _key(profileId, 'privateKeyPassphrase'),
      secrets.privateKeyPassphrase,
    );
  }

  Future<ServerSecrets> readSecrets(String profileId) async {
    return ServerSecrets(
      password: await _storage.read(key: _key(profileId, 'password')),
      privateKeyPem: await _storage.read(key: _key(profileId, 'privateKeyPem')),
      privateKeyPassphrase:
          await _storage.read(key: _key(profileId, 'privateKeyPassphrase')),
    );
  }

  Future<void> deleteSecrets(String profileId) async {
    await _storage.delete(key: _key(profileId, 'password'));
    await _storage.delete(key: _key(profileId, 'privateKeyPem'));
    await _storage.delete(key: _key(profileId, 'privateKeyPassphrase'));
  }

  Future<void> _writeNullable(String key, String? value) async {
    if (value == null || value.trim().isEmpty) {
      await _storage.delete(key: key);
      return;
    }
    await _storage.write(key: key, value: value);
  }
}
