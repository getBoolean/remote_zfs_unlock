import 'dart:math';
import 'dart:typed_data';

import 'package:remote_zfs_unlock/models/server_profile.dart';
import 'package:remote_zfs_unlock/models/server_secrets.dart';
import 'package:remote_zfs_unlock/models/create_dataset_request.dart';
import 'package:remote_zfs_unlock/models/unlock_request.dart';
import 'package:remote_zfs_unlock/models/zfs_dataset.dart';
import 'package:remote_zfs_unlock/services/ssh_service.dart';

class ZfsService {
  ZfsService(this._sshService);

  final SshService _sshService;

  Future<String> testConnection({
    required ServerProfile profile,
    required ServerSecrets secrets,
  }) {
    return _sshService.runCommand(
      profile: profile,
      secrets: secrets,
      command: "echo 'connected'",
    );
  }

  Future<List<ZfsDataset>> listDatasets({
    required ServerProfile profile,
    required ServerSecrets secrets,
  }) async {
    final output = await _sshService.runCommand(
      profile: profile,
      secrets: secrets,
      command:
          'zfs list -H -o name,encryption,keystatus,mounted,usedbydataset,available,type,dedup,compression,keyformat,keylocation,mountpoint',
    );
    return parseDatasets(output);
  }

  List<ZfsDataset> parseDatasets(String output) {
    final datasets = <ZfsDataset>[];
    for (final rawLine in output.split('\n')) {
      final line = rawLine.trim();
      if (line.isEmpty) {
        continue;
      }
      final columns = line.split('\t');
      if (columns.length < 12) {
        continue;
      }
      datasets.add(
        ZfsDataset(
          name: columns[0],
          encryption: _parseEncryptionType(columns[1]),
          keyStatus: _parseKeyStatusType(columns[2]),
          mounted: columns[3],
          usedByDataset: columns[4],
          available: columns[5],
          type: _parseDatasetType(columns[6]),
          dedup: _parseDedupType(columns[7]),
          compression: _parseCompressionType(columns[8]),
          keyFormat: _parseKeyFormatType(columns[9]),
          keyLocation: columns[10],
          mountPoint: columns[11],
        ),
      );
    }
    return datasets;
  }

  ZfsEncryptionType _parseEncryptionType(String rawValue) {
    switch (rawValue.trim().toLowerCase()) {
      case 'on':
        return ZfsEncryptionType.on;
      case 'off':
      case '-':
        return ZfsEncryptionType.off;
      case 'aes-128-ccm':
        return ZfsEncryptionType.aes128Ccm;
      case 'aes-192-ccm':
        return ZfsEncryptionType.aes192Ccm;
      case 'aes-256-ccm':
        return ZfsEncryptionType.aes256Ccm;
      case 'aes-128-gcm':
        return ZfsEncryptionType.aes128Gcm;
      case 'aes-192-gcm':
        return ZfsEncryptionType.aes192Gcm;
      case 'aes-256-gcm':
        return ZfsEncryptionType.aes256Gcm;
      default:
        return ZfsEncryptionType.unknown;
    }
  }

  ZfsDatasetType _parseDatasetType(String rawValue) {
    switch (rawValue.trim().toLowerCase()) {
      case 'filesystem':
        return ZfsDatasetType.filesystem;
      case 'volume':
        return ZfsDatasetType.volume;
      case 'snapshot':
        return ZfsDatasetType.snapshot;
      case 'bookmark':
        return ZfsDatasetType.bookmark;
      default:
        return ZfsDatasetType.unknown;
    }
  }

  ZfsKeyStatusType _parseKeyStatusType(String rawValue) {
    switch (rawValue.trim().toLowerCase()) {
      case '-':
      case 'none':
        return ZfsKeyStatusType.none;
      case 'unavailable':
        return ZfsKeyStatusType.unavailable;
      case 'available':
        return ZfsKeyStatusType.available;
      default:
        return ZfsKeyStatusType.unknown;
    }
  }

  ZfsDedupType _parseDedupType(String rawValue) {
    switch (rawValue.trim().toLowerCase()) {
      case 'on':
        return ZfsDedupType.on;
      case 'off':
        return ZfsDedupType.off;
      case 'verify':
        return ZfsDedupType.verify;
      case 'sha256':
        return ZfsDedupType.sha256;
      case 'sha256,verify':
        return ZfsDedupType.sha256Verify;
      case 'sha512':
        return ZfsDedupType.sha512;
      case 'sha512,verify':
        return ZfsDedupType.sha512Verify;
      case 'skein':
        return ZfsDedupType.skein;
      case 'skein,verify':
        return ZfsDedupType.skeinVerify;
      case 'edonr,verify':
        return ZfsDedupType.edonrVerify;
      case 'blake3':
        return ZfsDedupType.blake3;
      case 'blake3,verify':
        return ZfsDedupType.blake3Verify;
      default:
        return ZfsDedupType.unknown;
    }
  }

