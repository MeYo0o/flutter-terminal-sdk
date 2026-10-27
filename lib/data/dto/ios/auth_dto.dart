/// iOS auth wire-shapes (parity with rn-terminal-sdk `data/dto/ios/authDto`).
/// iOS payloads are normalized to camelCase before mapping, so these alias the
/// shared models.
library;

import '../shared/auth_dto.dart';

typedef IosOtpResponseDto = OtpResponseDto;
typedef IosNearpayUserDto = NearpayUserDto;
typedef IosAuthenticatorResultDto = AuthenticatorResultDto;
