/// Android auth wire-shapes (parity with rn-terminal-sdk
/// `data/dto/android/authDto`). Android payloads are post-normalization
/// camelCase, so these alias the shared models.
library;

import '../shared/auth_dto.dart';

typedef AndroidOtpResponseDto = OtpResponseDto;
typedef AndroidNearpayUserDto = NearpayUserDto;
typedef AndroidAuthenticatorResultDto = AuthenticatorResultDto;
