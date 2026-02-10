import 'package:dart_mappable/dart_mappable.dart';

part 'server_secrets.mapper.dart';

@MappableClass()
class ServerSecrets with ServerSecretsMappable {
  const ServerSecrets({
    this.password,
    this.privateKeyPem,
    this.privateKeyPassphrase,
  });

  final String? password;
  final String? privateKeyPem;
  final String? privateKeyPassphrase;
}
