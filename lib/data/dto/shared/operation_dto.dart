/// Shared standalone-operation wire-shapes (parity with rn-terminal-sdk
/// `data/dto/shared/operationDto`).
library;

class GeneratedQrCodeDto {
  final String? qrCode;
  final Object? transactionId;
  final Object? id;
  final Object? amount;

  const GeneratedQrCodeDto(
      {this.qrCode, this.transactionId, this.id, this.amount});

  factory GeneratedQrCodeDto.fromMap(Map<String, dynamic> map) {
    return GeneratedQrCodeDto(
      qrCode: map['qrCode'] as String?,
      transactionId: map['transactionId'],
      id: map['id'],
      amount: map['amount'],
    );
  }
}

class QrStatusReceiptDto {
  final Object? id;
  final String? standard;
  final String? data;

  const QrStatusReceiptDto({this.id, this.standard, this.data});

  factory QrStatusReceiptDto.fromMap(Map<String, dynamic> map) {
    return QrStatusReceiptDto(
      id: map['id'],
      standard: map['standard'] as String?,
      data: map['data'] as String?,
    );
  }
}

class QrStatusResponseDto {
  final Object? id;
  final String? status;
  final String? statusRaw;
  final String? message;
  final Object? authCode;
  final Object? actionCode;
  final Object? rrn;
  final Object? stan;
  final Object? amount;
  final QrStatusReceiptDto? receipt;

  const QrStatusResponseDto({
    this.id,
    this.status,
    this.statusRaw,
    this.message,
    this.authCode,
    this.actionCode,
    this.rrn,
    this.stan,
    this.amount,
    this.receipt,
  });

  factory QrStatusResponseDto.fromMap(Map<String, dynamic> map) {
    return QrStatusResponseDto(
      id: map['id'],
      status: map['status'] as String?,
      statusRaw: map['statusRaw'] as String?,
      message: map['message'] as String?,
      authCode: map['authCode'],
      actionCode: map['actionCode'],
      rrn: map['rrn'],
      stan: map['stan'],
      amount: map['amount'],
      receipt: map['receipt'] == null
          ? null
          : QrStatusReceiptDto.fromMap(
              Map<String, dynamic>.from(map['receipt'] as Map)),
    );
  }
}

class CanceledStateDto {
  final bool? canceled;

  const CanceledStateDto({this.canceled});

  factory CanceledStateDto.fromMap(Map<String, dynamic> map) {
    return CanceledStateDto(canceled: map['canceled'] as bool?);
  }
}

class PendingTotalDto {
  final Object? pendingTotal;
  final Object? total;

  const PendingTotalDto({this.pendingTotal, this.total});

  factory PendingTotalDto.fromMap(Map<String, dynamic> map) {
    return PendingTotalDto(
      pendingTotal: map['pendingTotal'],
      total: map['total'],
    );
  }
}

class PrintedReceiptImageDto {
  final String? image;

  const PrintedReceiptImageDto({this.image});

  factory PrintedReceiptImageDto.fromMap(Map<String, dynamic> map) {
    return PrintedReceiptImageDto(image: map['image'] as String?);
  }
}

class ProxyRoomResponseDto {
  final String? roomId;
  final String? token;
  final bool? pairingCodeIsUsed;

  const ProxyRoomResponseDto({this.roomId, this.token, this.pairingCodeIsUsed});

  factory ProxyRoomResponseDto.fromMap(Map<String, dynamic> map) {
    return ProxyRoomResponseDto(
      roomId: map['roomId'] as String?,
      token: map['token'] as String?,
      pairingCodeIsUsed: map['pairingCodeIsUsed'] as bool?,
    );
  }
}

class RoutingBinDto {
  final String? bin;
  final String? issuerId;
  final String? brand;
  final String? cardType;

  const RoutingBinDto({this.bin, this.issuerId, this.brand, this.cardType});

  factory RoutingBinDto.fromMap(Map<String, dynamic> map) {
    return RoutingBinDto(
      bin: map['bin'] as String?,
      issuerId: map['issuerId'] as String?,
      brand: map['brand'] as String?,
      cardType: map['cardType'] as String?,
    );
  }
}

class RoutingLookupResponseDto {
  final String? sessionId;
  final String? intentId;
  final bool? pinCaptured;
  final RoutingBinDto? bin;

  const RoutingLookupResponseDto({
    this.sessionId,
    this.intentId,
    this.pinCaptured,
    this.bin,
  });

  factory RoutingLookupResponseDto.fromMap(Map<String, dynamic> map) {
    return RoutingLookupResponseDto(
      sessionId: map['sessionId'] as String?,
      intentId: map['intentId'] as String?,
      pinCaptured: map['pinCaptured'] as bool?,
      bin: map['bin'] == null
          ? null
          : RoutingBinDto.fromMap(Map<String, dynamic>.from(map['bin'] as Map)),
    );
  }
}

class RoutingProfileDto {
  final String? serialNumber;
  final List<dynamic>? terminals;

  const RoutingProfileDto({this.serialNumber, this.terminals});

  factory RoutingProfileDto.fromMap(Map<String, dynamic> map) {
    return RoutingProfileDto(
      serialNumber: map['serialNumber'] as String?,
      terminals: map['terminals'] as List?,
    );
  }
}
