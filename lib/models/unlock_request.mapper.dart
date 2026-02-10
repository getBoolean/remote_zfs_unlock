// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: invalid_use_of_protected_member
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'unlock_request.dart';

class UnlockMethodMapper extends EnumMapper<UnlockMethod> {
  UnlockMethodMapper._();

  static UnlockMethodMapper? _instance;
  static UnlockMethodMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = UnlockMethodMapper._());
    }
    return _instance!;
  }

  static UnlockMethod fromValue(dynamic value) {
    ensureInitialized();
    return MapperContainer.globals.fromValue(value);
  }

  @override
  UnlockMethod decode(dynamic value) {
    switch (value) {
      case 'passphrase':
        return UnlockMethod.passphrase;
      case 'keyFile':
        return UnlockMethod.keyFile;
      case 'keyFilePathOnServer':
        return UnlockMethod.keyFilePathOnServer;
      default:
        throw MapperException.unknownEnumValue(value);
    }
  }

  @override
  dynamic encode(UnlockMethod self) {
    switch (self) {
      case UnlockMethod.passphrase:
        return 'passphrase';
      case UnlockMethod.keyFile:
        return 'keyFile';
      case UnlockMethod.keyFilePathOnServer:
        return 'keyFilePathOnServer';
    }
  }
}

extension UnlockMethodMapperExtension on UnlockMethod {
  dynamic toValue() {
    UnlockMethodMapper.ensureInitialized();
    return MapperContainer.globals.toValue<UnlockMethod>(this);
  }
}

class UnlockRequestMapper extends ClassMapperBase<UnlockRequest> {
  UnlockRequestMapper._();

  static UnlockRequestMapper? _instance;
  static UnlockRequestMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = UnlockRequestMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'UnlockRequest';

  static String? _$passphrase(UnlockRequest v) => v.passphrase;
  static const Field<UnlockRequest, String> _f$passphrase = Field(
    'passphrase',
    _$passphrase,
  );
  static UnlockMethod _$method(UnlockRequest v) => v.method;
  static const Field<UnlockRequest, UnlockMethod> _f$method = Field(
    'method',
    _$method,
    mode: FieldMode.member,
  );
  static Uint8List? _$keyFileBytes(UnlockRequest v) => v.keyFileBytes;
  static const Field<UnlockRequest, Uint8List> _f$keyFileBytes = Field(
    'keyFileBytes',
    _$keyFileBytes,
    mode: FieldMode.member,
  );
  static String? _$keyFilePathOnServer(UnlockRequest v) =>
      v.keyFilePathOnServer;
  static const Field<UnlockRequest, String> _f$keyFilePathOnServer = Field(
    'keyFilePathOnServer',
    _$keyFilePathOnServer,
    mode: FieldMode.member,
  );

  @override
  final MappableFields<UnlockRequest> fields = const {
    #passphrase: _f$passphrase,
    #method: _f$method,
    #keyFileBytes: _f$keyFileBytes,
    #keyFilePathOnServer: _f$keyFilePathOnServer,
  };

  static UnlockRequest _instantiate(DecodingData data) {
    return UnlockRequest.passphrase(data.dec(_f$passphrase));
  }

  @override
  final Function instantiate = _instantiate;

  static UnlockRequest fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<UnlockRequest>(map);
  }

  static UnlockRequest fromJson(String json) {
    return ensureInitialized().decodeJson<UnlockRequest>(json);
  }
}

mixin UnlockRequestMappable {
  String toJson() {
    return UnlockRequestMapper.ensureInitialized().encodeJson<UnlockRequest>(
      this as UnlockRequest,
    );
  }

  Map<String, dynamic> toMap() {
    return UnlockRequestMapper.ensureInitialized().encodeMap<UnlockRequest>(
      this as UnlockRequest,
    );
  }

  UnlockRequestCopyWith<UnlockRequest, UnlockRequest, UnlockRequest>
  get copyWith => _UnlockRequestCopyWithImpl<UnlockRequest, UnlockRequest>(
    this as UnlockRequest,
    $identity,
    $identity,
  );
  @override
  String toString() {
    return UnlockRequestMapper.ensureInitialized().stringifyValue(
      this as UnlockRequest,
    );
  }

  @override
  bool operator ==(Object other) {
    return UnlockRequestMapper.ensureInitialized().equalsValue(
      this as UnlockRequest,
      other,
    );
  }

  @override
  int get hashCode {
    return UnlockRequestMapper.ensureInitialized().hashValue(
      this as UnlockRequest,
    );
  }
}

extension UnlockRequestValueCopy<$R, $Out>
    on ObjectCopyWith<$R, UnlockRequest, $Out> {
  UnlockRequestCopyWith<$R, UnlockRequest, $Out> get $asUnlockRequest =>
      $base.as((v, t, t2) => _UnlockRequestCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class UnlockRequestCopyWith<$R, $In extends UnlockRequest, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call({String? passphrase});
  UnlockRequestCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _UnlockRequestCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, UnlockRequest, $Out>
    implements UnlockRequestCopyWith<$R, UnlockRequest, $Out> {
  _UnlockRequestCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<UnlockRequest> $mapper =
      UnlockRequestMapper.ensureInitialized();
  @override
  $R call({Object? passphrase = $none}) => $apply(
    FieldCopyWithData({if (passphrase != $none) #passphrase: passphrase}),
  );
  @override
  UnlockRequest $make(CopyWithData data) =>
      UnlockRequest.passphrase(data.get(#passphrase, or: $value.passphrase));

  @override
  UnlockRequestCopyWith<$R2, UnlockRequest, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _UnlockRequestCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

