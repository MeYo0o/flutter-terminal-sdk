/// Canonical native envelope wire-shape (parity with rn-terminal-sdk
/// `data/dto/shared/nativeEnvelopeDto`).
library;

class NativeOperationEnvelopeDto {
  final String? status;
  final Object? type;
  final Object? code;
  final String? message;
  final Object? data;
  final Map<String, dynamic>? nativeError;

  const NativeOperationEnvelopeDto({
    this.status,
    this.type,
    this.code,
    this.message,
    this.data,
    this.nativeError,
  });

  factory NativeOperationEnvelopeDto.fromMap(Map<String, dynamic> map) {
    return NativeOperationEnvelopeDto(
      status: map['status'] as String?,
      type: map['type'],
      code: map['code'],
      message: map['message'] as String?,
      data: map['data'],
      nativeError: map['nativeError'] == null
          ? null
          : Map<String, dynamic>.from(map['nativeError'] as Map),
    );
  }
}

typedef NativeOperationPayloadDto = Map<String, dynamic>;
