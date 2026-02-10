import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:remote_zfs_unlock/models/auth_mode.dart';
import 'package:remote_zfs_unlock/models/create_dataset_request.dart';
import 'package:remote_zfs_unlock/models/server_profile.dart';
import 'package:remote_zfs_unlock/models/server_secrets.dart';
import 'package:remote_zfs_unlock/models/unlock_request.dart';
import 'package:remote_zfs_unlock/models/zfs_dataset.dart';
import 'package:remote_zfs_unlock/services/ssh_service.dart';
import 'package:remote_zfs_unlock/services/zfs_service.dart';

ZfsEncryptionType parseEncryption(String encryption) {
  switch (encryption) {
    case 'on':
      return ZfsEncryptionType.on;
    case 'off':
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

void main() {
  late _RecordingSshService sshService;
  late ZfsService zfsService;

  const profile = ServerProfile(
    id: 'id-1',
    name: 'pool-host',
    host: 'example.com',
    port: 22,
    username: 'root',
    authMode: SshAuthMode.password,
  );
  const secrets = ServerSecrets(password: 'pw');

  setUp(() {
    sshService = _RecordingSshService();
    zfsService = ZfsService(sshService);
  });

  test('parseDatasets extracts encrypted/key status values', () {
    const output = '''
tank/home\taes-256-gcm\tavailable\tyes\t10G\t100G\tfilesystem\ton\tzstd-3\tpassphrase\tprompt\t/tank/home
tank/media\toff\t-\tyes\t2G\t200G\tvolume\toff\tlz4\tnone\tnone\t/tank/media
''';
    final datasets = zfsService.parseDatasets(output);

    expect(datasets, hasLength(2));
    expect(datasets.first.name, 'tank/home');
    expect(datasets.first.isEncrypted, isTrue);
    expect(datasets.first.encryption, ZfsEncryptionType.aes256Gcm);
    expect(datasets.first.keyStatus, ZfsKeyStatusType.available);
    expect(datasets.first.isKeyLoaded, isTrue);
    expect(datasets.first.usedByDataset, '10G');
    expect(datasets.first.available, '100G');
    expect(datasets.first.type, ZfsDatasetType.filesystem);
    expect(datasets.first.dedup, ZfsDedupType.on);
    expect(datasets.first.compression, ZfsCompressionType.zstd);
    expect(datasets.first.keyFormat, ZfsKeyFormatType.passphrase);
    expect(datasets.first.keyLocation, 'prompt');
    expect(datasets.first.mountPoint, '/tank/home');
    expect(datasets.last.name, 'tank/media');
    expect(datasets.last.isEncrypted, isFalse);
    expect(datasets.last.encryption, ZfsEncryptionType.off);
    expect(datasets.last.keyStatus, ZfsKeyStatusType.none);
    expect(datasets.last.type, ZfsDatasetType.volume);
  });

  test('ZfsDataset encryptionType parses all supported encryption values', () {
    ZfsDataset makeDataset(String encryption) {
      return ZfsDataset(
        name: 'tank/test',
        encryption: parseEncryption(encryption),
        keyStatus: ZfsKeyStatusType.none,
        mounted: 'no',
        usedByDataset: '0',
        available: '0',
        type: ZfsDatasetType.filesystem,
        dedup: ZfsDedupType.off,
        compression: ZfsCompressionType.off,
        keyFormat: ZfsKeyFormatType.none,
        keyLocation: 'none',
        mountPoint: '/tank/test',
      );
    }

    expect(makeDataset('on').encryption, ZfsEncryptionType.on);
    expect(makeDataset('off').encryption, ZfsEncryptionType.off);
    expect(makeDataset('aes-128-ccm').encryption, ZfsEncryptionType.aes128Ccm);
    expect(makeDataset('aes-192-ccm').encryption, ZfsEncryptionType.aes192Ccm);
    expect(makeDataset('aes-256-ccm').encryption, ZfsEncryptionType.aes256Ccm);
    expect(makeDataset('aes-128-gcm').encryption, ZfsEncryptionType.aes128Gcm);
    expect(makeDataset('aes-192-gcm').encryption, ZfsEncryptionType.aes192Gcm);
    expect(makeDataset('aes-256-gcm').encryption, ZfsEncryptionType.aes256Gcm);
  });

  test('unlockDataset with passphrase sends stdin to zfs load-key', () async {
    await zfsService.unlockDataset(
      profile: profile,
      secrets: secrets,
      datasetName: 'tank/home',
      request: const UnlockRequest.passphrase('my-secret'),
    );

    expect(sshService.commandWithInputCalls, hasLength(1));
    expect(
      sshService.commandWithInputCalls.single.command,
      contains("zfs load-key 'tank/home'"),
    );
    expect(
      sshService.commandWithInputCalls.single.stdinData,
      'my-secret\n'.codeUnits,
    );
    expect(sshService.uploadCalls, isEmpty);
    expect(sshService.commandCalls, isEmpty);
  });

  test('createDataset sends zfs create for non-encrypted dataset', () async {
    await zfsService.createDataset(
      profile: profile,
      secrets: secrets,
      request: const CreateDatasetRequest(
        parentDataset: 'tank/home',
        datasetName: 'projects',
        encrypted: false,
      ),
    );

    expect(sshService.commandWithInputCalls, hasLength(1));
    final call = sshService.commandWithInputCalls.single;
    expect(call.command, contains("zfs create 'tank/home/projects'"));
    expect(call.stdinData, isEmpty);
  });

  test(
    'createDataset sends encrypted create command with passphrase stdin',
    () async {
      await zfsService.createDataset(
        profile: profile,
        secrets: secrets,
        request: const CreateDatasetRequest(
          parentDataset: 'tank/home',
          datasetName: 'secrets',
          encrypted: true,
          passphrase: 'pass-123',
        ),
      );

      expect(sshService.commandWithInputCalls, hasLength(1));
      final call = sshService.commandWithInputCalls.single;
      expect(
        call.command,
        contains(
          "zfs create -o encryption=on -o keyformat=passphrase -o keylocation=prompt 'tank/home/secrets'",
        ),
      );
      expect(call.stdinData, 'pass-123\n'.codeUnits);
    },
  );

  test(
    'createDataset with keyfile uploads temp file and uses keylocation file',
    () async {
      await zfsService.createDataset(
        profile: profile,
        secrets: secrets,
        request: CreateDatasetRequest(
          parentDataset: 'tank/home',
          datasetName: 'secrets-keyfile',
          encrypted: true,
          keyFileBytes: Uint8List.fromList(List<int>.filled(32, 1)),
        ),
      );

      expect(sshService.uploadCalls, hasLength(1));
      expect(sshService.commandWithInputCalls, hasLength(1));
      final call = sshService.commandWithInputCalls.single;
      expect(
        call.command,
        contains(
          "zfs create -o encryption=on -o keyformat=raw -o keylocation='file:///tmp/remote_zfs_unlock_",
        ),
      );
      expect(call.command, contains("'tank/home/secrets-keyfile'"));
      expect(call.stdinData, isEmpty);
      expect(sshService.commandCalls, hasLength(1));
      expect(
        sshService.commandCalls.single,
        startsWith("rm -f '/tmp/remote_zfs_unlock_"),
      );
    },
  );

  test(
    'createDataset with keyfile allows selecting aes-128-gcm encryption',
    () async {
      await zfsService.createDataset(
        profile: profile,
        secrets: secrets,
        request: CreateDatasetRequest(
          parentDataset: 'tank/home',
          datasetName: 'secrets-keyfile-128',
          encrypted: true,
          keyFileBytes: Uint8List.fromList(List<int>.filled(32, 7)),
          keyFileEncryptionType: CreateDatasetEncryptionType.aes128Gcm,
        ),
      );

      expect(sshService.commandWithInputCalls, hasLength(1));
      expect(
        sshService.commandWithInputCalls.single.command,
        contains('zfs create -o encryption=aes-128-gcm -o keyformat=raw'),
      );
    },
  );

  test(
    'createDataset with keyfile allows selecting aes-192-gcm encryption',
    () async {
      await zfsService.createDataset(
        profile: profile,
        secrets: secrets,
        request: CreateDatasetRequest(
          parentDataset: 'tank/home',
          datasetName: 'secrets-keyfile-192',
          encrypted: true,
          keyFileBytes: Uint8List.fromList(List<int>.filled(32, 9)),
          keyFileEncryptionType: CreateDatasetEncryptionType.aes192Gcm,
        ),
      );

      expect(sshService.commandWithInputCalls, hasLength(1));
      expect(
        sshService.commandWithInputCalls.single.command,
        contains('zfs create -o encryption=aes-192-gcm -o keyformat=raw'),
      );
    },
  );

  test('createDataset rejects non-32-byte keyfile length', () async {
    await expectLater(
      () => zfsService.createDataset(
        profile: profile,
        secrets: secrets,
        request: CreateDatasetRequest(
          parentDataset: 'tank/home',
          datasetName: 'secrets-keyfile-invalid',
          encrypted: true,
          keyFileBytes: Uint8List.fromList(List<int>.filled(20, 1)),
        ),
      ),
      throwsArgumentError,
    );
    expect(sshService.commandWithInputCalls, isEmpty);
    expect(sshService.uploadCalls, isEmpty);
    expect(sshService.commandCalls, isEmpty);
  });

  test('createDataset rejects empty dataset name', () async {
    await expectLater(
      () => zfsService.createDataset(
        profile: profile,
        secrets: secrets,
        request: const CreateDatasetRequest(
          parentDataset: 'tank/home',
          datasetName: '   ',
          encrypted: false,
        ),
      ),
      throwsArgumentError,
    );
    expect(sshService.commandWithInputCalls, isEmpty);
  });

  test('createDataset rejects encrypted request without passphrase', () async {
    await expectLater(
      () => zfsService.createDataset(
        profile: profile,
        secrets: secrets,
        request: const CreateDatasetRequest(
          parentDataset: 'tank/home',
          datasetName: 'private',
          encrypted: true,
        ),
      ),
      throwsArgumentError,
    );
    expect(sshService.commandWithInputCalls, isEmpty);
  });

  test(
    'unlockDataset with keyfile uploads and removes remote temp file',
    () async {
      await zfsService.unlockDataset(
        profile: profile,
        secrets: secrets,
        datasetName: 'tank/home',
        request: UnlockRequest.keyFile(Uint8List.fromList([1, 2, 3])),
      );

      expect(sshService.uploadCalls, hasLength(1));
      expect(sshService.commandWithInputCalls, hasLength(1));
      expect(
        sshService.commandWithInputCalls.single.command,
        contains("zfs load-key -L 'file:///tmp/remote_zfs_unlock_"),
      );
      expect(sshService.commandCalls, hasLength(1));
      expect(
        sshService.commandCalls.single,
        startsWith("rm -f '/tmp/remote_zfs_unlock_"),
      );
    },
  );

  test('lockDataset calls zfs unload-key', () async {
    await zfsService.lockDataset(
      profile: profile,
      secrets: secrets,
      datasetName: 'tank/home',
    );

    expect(sshService.commandWithInputCalls, hasLength(1));
    expect(
      sshService.commandWithInputCalls.single.command,
      contains("zfs unload-key 'tank/home'"),
    );
  });
}

class _RecordingSshService extends SshService {
  final List<String> commandCalls = <String>[];
  final List<_CommandWithInputCall> commandWithInputCalls =
      <_CommandWithInputCall>[];
  final List<_UploadCall> uploadCalls = <_UploadCall>[];

  @override
  Future<String> runCommand({
    required ServerProfile profile,
    required ServerSecrets secrets,
    required String command,
  }) async {
    commandCalls.add(command);
    return '';
  }

  @override
  Future<SshExecutionResult> runCommandWithInput({
    required ServerProfile profile,
    required ServerSecrets secrets,
    required String command,
    required List<int> stdinData,
  }) async {
    commandWithInputCalls.add(
      _CommandWithInputCall(
        command: command,
        stdinData: List<int>.from(stdinData),
      ),
    );
    return const SshExecutionResult(exitCode: 0, stdout: '', stderr: '');
  }

  @override
  Future<void> uploadBytes({
    required ServerProfile profile,
    required ServerSecrets secrets,
    required Uint8List bytes,
    required String remotePath,
  }) async {
    uploadCalls.add(_UploadCall(bytes: bytes, remotePath: remotePath));
  }
}

class _CommandWithInputCall {
  const _CommandWithInputCall({required this.command, required this.stdinData});

  final String command;
  final List<int> stdinData;
}

class _UploadCall {
  const _UploadCall({required this.bytes, required this.remotePath});

  final Uint8List bytes;
  final String remotePath;
}
