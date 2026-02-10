import 'package:dart_mappable/dart_mappable.dart';

part 'auth_mode.mapper.dart';

@MappableEnum()
enum SshAuthMode {
  @MappableValue('password')
  password,
  @MappableValue('privateKey')
  privateKey,
}
