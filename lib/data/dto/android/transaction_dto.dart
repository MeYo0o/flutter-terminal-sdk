/// Android transaction wire-shapes (parity with rn-terminal-sdk
/// `data/dto/android/transactionDto`).
library;

import '../shared/transaction_dto.dart';

typedef AndroidTransactionResponseDto = TransactionResponseDto;
typedef AndroidIntentDetailsDto = IntentDetailsDto;
typedef AndroidPurchaseResponseDto = PurchaseOrRefundResponseDto;
typedef AndroidRefundResponseDto = PurchaseOrRefundResponseDto;
typedef AndroidReverseResponseDto = IntentDetailsDto;
typedef AndroidAuthorizeResponseDto = AuthorizeResponseDto;
typedef AndroidCaptureResponseDto = CaptureResponseDto;
typedef AndroidVoidAuthorizationResponseDto = VoidAuthorizationResponseDto;
typedef AndroidTransactionsResponseDto = TransactionsResponseDto;
