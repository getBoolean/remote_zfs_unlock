// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: invalid_use_of_protected_member
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'zfs_dataset.dart';

class ZfsDatasetTypeMapper extends EnumMapper<ZfsDatasetType> {
  ZfsDatasetTypeMapper._();

  static ZfsDatasetTypeMapper? _instance;
  static ZfsDatasetTypeMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = ZfsDatasetTypeMapper._());
    }
    return _instance!;
  }

  static ZfsDatasetType fromValue(dynamic value) {
    ensureInitialized();
    return MapperContainer.globals.fromValue(value);
  }

  @override
  ZfsDatasetType decode(dynamic value) {
    switch (value) {
      case r'filesystem':
        return ZfsDatasetType.filesystem;
      case r'volume':
        return ZfsDatasetType.volume;
      case r'snapshot':
        return ZfsDatasetType.snapshot;
      case r'bookmark':
        return ZfsDatasetType.bookmark;
      case r'unknown':
        return ZfsDatasetType.unknown;
      default:
        throw MapperException.unknownEnumValue(value);
    }
  }

  @override
  dynamic encode(ZfsDatasetType self) {
    switch (self) {
      case ZfsDatasetType.filesystem:
        return r'filesystem';
      case ZfsDatasetType.volume:
        return r'volume';
      case ZfsDatasetType.snapshot:
        return r'snapshot';
      case ZfsDatasetType.bookmark:
        return r'bookmark';
      case ZfsDatasetType.unknown:
        return r'unknown';
    }
  }
}

extension ZfsDatasetTypeMapperExtension on ZfsDatasetType {
  String toValue() {
    ZfsDatasetTypeMapper.ensureInitialized();
    return MapperContainer.globals.toValue<ZfsDatasetType>(this) as String;
  }
}

class ZfsDedupTypeMapper extends EnumMapper<ZfsDedupType> {
  ZfsDedupTypeMapper._();

  static ZfsDedupTypeMapper? _instance;
  static ZfsDedupTypeMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = ZfsDedupTypeMapper._());
    }
    return _instance!;
  }

  static ZfsDedupType fromValue(dynamic value) {
    ensureInitialized();
    return MapperContainer.globals.fromValue(value);
  }

  @override
  ZfsDedupType decode(dynamic value) {
    switch (value) {
      case r'on':
        return ZfsDedupType.on;
      case r'off':
        return ZfsDedupType.off;
      case r'verify':
        return ZfsDedupType.verify;
      case r'sha256':
        return ZfsDedupType.sha256;
      case r'sha256Verify':
        return ZfsDedupType.sha256Verify;
      case r'sha512':
        return ZfsDedupType.sha512;
      case r'sha512Verify':
        return ZfsDedupType.sha512Verify;
      case r'skein':
        return ZfsDedupType.skein;
      case r'skeinVerify':
        return ZfsDedupType.skeinVerify;
      case r'edonrVerify':
        return ZfsDedupType.edonrVerify;
      case r'blake3':
        return ZfsDedupType.blake3;
      case r'blake3Verify':
        return ZfsDedupType.blake3Verify;
      case r'unknown':
        return ZfsDedupType.unknown;
      default:
        throw MapperException.unknownEnumValue(value);
    }
  }

  @override
  dynamic encode(ZfsDedupType self) {
    switch (self) {
      case ZfsDedupType.on:
        return r'on';
      case ZfsDedupType.off:
        return r'off';
      case ZfsDedupType.verify:
        return r'verify';
      case ZfsDedupType.sha256:
        return r'sha256';
      case ZfsDedupType.sha256Verify:
        return r'sha256Verify';
      case ZfsDedupType.sha512:
        return r'sha512';
      case ZfsDedupType.sha512Verify:
        return r'sha512Verify';
      case ZfsDedupType.skein:
        return r'skein';
      case ZfsDedupType.skeinVerify:
        return r'skeinVerify';
      case ZfsDedupType.edonrVerify:
        return r'edonrVerify';
      case ZfsDedupType.blake3:
        return r'blake3';
      case ZfsDedupType.blake3Verify:
        return r'blake3Verify';
      case ZfsDedupType.unknown:
        return r'unknown';
    }
  }
}

extension ZfsDedupTypeMapperExtension on ZfsDedupType {
  String toValue() {
    ZfsDedupTypeMapper.ensureInitialized();
    return MapperContainer.globals.toValue<ZfsDedupType>(this) as String;
  }
}

class ZfsCompressionTypeMapper extends EnumMapper<ZfsCompressionType> {
  ZfsCompressionTypeMapper._();

