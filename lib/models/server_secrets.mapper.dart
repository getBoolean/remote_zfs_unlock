// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: invalid_use_of_protected_member
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'server_secrets.dart';

class ServerSecretsMapper extends ClassMapperBase<ServerSecrets> {
  ServerSecretsMapper._();

  static ServerSecretsMapper? _instance;
  static ServerSecretsMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = ServerSecretsMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'ServerSecrets';

  static String? _$password(ServerSecrets v) => v.password;
  static const Field<ServerSecrets, String> _f$password = Field(
    'password',
    _$password,
    opt: true,
  );
  static String? _$privateKeyPem(ServerSecrets v) => v.privateKeyPem;
  static const Field<ServerSecrets, String> _f$privateKeyPem = Field(
    'privateKeyPem',
    _$privateKeyPem,
    opt: true,
  );
  static String? _$privateKeyPassphrase(ServerSecrets v) =>
      v.privateKeyPassphrase;
  static const Field<ServerSecrets, String> _f$privateKeyPassphrase = Field(
    'privateKeyPassphrase',
    _$privateKeyPassphrase,
    opt: true,
  );

  @override
  final MappableFields<ServerSecrets> fields = const {
    #password: _f$password,
    #privateKeyPem: _f$privateKeyPem,
    #privateKeyPassphrase: _f$privateKeyPassphrase,
  };

  static ServerSecrets _instantiate(DecodingData data) {
    return ServerSecrets(
      password: data.dec(_f$password),
      privateKeyPem: data.dec(_f$privateKeyPem),
      privateKeyPassphrase: data.dec(_f$privateKeyPassphrase),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static ServerSecrets fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<ServerSecrets>(map);
  }

  static ServerSecrets fromJson(String json) {
    return ensureInitialized().decodeJson<ServerSecrets>(json);
  }
}

mixin ServerSecretsMappable {
  String toJson() {
    return ServerSecretsMapper.ensureInitialized().encodeJson<ServerSecrets>(
      this as ServerSecrets,
    );
  }

  Map<String, dynamic> toMap() {
    return ServerSecretsMapper.ensureInitialized().encodeMap<ServerSecrets>(
      this as ServerSecrets,
    );
  }

  ServerSecretsCopyWith<ServerSecrets, ServerSecrets, ServerSecrets>
  get copyWith => _ServerSecretsCopyWithImpl<ServerSecrets, ServerSecrets>(
    this as ServerSecrets,
    $identity,
    $identity,
  );
  @override
  String toString() {
    return ServerSecretsMapper.ensureInitialized().stringifyValue(
      this as ServerSecrets,
    );
  }

  @override
  bool operator ==(Object other) {
    return ServerSecretsMapper.ensureInitialized().equalsValue(
      this as ServerSecrets,
      other,
    );
  }

  @override
  int get hashCode {
    return ServerSecretsMapper.ensureInitialized().hashValue(
      this as ServerSecrets,
    );
  }
}

extension ServerSecretsValueCopy<$R, $Out>
    on ObjectCopyWith<$R, ServerSecrets, $Out> {
  ServerSecretsCopyWith<$R, ServerSecrets, $Out> get $asServerSecrets =>
      $base.as((v, t, t2) => _ServerSecretsCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class ServerSecretsCopyWith<$R, $In extends ServerSecrets, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call({
    String? password,
    String? privateKeyPem,
    String? privateKeyPassphrase,
  });
  ServerSecretsCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _ServerSecretsCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, ServerSecrets, $Out>
    implements ServerSecretsCopyWith<$R, ServerSecrets, $Out> {
  _ServerSecretsCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<ServerSecrets> $mapper =
      ServerSecretsMapper.ensureInitialized();
  @override
  $R call({
    Object? password = $none,
    Object? privateKeyPem = $none,
    Object? privateKeyPassphrase = $none,
  }) => $apply(
    FieldCopyWithData({
      if (password != $none) #password: password,
      if (privateKeyPem != $none) #privateKeyPem: privateKeyPem,
      if (privateKeyPassphrase != $none)
        #privateKeyPassphrase: privateKeyPassphrase,
    }),
  );
  @override
  ServerSecrets $make(CopyWithData data) => ServerSecrets(
    password: data.get(#password, or: $value.password),
    privateKeyPem: data.get(#privateKeyPem, or: $value.privateKeyPem),
    privateKeyPassphrase: data.get(
      #privateKeyPassphrase,
      or: $value.privateKeyPassphrase,
    ),
  );

  @override
  ServerSecretsCopyWith<$R2, ServerSecrets, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _ServerSecretsCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

