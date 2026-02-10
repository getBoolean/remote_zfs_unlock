import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:remote_zfs_unlock/models/server_secrets.dart';
import 'package:remote_zfs_unlock/services/secure_storage_service.dart';

void main() {
  late _FakeFlutterSecureStorage storage;
  late SecureStorageService service;

  setUp(() {
    storage = _FakeFlutterSecureStorage();
    service = SecureStorageService(storage);
  });

  test('saveSecrets writes non-empty values and deletes empty ones', () async {
    await service.saveSecrets(
      profileId: 'p1',
      secrets: const ServerSecrets(
        password: 'password123',
        privateKeyPem: '',
        privateKeyPassphrase: null,
      ),
    );

    expect(storage.values['profile.p1.password'], 'password123');
    expect(storage.deletedKeys, contains('profile.p1.privateKeyPem'));
    expect(storage.deletedKeys, contains('profile.p1.privateKeyPassphrase'));
  });

  test('readSecrets returns values from storage keys', () async {
    storage.values['profile.p1.password'] = 'pw';
    storage.values['profile.p1.privateKeyPem'] = 'PEM';
    storage.values['profile.p1.privateKeyPassphrase'] = 'phrase';

    final secrets = await service.readSecrets('p1');

    expect(secrets.password, 'pw');
    expect(secrets.privateKeyPem, 'PEM');
    expect(secrets.privateKeyPassphrase, 'phrase');
  });
}

class _FakeFlutterSecureStorage extends FlutterSecureStorage {
  final Map<String, String> values = <String, String>{};
  final List<String> deletedKeys = <String>[];

  @override
  Future<void> write({
    required String key,
    required String? value,
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    if (value == null) {
      values.remove(key);
    } else {
      values[key] = value;
    }
  }

  @override
  Future<String?> read({
    required String key,
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    return values[key];
  }

  @override
  Future<void> delete({
    required String key,
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    deletedKeys.add(key);
    values.remove(key);
  }
}