  static ZfsCompressionTypeMapper? _instance;
  static ZfsCompressionTypeMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = ZfsCompressionTypeMapper._());
    }
    return _instance!;
  }

  static ZfsCompressionType fromValue(dynamic value) {
    ensureInitialized();
    return MapperContainer.globals.fromValue(value);
  }

  @override
  ZfsCompressionType decode(dynamic value) {
    switch (value) {
      case r'on':
        return ZfsCompressionType.on;
      case r'off':
        return ZfsCompressionType.off;
      case r'lzjb':
        return ZfsCompressionType.lzjb;
      case r'gzip':
        return ZfsCompressionType.gzip;
      case r'zle':
        return ZfsCompressionType.zle;
      case r'lz4':
        return ZfsCompressionType.lz4;
      case r'zstd':
        return ZfsCompressionType.zstd;
      case r'zstdFast':
        return ZfsCompressionType.zstdFast;
      case r'unknown':
        return ZfsCompressionType.unknown;
      default:
        throw MapperException.unknownEnumValue(value);
    }
  }

  @override
  dynamic encode(ZfsCompressionType self) {
    switch (self) {
      case ZfsCompressionType.on:
        return r'on';
      case ZfsCompressionType.off:
        return r'off';
      case ZfsCompressionType.lzjb:
        return r'lzjb';
      case ZfsCompressionType.gzip:
        return r'gzip';
      case ZfsCompressionType.zle:
        return r'zle';
      case ZfsCompressionType.lz4:
        return r'lz4';
      case ZfsCompressionType.zstd:
        return r'zstd';
      case ZfsCompressionType.zstdFast:
        return r'zstdFast';
      case ZfsCompressionType.unknown:
        return r'unknown';
    }
  }
}

extension ZfsCompressionTypeMapperExtension on ZfsCompressionType {
  String toValue() {
    ZfsCompressionTypeMapper.ensureInitialized();
    return MapperContainer.globals.toValue<ZfsCompressionType>(this) as String;
  }
}

class ZfsKeyFormatTypeMapper extends EnumMapper<ZfsKeyFormatType> {
  ZfsKeyFormatTypeMapper._();

  static ZfsKeyFormatTypeMapper? _instance;
  static ZfsKeyFormatTypeMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = ZfsKeyFormatTypeMapper._());
    }
    return _instance!;
  }

  static ZfsKeyFormatType fromValue(dynamic value) {
    ensureInitialized();
    return MapperContainer.globals.fromValue(value);
  }

  @override
  ZfsKeyFormatType decode(dynamic value) {
    switch (value) {
      case r'none':
        return ZfsKeyFormatType.none;
      case r'raw':
        return ZfsKeyFormatType.raw;
      case r'hex':
        return ZfsKeyFormatType.hex;
      case r'passphrase':
        return ZfsKeyFormatType.passphrase;
      case r'unknown':
        return ZfsKeyFormatType.unknown;
      default:
        throw MapperException.unknownEnumValue(value);
    }
  }

  @override
  dynamic encode(ZfsKeyFormatType self) {
    switch (self) {
      case ZfsKeyFormatType.none:
        return r'none';
      case ZfsKeyFormatType.raw:
        return r'raw';
      case ZfsKeyFormatType.hex:
        return r'hex';
      case ZfsKeyFormatType.passphrase:
        return r'passphrase';
      case ZfsKeyFormatType.unknown:
        return r'unknown';
    }
  }
}

extension ZfsKeyFormatTypeMapperExtension on ZfsKeyFormatType {
  String toValue() {
    ZfsKeyFormatTypeMapper.ensureInitialized();
    return MapperContainer.globals.toValue<ZfsKeyFormatType>(this) as String;
  }
}

class ZfsDatasetMapper extends ClassMapperBase<ZfsDataset> {
  ZfsDatasetMapper._();

