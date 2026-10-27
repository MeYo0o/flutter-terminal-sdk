class RoutingSession {
  final ReaderEnvelope envelope;
  final String intentId;
  final bool pinCaptured;
  final dynamic location;
  final String? createdAt;

  RoutingSession({
    required this.envelope,
    required this.intentId,
    required this.pinCaptured,
    this.location,
    required this.createdAt,
  });

  factory RoutingSession.fromJson(Map<dynamic, dynamic> json) {
    return RoutingSession(
        envelope: ReaderEnvelope.fromJson(json['envelope']),
        intentId: json['intentId'],
        pinCaptured: json['pinCaptured'],
        location: json['location'],
        createdAt: json['createdAt']);
  }

  Map<dynamic, dynamic> toJson() {
    return {
      'envelope': envelope.toJson(),
      'intentId': intentId,
      'pinCaptured': pinCaptured,
      'location': location,
      'createdAt': createdAt,
    };
  }
}

class ReaderEnvelope {
  final CardEnvelope cardEnvelope;
  final dynamic pinEnvelope;

  ReaderEnvelope({
    required this.cardEnvelope,
    this.pinEnvelope,
  });

  factory ReaderEnvelope.fromJson(Map<dynamic, dynamic> json) {
    return ReaderEnvelope(
      cardEnvelope: CardEnvelope.fromJson(json['card_envelope']),
      pinEnvelope: json['pin_envelope'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'card_envelope': cardEnvelope.toJson(),
      'pin_envelope': pinEnvelope,
    };
  }
}

class CardEnvelope {
  final String type;
  final String keyId;
  final EncryptedData dataEnvelope;
  final EncryptedData keyEnvelope;

  CardEnvelope({
    required this.type,
    required this.keyId,
    required this.dataEnvelope,
    required this.keyEnvelope,
  });

  factory CardEnvelope.fromJson(Map<dynamic, dynamic> json) {
    return CardEnvelope(
      type: json['type'],
      keyId: json['key_id'],
      dataEnvelope: EncryptedData.fromJson(json['data_envelope']),
      keyEnvelope: EncryptedData.fromJson(json['key_envelope']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'key_id': keyId,
      'data_envelope': dataEnvelope.toJson(),
      'key_envelope': keyEnvelope.toJson(),
    };
  }
}

class EncryptedData {
  final String encrypted;
  final String iv;
  final String authTag;

  EncryptedData({
    required this.encrypted,
    required this.iv,
    required this.authTag,
  });

  factory EncryptedData.fromJson(Map<dynamic, dynamic> json) {
    return EncryptedData(
      encrypted: json['encrypted'],
      iv: json['iv'],
      authTag: json['auth_tag'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'encrypted': encrypted,
      'iv': iv,
      'auth_tag': authTag,
    };
  }
}
