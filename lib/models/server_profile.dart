import 'package:dart_mappable/dart_mappable.dart';
import 'package:remote_zfs_unlock/models/auth_mode.dart';

part 'server_profile.mapper.dart';

@MappableClass()
class ServerProfile with ServerProfileMappable {
  const ServerProfile({
    required this.id,
    required this.name,
    required this.host,
    required this.port,
    required this.username,
    required this.authMode,
    this.macAddress,
    this.broadcastAddress,
  });

  final String id;
  final String name;
  final String host;
  final int port;
  final String username;
  final SshAuthMode authMode;
  final String? macAddress;
  final String? broadcastAddress;
}