  static ZfsDatasetMapper? _instance;
  static ZfsDatasetMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = ZfsDatasetMapper._());
      ZfsDatasetTypeMapper.ensureInitialized();
      ZfsDedupTypeMapper.ensureInitialized();
      ZfsCompressionTypeMapper.ensureInitialized();
      ZfsKeyFormatTypeMapper.ensureInitialized();
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
  static String _$usedByDataset(ZfsDataset v) => v.usedByDataset;
  static const Field<ZfsDataset, String> _f$usedByDataset = Field(
    'usedByDataset',
    _$usedByDataset,
  );
  static String _$available(ZfsDataset v) => v.available;
  static const Field<ZfsDataset, String> _f$available = Field(
    'available',
    _$available,
  );
  static ZfsDatasetType _$type(ZfsDataset v) => v.type;
  static const Field<ZfsDataset, ZfsDatasetType> _f$type = Field(
    'type',
    _$type,
  );
  static ZfsDedupType _$dedup(ZfsDataset v) => v.dedup;
  static const Field<ZfsDataset, ZfsDedupType> _f$dedup = Field(
    'dedup',
    _$dedup,
  );
  static ZfsCompressionType _$compression(ZfsDataset v) => v.compression;
  static const Field<ZfsDataset, ZfsCompressionType> _f$compression = Field(
    'compression',
    _$compression,
  );
  static ZfsKeyFormatType _$keyFormat(ZfsDataset v) => v.keyFormat;
  static const Field<ZfsDataset, ZfsKeyFormatType> _f$keyFormat = Field(
    'keyFormat',
    _$keyFormat,
  );
  static String _$keyLocation(ZfsDataset v) => v.keyLocation;
  static const Field<ZfsDataset, String> _f$keyLocation = Field(
    'keyLocation',
    _$keyLocation,
  );
  static String _$mountPoint(ZfsDataset v) => v.mountPoint;
  static const Field<ZfsDataset, String> _f$mountPoint = Field(
    'mountPoint',
    _$mountPoint,
  );

  @override
  final MappableFields<ZfsDataset> fields = const {
    #name: _f$name,
    #encryption: _f$encryption,
    #keyStatus: _f$keyStatus,
    #mounted: _f$mounted,
    #usedByDataset: _f$usedByDataset,
    #available: _f$available,
    #type: _f$type,
    #dedup: _f$dedup,
    #compression: _f$compression,
    #keyFormat: _f$keyFormat,
    #keyLocation: _f$keyLocation,
    #mountPoint: _f$mountPoint,
  };

  static ZfsDataset _instantiate(DecodingData data) {
    return ZfsDataset(
      name: data.dec(_f$name),
      encryption: data.dec(_f$encryption),
      keyStatus: data.dec(_f$keyStatus),
      mounted: data.dec(_f$mounted),
      usedByDataset: data.dec(_f$usedByDataset),
      available: data.dec(_f$available),
      type: data.dec(_f$type),
      dedup: data.dec(_f$dedup),
      compression: data.dec(_f$compression),
      keyFormat: data.dec(_f$keyFormat),
      keyLocation: data.dec(_f$keyLocation),
      mountPoint: data.dec(_f$mountPoint),
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
    String? usedByDataset,
    String? available,
    ZfsDatasetType? type,
    ZfsDedupType? dedup,
    ZfsCompressionType? compression,
    ZfsKeyFormatType? keyFormat,
    String? keyLocation,
    String? mountPoint,
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
    String? usedByDataset,
    String? available,
    ZfsDatasetType? type,
    ZfsDedupType? dedup,
    ZfsCompressionType? compression,
    ZfsKeyFormatType? keyFormat,
    String? keyLocation,
    String? mountPoint,
  }) => $apply(
    FieldCopyWithData({
      if (name != null) #name: name,
      if (encryption != null) #encryption: encryption,
      if (keyStatus != null) #keyStatus: keyStatus,
      if (mounted != null) #mounted: mounted,
      if (usedByDataset != null) #usedByDataset: usedByDataset,
      if (available != null) #available: available,
      if (type != null) #type: type,
      if (dedup != null) #dedup: dedup,
      if (compression != null) #compression: compression,
      if (keyFormat != null) #keyFormat: keyFormat,
      if (keyLocation != null) #keyLocation: keyLocation,
      if (mountPoint != null) #mountPoint: mountPoint,
    }),
  );
  @override
  ZfsDataset $make(CopyWithData data) => ZfsDataset(
    name: data.get(#name, or: $value.name),
    encryption: data.get(#encryption, or: $value.encryption),
    keyStatus: data.get(#keyStatus, or: $value.keyStatus),
    mounted: data.get(#mounted, or: $value.mounted),
    usedByDataset: data.get(#usedByDataset, or: $value.usedByDataset),
    available: data.get(#available, or: $value.available),
    type: data.get(#type, or: $value.type),
    dedup: data.get(#dedup, or: $value.dedup),
    compression: data.get(#compression, or: $value.compression),
    keyFormat: data.get(#keyFormat, or: $value.keyFormat),
    keyLocation: data.get(#keyLocation, or: $value.keyLocation),
    mountPoint: data.get(#mountPoint, or: $value.mountPoint),
  );

  @override
  ZfsDatasetCopyWith<$R2, ZfsDataset, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _ZfsDatasetCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

