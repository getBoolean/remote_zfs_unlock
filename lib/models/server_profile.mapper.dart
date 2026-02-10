// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: invalid_use_of_protected_member
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'server_profile.dart';

class ServerProfileMapper extends ClassMapperBase<ServerProfile> {
  ServerProfileMapper._();

  static ServerProfileMapper? _instance;
  static ServerProfileMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = ServerProfileMapper._());
      SshAuthModeMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'ServerProfile';

  static String _$id(ServerProfile v) => v.id;
  static const Field<ServerProfile, String> _f$id = Field('id', _$id);
  static String _$name(ServerProfile v) => v.name;
  static const Field<ServerProfile, String> _f$name = Field('name', _$name);
  static String _$host(ServerProfile v) => v.host;
  static const Field<ServerProfile, String> _f$host = Field('host', _$host);
  static int _$port(ServerProfile v) => v.port;
  static const Field<ServerProfile, int> _f$port = Field('port', _$port);
  static String _$username(ServerProfile v) => v.username;
  static const Field<ServerProfile, String> _f$username = Field(
    'username',
    _$username,
  );
  static SshAuthMode _$authMode(ServerProfile v) => v.authMode;
  static const Field<ServerProfile, SshAuthMode> _f$authMode = Field(
    'authMode',
    _$authMode,
  );

  @override
  final MappableFields<ServerProfile> fields = const {
    #id: _f$id,
    #name: _f$name,
    #host: _f$host,
    #port: _f$port,
    #username: _f$username,
    #authMode: _f$authMode,
  };

  static ServerProfile _instantiate(DecodingData data) {
    return ServerProfile(
      id: data.dec(_f$id),
      name: data.dec(_f$name),
      host: data.dec(_f$host),
      port: data.dec(_f$port),
      username: data.dec(_f$username),
      authMode: data.dec(_f$authMode),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static ServerProfile fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<ServerProfile>(map);
  }

  static ServerProfile fromJson(String json) {
    return ensureInitialized().decodeJson<ServerProfile>(json);
  }
}

mixin ServerProfileMappable {
  String toJson() {
    return ServerProfileMapper.ensureInitialized().encodeJson<ServerProfile>(
      this as ServerProfile,
    );
  }

  Map<String, dynamic> toMap() {
    return ServerProfileMapper.ensureInitialized().encodeMap<ServerProfile>(
      this as ServerProfile,
    );
  }

  ServerProfileCopyWith<ServerProfile, ServerProfile, ServerProfile>
  get copyWith => _ServerProfileCopyWithImpl<ServerProfile, ServerProfile>(
    this as ServerProfile,
    $identity,
    $identity,
  );
  @override
  String toString() {
    return ServerProfileMapper.ensureInitialized().stringifyValue(
      this as ServerProfile,
    );
  }

  @override
  bool operator ==(Object other) {
    return ServerProfileMapper.ensureInitialized().equalsValue(
      this as ServerProfile,
      other,
    );
  }

  @override
  int get hashCode {
    return ServerProfileMapper.ensureInitialized().hashValue(
      this as ServerProfile,
    );
  }
}

extension ServerProfileValueCopy<$R, $Out>
    on ObjectCopyWith<$R, ServerProfile, $Out> {
  ServerProfileCopyWith<$R, ServerProfile, $Out> get $asServerProfile =>
      $base.as((v, t, t2) => _ServerProfileCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class ServerProfileCopyWith<$R, $In extends ServerProfile, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call({
    String? id,
    String? name,
    String? host,
    int? port,
    String? username,
    SshAuthMode? authMode,
  });
  ServerProfileCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _ServerProfileCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, ServerProfile, $Out>
    implements ServerProfileCopyWith<$R, ServerProfile, $Out> {
  _ServerProfileCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<ServerProfile> $mapper =
      ServerProfileMapper.ensureInitialized();
  @override
  $R call({
    String? id,
    String? name,
    String? host,
    int? port,
    String? username,
    SshAuthMode? authMode,
  }) => $apply(
    FieldCopyWithData({
      if (id != null) #id: id,
      if (name != null) #name: name,
      if (host != null) #host: host,
      if (port != null) #port: port,
      if (username != null) #username: username,
      if (authMode != null) #authMode: authMode,
    }),
  );
  @override
  ServerProfile $make(CopyWithData data) => ServerProfile(
    id: data.get(#id, or: $value.id),
    name: data.get(#name, or: $value.name),
    host: data.get(#host, or: $value.host),
    port: data.get(#port, or: $value.port),
    username: data.get(#username, or: $value.username),
    authMode: data.get(#authMode, or: $value.authMode),
  );

  @override
  ServerProfileCopyWith<$R2, ServerProfile, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _ServerProfileCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

