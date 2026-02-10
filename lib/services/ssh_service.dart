import 'dart:convert';
import 'dart:typed_data';

import 'package:dartssh2/dartssh2.dart';
import 'package:remote_zfs_unlock/models/auth_mode.dart';
import 'package:remote_zfs_unlock/models/server_profile.dart';
import 'package:remote_zfs_unlock/models/server_secrets.dart';

class SshService {
  Future<String> runCommand({
    required ServerProfile profile,
    required ServerSecrets secrets,
    required String command,
  }) async {
    final result = await _withClient(
      profile: profile,
      secrets: secrets,
      callback: (client) async => client.run(command),
    );
    return utf8.decode(result);
  }

  Future<SshExecutionResult> runCommandWithInput({
    required ServerProfile profile,
    required ServerSecrets secrets,
    required String command,
    required List<int> stdinData,
  }) async {
    return _withClient(
      profile: profile,
      secrets: secrets,
      callback: (client) async {
        final session = await client.execute(command);
        session.stdin.add(Uint8List.fromList(stdinData));
        await session.stdin.close();
        await session.done;
        final stdout = await _readStream(session.stdout);
        final stderr = await _readStream(session.stderr);
        return SshExecutionResult(
          exitCode: session.exitCode ?? -1,
          stdout: utf8.decode(stdout),
          stderr: utf8.decode(stderr),
        );
      },
    );
  }

  Future<void> uploadBytes({
    required ServerProfile profile,
    required ServerSecrets secrets,
    required Uint8List bytes,
    required String remotePath,
  }) async {
    await _withClient<void>(
      profile: profile,
      secrets: secrets,
      callback: (client) async {
        final sftp = await client.sftp();
        final file = await sftp.open(
          remotePath,
          mode: SftpFileOpenMode.create |
              SftpFileOpenMode.truncate |
              SftpFileOpenMode.write,
        );
        await file.write(Stream<Uint8List>.value(bytes));
        await file.close();
      },
    );
  }

  Future<T> _withClient<T>({
    required ServerProfile profile,
    required ServerSecrets secrets,
    required Future<T> Function(SSHClient client) callback,
  }) async {
    final socket = await SSHSocket.connect(profile.host, profile.port);
    final client = SSHClient(
      socket,
      username: profile.username,
      onPasswordRequest: () => secrets.password ?? '',
      identities: await _readIdentities(profile, secrets),
    );

    try {
      await client.authenticated;
      return await callback(client);
    } finally {
      client.close();
    }
  }

  Future<List<SSHKeyPair>> _readIdentities(
    ServerProfile profile,
    ServerSecrets secrets,
  ) async {
    if (profile.authMode != SshAuthMode.privateKey) {
      return const [];
    }
    final pem = secrets.privateKeyPem;
    if (pem == null || pem.trim().isEmpty) {
      throw StateError('Private key authentication selected but key is missing.');
    }
    return SSHKeyPair.fromPem(pem, secrets.privateKeyPassphrase);
  }

  Future<List<int>> _readStream(Stream<Uint8List> stream) async {
    final chunks = <int>[];
    await for (final chunk in stream) {
      chunks.addAll(chunk);
    }
    return chunks;
  }
}

class SshExecutionResult {
  const SshExecutionResult({
    required this.exitCode,
    required this.stdout,
    required this.stderr,
  });

  final int exitCode;
  final String stdout;
  final String stderr;
}
