// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: invalid_use_of_protected_member
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'auth_mode.dart';

class SshAuthModeMapper extends EnumMapper<SshAuthMode> {
  SshAuthModeMapper._();

  static SshAuthModeMapper? _instance;
  static SshAuthModeMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = SshAuthModeMapper._());
    }
    return _instance!;
  }

  static SshAuthMode fromValue(dynamic value) {
    ensureInitialized();
    return MapperContainer.globals.fromValue(value);
  }

  @override
  SshAuthMode decode(dynamic value) {
    switch (value) {
      case 'password':
        return SshAuthMode.password;
      case 'privateKey':
        return SshAuthMode.privateKey;
      default:
        throw MapperException.unknownEnumValue(value);
    }
  }

  @override
  dynamic encode(SshAuthMode self) {
    switch (self) {
      case SshAuthMode.password:
        return 'password';
      case SshAuthMode.privateKey:
        return 'privateKey';
    }
  }
}

extension SshAuthModeMapperExtension on SshAuthMode {
  dynamic toValue() {
    SshAuthModeMapper.ensureInitialized();
    return MapperContainer.globals.toValue<SshAuthMode>(this);
  }
}