  ZfsCompressionType _parseCompressionType(String rawValue) {
    final normalized = rawValue.trim().toLowerCase();
    switch (normalized) {
      case 'on':
        return ZfsCompressionType.on;
      case 'off':
        return ZfsCompressionType.off;
      case 'lzjb':
        return ZfsCompressionType.lzjb;
      case 'gzip':
      case 'gzip-1':
      case 'gzip-2':
      case 'gzip-3':
      case 'gzip-4':
      case 'gzip-5':
      case 'gzip-6':
      case 'gzip-7':
      case 'gzip-8':
      case 'gzip-9':
        return ZfsCompressionType.gzip;
      case 'zle':
        return ZfsCompressionType.zle;
      case 'lz4':
        return ZfsCompressionType.lz4;
      case 'zstd':
      case 'zstd-1':
      case 'zstd-2':
      case 'zstd-3':
      case 'zstd-4':
      case 'zstd-5':
      case 'zstd-6':
      case 'zstd-7':
      case 'zstd-8':
      case 'zstd-9':
      case 'zstd-10':
      case 'zstd-11':
      case 'zstd-12':
      case 'zstd-13':
      case 'zstd-14':
      case 'zstd-15':
      case 'zstd-16':
      case 'zstd-17':
      case 'zstd-18':
      case 'zstd-19':
        return ZfsCompressionType.zstd;
      default:
        if (normalized == 'zstd-fast' || normalized.startsWith('zstd-fast-')) {
          return ZfsCompressionType.zstdFast;
        }
        return ZfsCompressionType.unknown;
    }
  }

  ZfsKeyFormatType _parseKeyFormatType(String rawValue) {
    switch (rawValue.trim().toLowerCase()) {
      case 'none':
        return ZfsKeyFormatType.none;
      case 'raw':
        return ZfsKeyFormatType.raw;
      case 'hex':
        return ZfsKeyFormatType.hex;
      case 'passphrase':
        return ZfsKeyFormatType.passphrase;
      default:
        return ZfsKeyFormatType.unknown;
    }
  }

  Future<void> createDataset({
    required ServerProfile profile,
    required ServerSecrets secrets,
    required CreateDatasetRequest request,
  }) async {
    final parentDataset = request.parentDataset.trim();
    final datasetName = request.datasetName.trim();
    if (parentDataset.isEmpty) {
      throw ArgumentError('Parent dataset is required.');
    }
    if (datasetName.isEmpty) {
      throw ArgumentError('Dataset name is required.');
    }
    if (datasetName.contains('/')) {
      throw ArgumentError(
        'Dataset name must be a single name without slashes.',
      );
    }

    final fullDatasetName = '$parentDataset/$datasetName';
    if (!request.encrypted) {
      final result = await _sshService.runCommandWithInput(
        profile: profile,
        secrets: secrets,
        command: 'zfs create ${_shellQuote(fullDatasetName)}',
        stdinData: const [],
      );
      if (result.exitCode != 0) {
        throw StateError(_joinStdio(result.stdout, result.stderr));
      }
      return;
    }

    final passphrase = request.passphrase?.trim();
    final keyFileBytes = request.keyFileBytes;
    final hasPassphrase = passphrase != null && passphrase.isNotEmpty;
    final hasKeyFile = keyFileBytes != null && keyFileBytes.isNotEmpty;
    if (hasPassphrase && hasKeyFile) {
      throw ArgumentError(
        'Use either a passphrase or keyfile for encrypted datasets, not both.',
      );
    }
    if (hasPassphrase) {
      final result = await _sshService.runCommandWithInput(
        profile: profile,
        secrets: secrets,
        command:
            'zfs create -o encryption=on -o keyformat=passphrase -o keylocation=prompt ${_shellQuote(fullDatasetName)}',
        stdinData: '$passphrase\n'.codeUnits,
      );
      if (result.exitCode != 0) {
        throw StateError(_joinStdio(result.stdout, result.stderr));
      }
      return;
    }
    if (hasKeyFile) {
      if (keyFileBytes.length != 32) {
        throw ArgumentError('Raw keyfile must be exactly 32 bytes (256 bit).');
      }
      final encryption = request.keyFileEncryptionType.zfsValue;
      final result = await _sshService.runCommandWithInput(
        profile: profile,
        secrets: secrets,
        command:
            'zfs create -o encryption=$encryption -o keyformat=raw -o keylocation=prompt ${_shellQuote(fullDatasetName)}',
        stdinData: Uint8List.fromList(keyFileBytes),
      );
      if (result.exitCode != 0) {
        throw StateError(_joinStdio(result.stdout, result.stderr));
      }
      return;
    }
    throw ArgumentError(
      'Passphrase or keyfile is required for encrypted datasets.',
    );
  }

