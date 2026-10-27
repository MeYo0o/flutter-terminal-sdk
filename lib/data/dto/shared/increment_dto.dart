/// Shared increment-authorization wire-shapes (parity with rn-terminal-sdk
/// `data/dto/shared/incrementDto`).
library;

class IncrementEventDto {
  final Object? receipt;
  final Object? receiptModel;
  final Map<String, dynamic>? data;
  final Object? rrn;
  final Object? status;
  final Object? stan;
  final Object? type;

  const IncrementEventDto({
    this.receipt,
    this.receiptModel,
    this.data,
    this.rrn,
    this.status,
    this.stan,
    this.type,
  });

  factory IncrementEventDto.fromMap(Map<String, dynamic> map) {
    return IncrementEventDto(
      receipt: map['receipt'],
      receiptModel: map['receiptModel'],
      data: map['data'] == null
          ? null
          : Map<String, dynamic>.from(map['data'] as Map),
      rrn: map['rrn'],
      status: map['status'],
      stan: map['stan'],
      type: map['type'],
    );
  }
}

class IncrementResponseDto {
  final Object? status;
  final Object? details;
  final List<IncrementEventDto>? events;

  const IncrementResponseDto({this.status, this.details, this.events});

  factory IncrementResponseDto.fromMap(Map<String, dynamic> map) {
    return IncrementResponseDto(
      status: map['status'],
      details: map['details'],
      events: (map['events'] as List?)
          ?.map((e) =>
              IncrementEventDto.fromMap(Map<String, dynamic>.from(e as Map)))
          .toList(),
    );
  }
}
