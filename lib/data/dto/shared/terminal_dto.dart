/// Shared terminal wire-shapes (parity with rn-terminal-sdk
/// `data/dto/shared/terminalDto`).
library;

class ConnectTerminalAdapterInputDto {
  final String tid;
  final String userUUID;
  final String terminalUUID;

  const ConnectTerminalAdapterInputDto({
    required this.tid,
    required this.userUUID,
    required this.terminalUUID,
  });

  factory ConnectTerminalAdapterInputDto.fromMap(Map<String, dynamic> map) {
    return ConnectTerminalAdapterInputDto(
      tid: map['tid'] as String,
      userUUID: map['userUUID'] as String,
      terminalUUID: map['terminalUUID'] as String,
    );
  }
}

class NativePaginationDto {
  final Object? totalPages;
  final Object? currentPage;
  final Object? totalData;

  const NativePaginationDto(
      {this.totalPages, this.currentPage, this.totalData});

  factory NativePaginationDto.fromMap(Map<String, dynamic> map) {
    return NativePaginationDto(
      totalPages: map['totalPages'],
      currentPage: map['currentPage'],
      totalData: map['totalData'],
    );
  }
}

class NativeTerminalConnectionDto {
  final String? name;
  final Object? tid;
  final String? uuid;
  final String? id;
  final bool? busy;
  final String? mode;
  final bool? isLocked;
  final bool? hasProfile;
  final String? userUUID;
  final Map<String, dynamic>? merchant;
  final String? client;

  const NativeTerminalConnectionDto({
    this.name,
    this.tid,
    this.uuid,
    this.id,
    this.busy,
    this.mode,
    this.isLocked,
    this.hasProfile,
    this.userUUID,
    this.merchant,
    this.client,
  });

  factory NativeTerminalConnectionDto.fromMap(Map<String, dynamic> map) {
    return NativeTerminalConnectionDto(
      name: map['name'] as String?,
      tid: map['tid'],
      uuid: map['uuid'] as String?,
      id: map['id'] as String?,
      busy: map['busy'] as bool?,
      mode: map['mode'] as String?,
      isLocked: map['isLocked'] as bool?,
      hasProfile: map['hasProfile'] as bool?,
      userUUID: map['userUUID'] as String?,
      merchant: map['merchant'] == null
          ? null
          : Map<String, dynamic>.from(map['merchant'] as Map),
      client: map['client'] as String?,
    );
  }
}

class NativeTerminalListDto {
  final List<NativeTerminalConnectionDto>? terminals;
  final NativePaginationDto? pagination;

  const NativeTerminalListDto({this.terminals, this.pagination});

  factory NativeTerminalListDto.fromMap(Map<String, dynamic> map) {
    return NativeTerminalListDto(
      terminals: (map['terminals'] as List?)
          ?.map((e) => NativeTerminalConnectionDto.fromMap(
              Map<String, dynamic>.from(e as Map)))
          .toList(),
      pagination: map['pagination'] == null
          ? null
          : NativePaginationDto.fromMap(
              Map<String, dynamic>.from(map['pagination'] as Map)),
    );
  }
}

class NativeTerminalDto {
  final Object? tid;
  final String? terminalUUID;
  final String? uuid;
  final String? id;
  final bool? isReady;
  final bool? hasReaderToken;
  final String? name;

  const NativeTerminalDto({
    this.tid,
    this.terminalUUID,
    this.uuid,
    this.id,
    this.isReady,
    this.hasReaderToken,
    this.name,
  });

  factory NativeTerminalDto.fromMap(Map<String, dynamic> map) {
    return NativeTerminalDto(
      tid: map['tid'],
      terminalUUID: map['terminalUUID'] as String?,
      uuid: map['uuid'] as String?,
      id: map['id'] as String?,
      isReady: map['isReady'] as bool?,
      hasReaderToken: map['hasReaderToken'] as bool?,
      name: map['name'] as String?,
    );
  }
}
