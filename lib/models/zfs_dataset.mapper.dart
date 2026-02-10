// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: invalid_use_of_protected_member
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'zfs_dataset.dart';

class ZfsDatasetMapper extends ClassMapperBase<ZfsDataset> {
  ZfsDatasetMapper._();

  static ZfsDatasetMapper? _instance;
  static ZfsDatasetMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = ZfsDatasetMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'ZfsDataset';

  static String _$name(ZfsDataset v) => v.name;
  static const Field<ZfsDataset, String> _f$name = Field('name', _$name);
  static String _$encryption(ZfsDataset v) => v.encryption;
  static const Field<ZfsDataset, String> _f$encryption = Field(
    'encryption',
    _$encryption,
  );
  static String _$keyStatus(ZfsDataset v) => v.keyStatus;
  static const Field<ZfsDataset, String> _f$keyStatus = Field(
    'keyStatus',
    _$keyStatus,
  );
  static String _$mounted(ZfsDataset v) => v.mounted;
  static const Field<ZfsDataset, String> _f$mounted = Field(
    'mounted',
    _$mounted,
  );

  @override
  final MappableFields<ZfsDataset> fields = const {
    #name: _f$name,
    #encryption: _f$encryption,
    #keyStatus: _f$keyStatus,
    #mounted: _f$mounted,
  };

  static ZfsDataset _instantiate(DecodingData data) {
    return ZfsDataset(
      name: data.dec(_f$name),
      encryption: data.dec(_f$encryption),
      keyStatus: data.dec(_f$keyStatus),
      mounted: data.dec(_f$mounted),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static ZfsDataset fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<ZfsDataset>(map);
  }

  static ZfsDataset fromJson(String json) {
    return ensureInitialized().decodeJson<ZfsDataset>(json);
  }
}

mixin ZfsDatasetMappable {
  String toJson() {
    return ZfsDatasetMapper.ensureInitialized().encodeJson<ZfsDataset>(
      this as ZfsDataset,
    );
  }

  Map<String, dynamic> toMap() {
    return ZfsDatasetMapper.ensureInitialized().encodeMap<ZfsDataset>(
      this as ZfsDataset,
    );
  }

  ZfsDatasetCopyWith<ZfsDataset, ZfsDataset, ZfsDataset> get copyWith =>
      _ZfsDatasetCopyWithImpl<ZfsDataset, ZfsDataset>(
        this as ZfsDataset,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return ZfsDatasetMapper.ensureInitialized().stringifyValue(
      this as ZfsDataset,
    );
  }

  @override
  bool operator ==(Object other) {
    return ZfsDatasetMapper.ensureInitialized().equalsValue(
      this as ZfsDataset,
      other,
    );
  }

  @override
  int get hashCode {
    return ZfsDatasetMapper.ensureInitialized().hashValue(this as ZfsDataset);
  }
}

extension ZfsDatasetValueCopy<$R, $Out>
    on ObjectCopyWith<$R, ZfsDataset, $Out> {
  ZfsDatasetCopyWith<$R, ZfsDataset, $Out> get $asZfsDataset =>
      $base.as((v, t, t2) => _ZfsDatasetCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class ZfsDatasetCopyWith<$R, $In extends ZfsDataset, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call({
    String? name,
    String? encryption,
    String? keyStatus,
    String? mounted,
  });
  ZfsDatasetCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _ZfsDatasetCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, ZfsDataset, $Out>
    implements ZfsDatasetCopyWith<$R, ZfsDataset, $Out> {
  _ZfsDatasetCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<ZfsDataset> $mapper =
      ZfsDatasetMapper.ensureInitialized();
  @override
  $R call({
    String? name,
    String? encryption,
    String? keyStatus,
    String? mounted,
  }) => $apply(
    FieldCopyWithData({
      if (name != null) #name: name,
      if (encryption != null) #encryption: encryption,
      if (keyStatus != null) #keyStatus: keyStatus,
      if (mounted != null) #mounted: mounted,
    }),
  );
  @override
  ZfsDataset $make(CopyWithData data) => ZfsDataset(
    name: data.get(#name, or: $value.name),
    encryption: data.get(#encryption, or: $value.encryption),
    keyStatus: data.get(#keyStatus, or: $value.keyStatus),
    mounted: data.get(#mounted, or: $value.mounted),
  );

  @override
  ZfsDatasetCopyWith<$R2, ZfsDataset, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _ZfsDatasetCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

