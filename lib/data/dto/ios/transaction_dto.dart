/// iOS transaction wire-shapes (parity with rn-terminal-sdk
/// `data/dto/ios/transactionDto`).
library;

import '../shared/transaction_dto.dart';

typedef IosTransactionResponseDto = TransactionResponseDto;
typedef IosIntentDetailsDto = IntentDetailsDto;
typedef IosPurchaseResponseDto = PurchaseOrRefundResponseDto;
typedef IosRefundResponseDto = PurchaseOrRefundResponseDto;
typedef IosReverseResponseDto = IntentDetailsDto;
typedef IosAuthorizeResponseDto = AuthorizeResponseDto;
typedef IosCaptureResponseDto = CaptureResponseDto;
typedef IosVoidAuthorizationResponseDto = VoidAuthorizationResponseDto;
typedef IosTransactionsResponseDto = TransactionsResponseDto;
