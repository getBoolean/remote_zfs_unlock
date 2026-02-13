import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' show Provider;
import 'package:hive_ce/hive.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:remote_zfs_unlock/models/server_profile.dart';
import 'package:remote_zfs_unlock/models/server_secrets.dart';
import 'package:remote_zfs_unlock/repositories/server_repository.dart';
import 'package:remote_zfs_unlock/services/clipboard_service.dart';
import 'package:remote_zfs_unlock/services/dataset_lock_unlock_helper.dart';
import 'package:remote_zfs_unlock/services/secure_storage_service.dart';
import 'package:remote_zfs_unlock/services/ssh_service.dart';
import 'package:remote_zfs_unlock/services/zfs_service.dart';

part 'app_providers.g.dart';

const serverProfilesBoxName = 'server_profiles';
const uiPreferencesBoxName = 'ui_preferences';

@riverpod
Box<Map<dynamic, dynamic>> serverProfilesBox(Ref ref) =>
    Hive.box<Map<dynamic, dynamic>>(serverProfilesBoxName);

@riverpod
FlutterSecureStorage flutterSecureStorage(Ref ref) =>
    const FlutterSecureStorage();

@riverpod
SecureStorageService secureStorageService(Ref ref) {
  return SecureStorageService(ref.watch(flutterSecureStorageProvider));
}

@riverpod
ServerRepository serverRepository(Ref ref) {
  return ServerRepository(ref.watch(serverProfilesBoxProvider));
}

@riverpod
SshService sshService(Ref ref) => SshService();

@riverpod
ZfsService zfsService(Ref ref) => ZfsService(ref.watch(sshServiceProvider));

final datasetLockUnlockHelperProvider = Provider<DatasetLockUnlockHelper>((
  ref,
) {
  return DatasetLockUnlockHelper(ref.watch(zfsServiceProvider));
});

final clipboardServiceProvider = Provider<ClipboardService>((ref) {
  return ClipboardService();
});

@riverpod
class ServerList extends _$ServerList {
  ServerRepository get _repository => ref.read(serverRepositoryProvider);
  SecureStorageService get _secureStorage =>
      ref.read(secureStorageServiceProvider);

  @override
  Future<List<ServerProfile>> build() {
    return _repository.readAll();
  }

  Future<void> load() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_repository.readAll);
  }

  Future<void> saveProfile({
    required ServerProfile profile,
    required ServerSecrets secrets,
  }) async {
    await _repository.upsert(profile);
    await _secureStorage.saveSecrets(profileId: profile.id, secrets: secrets);
    state = await AsyncValue.guard(_repository.readAll);
  }

  Future<void> deleteProfile(String id) async {
    await _repository.delete(id);
    await _secureStorage.deleteSecrets(id);
    state = await AsyncValue.guard(_repository.readAll);
  }

  Future<ServerSecrets> readSecrets(String profileId) {
    return _secureStorage.readSecrets(profileId);
  }
}
