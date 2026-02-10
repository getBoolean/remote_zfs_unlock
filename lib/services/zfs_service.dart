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
      command: 'zfs list -H -o name,encryption,keystatus,mounted',
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
      if (columns.length < 4) {
        continue;
      }
      datasets.add(
        ZfsDataset(
          name: columns[0],
          encryption: columns[1],
          keyStatus: columns[2],
          mounted: columns[3],
        ),
      );
    }
    return datasets;
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
    if (passphrase == null || passphrase.isEmpty) {
      throw ArgumentError('Passphrase is required for encrypted datasets.');
    }
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
