import 'dart:async';

import 'package:remote_zfs_unlock/models/server_profile.dart';
import 'package:remote_zfs_unlock/models/server_secrets.dart';
import 'package:remote_zfs_unlock/models/unlock_request.dart';
import 'package:remote_zfs_unlock/models/zfs_dataset.dart';
import 'package:remote_zfs_unlock/services/zfs_service.dart';

class DatasetActionResult {
  const DatasetActionResult({
    required this.datasets,
    required this.statusMessage,
  });

  final List<ZfsDataset> datasets;
  final String statusMessage;
}

class DatasetLockUnlockHelper {
  const DatasetLockUnlockHelper(this._zfsService);

  final ZfsService _zfsService;

  UnlockMethod? resolveUnlockMethod(ZfsDataset dataset) {
    switch (dataset.keyFormat) {
      case ZfsKeyFormatType.passphrase:
        return UnlockMethod.passphrase;
      case ZfsKeyFormatType.raw:
      case ZfsKeyFormatType.hex:
        return UnlockMethod.keyFile;
      case ZfsKeyFormatType.none:
      case ZfsKeyFormatType.unknown:
        return null;
    }
  }

  String? initialServerKeyFilePath(ZfsDataset dataset) {
    final rawKeyLocation = dataset.keyLocation.trim();
    if (rawKeyLocation.startsWith('file://') &&
        rawKeyLocation.length > 'file://'.length) {
      return rawKeyLocation.substring('file://'.length);
    }
    if (rawKeyLocation.startsWith('/')) {
      return rawKeyLocation;
    }
    return null;
  }

  Future<ZfsDataset?> refreshAndValidateDatasetState({
    required ServerProfile profile,
    required Future<ServerSecrets> Function() readSecrets,
    required ZfsDataset dataset,
    required bool expectedMounted,
    required bool expectedKeyLoaded,
  }) async {
    final datasets = await _listDatasets(profile: profile, readSecrets: readSecrets);
    for (final item in datasets) {
      if (item.name != dataset.name) {
        continue;
      }
      final isMounted = item.mounted.toLowerCase().trim() == 'yes';
      if (isMounted != expectedMounted || item.isKeyLoaded != expectedKeyLoaded) {
        return null;
      }
      return item;
    }
    return null;
  }

  Future<DatasetActionResult> lockDataset({
    required ServerProfile profile,
    required Future<ServerSecrets> Function() readSecrets,
    required ZfsDataset dataset,
  }) async {
    final secrets = await readSecrets();
    final isMounted = dataset.mounted.toLowerCase().trim() == 'yes';
    if (isMounted) {
      await _zfsService.unmountDataset(
        profile: profile,
        secrets: secrets,
        datasetName: dataset.name,
      );
    }
    await _zfsService.lockDataset(
      profile: profile,
      secrets: secrets,
      datasetName: dataset.name,
    );
    final datasets = await _zfsService.listDatasets(profile: profile, secrets: secrets);
    return DatasetActionResult(
      datasets: datasets,
      statusMessage: isMounted
          ? 'Unmounted and locked `${dataset.name}`.'
          : 'Locked `${dataset.name}`.',
    );
  }

  Future<DatasetActionResult> unlockDataset({
    required ServerProfile profile,
    required Future<ServerSecrets> Function() readSecrets,
    required ZfsDataset dataset,
    required UnlockRequest request,
  }) async {
    final secrets = await readSecrets();
    await _zfsService.unlockDataset(
      profile: profile,
      secrets: secrets,
      datasetName: dataset.name,
      request: request,
    );
    if (dataset.type == ZfsDatasetType.filesystem) {
      await _zfsService.mountDataset(
        profile: profile,
        secrets: secrets,
        datasetName: dataset.name,
      );
    }
    var datasets = await _zfsService.listDatasets(profile: profile, secrets: secrets);
    final hasNestedFilesystem = datasets.any(
      (candidate) =>
          candidate.type == ZfsDatasetType.filesystem &&
          candidate.name.startsWith('${dataset.name}/'),
    );
    if (hasNestedFilesystem) {
      // Child datasets can mount shortly after the parent unlock/mount completes.
      await Future<void>.delayed(const Duration(milliseconds: 1500));
      datasets = await _zfsService.listDatasets(profile: profile, secrets: secrets);
    }
    return DatasetActionResult(
      datasets: datasets,
      statusMessage: dataset.type == ZfsDatasetType.filesystem
          ? 'Unlocked and mounted `${dataset.name}`.'
          : 'Unlocked `${dataset.name}`.',
    );
  }

  Future<List<ZfsDataset>> _listDatasets({
    required ServerProfile profile,
    required Future<ServerSecrets> Function() readSecrets,
  }) async {
    final secrets = await readSecrets();
    return _zfsService.listDatasets(profile: profile, secrets: secrets);
  }
}
