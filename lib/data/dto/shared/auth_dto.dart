/// Shared auth wire-shapes (parity with rn-terminal-sdk
/// `data/dto/shared/authDto`).
library;

class OtpResponseDto {
  final String? message;

  const OtpResponseDto({this.message});

  factory OtpResponseDto.fromMap(Map<String, dynamic> map) {
    return OtpResponseDto(message: map['message'] as String?);
  }
}

class NearpayUserInfoDto {
  final String? name;
  final String? email;
  final String? mobile;
  final Object? id;

  const NearpayUserInfoDto({this.name, this.email, this.mobile, this.id});

  factory NearpayUserInfoDto.fromMap(Map<String, dynamic> map) {
    return NearpayUserInfoDto(
      name: map['name'] as String?,
      email: map['email'] as String?,
      mobile: map['mobile'] as String?,
      id: map['id'],
    );
  }
}

class NearpayUserDto {
  final String? name;
  final String? email;
  final String? mobile;
  final Object? userUUID;
  final Object? id;
  final NearpayUserInfoDto? info;

  const NearpayUserDto({
    this.name,
    this.email,
    this.mobile,
    this.userUUID,
    this.id,
    this.info,
  });

  factory NearpayUserDto.fromMap(Map<String, dynamic> map) {
    return NearpayUserDto(
      name: map['name'] as String?,
      email: map['email'] as String?,
      mobile: map['mobile'] as String?,
      userUUID: map['userUUID'],
      id: map['id'],
      info: map['info'] == null
          ? null
          : NearpayUserInfoDto.fromMap(
              Map<String, dynamic>.from(map['info'] as Map)),
    );
  }
}

class AuthenticatorResultDto {
  final bool? requiresOtp;
  final String? type;
  final String? value;

  const AuthenticatorResultDto({this.requiresOtp, this.type, this.value});

  factory AuthenticatorResultDto.fromMap(Map<String, dynamic> map) {
    return AuthenticatorResultDto(
      requiresOtp: map['requiresOtp'] as bool?,
      type: map['type'] as String?,
      value: map['value'] as String?,
    );
  }
}
