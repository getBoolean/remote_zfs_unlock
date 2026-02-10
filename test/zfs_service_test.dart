import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:remote_zfs_unlock/models/auth_mode.dart';
import 'package:remote_zfs_unlock/models/server_profile.dart';
import 'package:remote_zfs_unlock/models/server_secrets.dart';
import 'package:remote_zfs_unlock/models/unlock_request.dart';
import 'package:remote_zfs_unlock/services/ssh_service.dart';
import 'package:remote_zfs_unlock/services/zfs_service.dart';

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
tank/home\taes-256-gcm\tavailable\tyes
tank/media\toff\t-\tyes
''';
    final datasets = zfsService.parseDatasets(output);

    expect(datasets, hasLength(2));
    expect(datasets.first.name, 'tank/home');
    expect(datasets.first.isEncrypted, isTrue);
    expect(datasets.first.isKeyLoaded, isTrue);
    expect(datasets.last.name, 'tank/media');
    expect(datasets.last.isEncrypted, isFalse);
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
    expect(sshService.commandWithInputCalls.single.stdinData, 'my-secret\n'.codeUnits);
  });

  test('unlockDataset with keyfile uploads and removes remote temp file', () async {
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
    expect(sshService.commandCalls.single, startsWith("rm -f '/tmp/remote_zfs_unlock_"));
  });

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
  final List<_CommandWithInputCall> commandWithInputCalls = <_CommandWithInputCall>[];
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
      _CommandWithInputCall(command: command, stdinData: List<int>.from(stdinData)),
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
  const _CommandWithInputCall({
    required this.command,
    required this.stdinData,
  });

  final String command;
  final List<int> stdinData;
}

class _UploadCall {
  const _UploadCall({
    required this.bytes,
    required this.remotePath,
  });

  final Uint8List bytes;
  final String remotePath;
}