  Future<void> unlockDataset({
    required ServerProfile profile,
    required ServerSecrets secrets,
    required String datasetName,
    required UnlockRequest request,
  }) async {
    switch (request.method) {
      case UnlockMethod.passphrase:
        final passphrase = request.passphrase;
        if (passphrase == null || passphrase.isEmpty) {
          throw ArgumentError('Passphrase is required.');
        }
        final result = await _sshService.runCommandWithInput(
          profile: profile,
          secrets: secrets,
          command: 'zfs load-key ${_shellQuote(datasetName)}',
          stdinData: '$passphrase\n'.codeUnits,
        );
        if (result.exitCode != 0) {
          throw StateError(_joinStdio(result.stdout, result.stderr));
        }
        return;
      case UnlockMethod.keyFile:
        final keyFileBytes = request.keyFileBytes;
        if (keyFileBytes == null || keyFileBytes.isEmpty) {
          throw ArgumentError('Key file is required.');
        }
        final tempPath =
            '/tmp/remote_zfs_unlock_${Random().nextInt(1 << 32)}.key';
        await _sshService.uploadBytes(
          profile: profile,
          secrets: secrets,
          bytes: Uint8List.fromList(keyFileBytes),
          remotePath: tempPath,
        );
        try {
          final locator = 'file://$tempPath';
          final loadResult = await _sshService.runCommandWithInput(
            profile: profile,
            secrets: secrets,
            command:
                'zfs load-key -L ${_shellQuote(locator)} ${_shellQuote(datasetName)}',
            stdinData: const [],
          );
          if (loadResult.exitCode != 0) {
            throw StateError(_joinStdio(loadResult.stdout, loadResult.stderr));
          }
        } finally {
          await _sshService.runCommand(
            profile: profile,
            secrets: secrets,
            command: 'rm -f ${_shellQuote(tempPath)}',
          );
        }
    }
  }

  Future<void> lockDataset({
    required ServerProfile profile,
    required ServerSecrets secrets,
    required String datasetName,
  }) async {
    final result = await _sshService.runCommandWithInput(
      profile: profile,
      secrets: secrets,
      command: 'zfs unload-key ${_shellQuote(datasetName)}',
      stdinData: const [],
    );
    if (result.exitCode != 0) {
      throw StateError(_joinStdio(result.stdout, result.stderr));
    }
  }

  Future<void> mountDataset({
    required ServerProfile profile,
    required ServerSecrets secrets,
    required String datasetName,
  }) async {
    final result = await _sshService.runCommandWithInput(
      profile: profile,
      secrets: secrets,
      command: 'zfs mount ${_shellQuote(datasetName)}',
      stdinData: const [],
    );
    if (result.exitCode != 0) {
      throw StateError(_joinStdio(result.stdout, result.stderr));
    }
  }

  Future<void> unmountDataset({
    required ServerProfile profile,
    required ServerSecrets secrets,
    required String datasetName,
  }) async {
    final result = await _sshService.runCommandWithInput(
      profile: profile,
      secrets: secrets,
      command: 'zfs unmount ${_shellQuote(datasetName)}',
      stdinData: const [],
    );
    if (result.exitCode != 0) {
      throw StateError(_joinStdio(result.stdout, result.stderr));
    }
  }

  Future<void> deleteDataset({
    required ServerProfile profile,
    required ServerSecrets secrets,
    required String datasetName,
  }) async {
    final result = await _sshService.runCommandWithInput(
      profile: profile,
      secrets: secrets,
      command: 'zfs destroy ${_shellQuote(datasetName)}',
      stdinData: const [],
    );
    if (result.exitCode != 0) {
      throw StateError(_joinStdio(result.stdout, result.stderr));
    }
  }

  String _joinStdio(String stdout, String stderr) {
    final out = stdout.trim();
    final err = stderr.trim();
    if (out.isEmpty && err.isEmpty) {
      return 'SSH command failed.';
    }
    if (out.isEmpty) {
      return err;
    }
    if (err.isEmpty) {
      return out;
    }
    return '$out\n$err';
  }

  String _shellQuote(String value) {
    return "'${value.replaceAll("'", "'\"'\"'")}'";
  }
}
