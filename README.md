# NearPay Flutter Terminal SDK

Accept in-person card payments from a single Dart API on **both Android and iOS** (Tap to Pay). The plugin wraps the native NearPay Terminal SDKs and exposes one consistent, intent-centric API.

A few features are platform-specific (see [Platform Availability](#platform-availability)). Calling an unavailable feature throws a `NearpayException` with a clear message instead of failing silently.

---

## Table of Contents

1. [Requirements](#requirements)
2. [Installation](#installation)
3. [iOS Setup](#ios-setup)
4. [Android Setup](#android-setup)
5. [Initialization](#initialization)
6. [Authentication](#authentication)
7. [Terminals](#terminals)
8. [Transactions](#transactions)
9. [Reconciliation](#reconciliation)
10. [Queries](#queries)
11. [Authorizations](#authorizations)
12. [Callbacks](#callbacks)
13. [Error Handling](#error-handling)
14. [Utilities](#utilities)
15. [Platform Availability](#platform-availability)

---

## Requirements

**iOS**

- iOS 15.5+. Tap to Pay needs iOS 17 and a physical device (it does not run on the simulator)
- Xcode 15+ and CocoaPods
- Apple entitlement for proximity-reader payment acceptance

**Android**

- Android 9+ (API 28) device with NFC
- JDK 17
- Google Play Services (or Huawei Mobile Services for Huawei devices)

---

## Installation

Add the plugin to your `pubspec.yaml`:

```yaml
dependencies:
  flutter_terminal_sdk:
    path: ../ # or your package source
```

Then run `flutter pub get`.

---

## iOS Setup

iOS uses the pre-built `TerminalSDK.xcframework` (Tap to Pay).

- The framework is committed under `ios/Frameworks/TerminalSDK.xcframework`, so `pod install` works out of the box. To refresh it from the source SDK, run `ios/scripts/copy_unified_framework.sh`.
- Pin the deployment target to iOS 15.5 and apply the shared post-install hook from `ios/nearpay_pods.rb` (see `example/ios/Podfile`).

Add the required entitlements and `Info.plist` usage strings to your host app:

```xml
<!-- Runner.entitlements -->
<key>com.apple.developer.nfc.readersession.formats</key>
<array><string>TAG</string></array>
<key>com.apple.developer.proximity-reader.payment.acceptance</key>
<true/>
```

```xml
<!-- Info.plist -->
<key>NFCReaderUsageDescription</key>
<string>Needed to accept contactless payments.</string>
```

If your backend uses non-ATS-compliant endpoints, add an App Transport Security override in `Info.plist`. See `example/ios/Runner/Info.plist` for a complete reference.

---

## Android Setup

### Device integrity

The SDK uses **Google Play Integrity** (mandatory) and **Huawei Safety Detect** (optional) to verify device integrity.

- **Google Play Integrity:** create/select a Google Cloud project, enable the Play Integrity API (Play Console → *Release → App Integrity*), and pass the project number to `initialize(googleCloudProjectNumber: ...)`. See the [official setup guide](https://developer.android.com/google/play/integrity/setup).
- **Huawei Safety Detect:** enable Safety Detect in AppGallery Connect and pass the API key to `initialize(huaweiSafetyDetectApiKey: ...)`.

### Secure Maven repository

Add the ReaderCore repository to your root `build.gradle`:

```kotlin
allprojects {
    repositories {
        def props = new Properties()
        maven {
            url = "https://gitlab.com/api/v4/projects/37026421/packages/maven"
            credentials(HttpHeaderCredentials) {
                name = 'Private-Token'
                value = props.getProperty("gitlab.token", "ADD_YOUR_TOKEN_HERE")
            }
            authentication { header(HttpHeaderAuthentication) }
            content {
                includeGroup "io.nearpay"
                includeGroup "local.libs"
            }
        }
        maven { url 'https://jitpack.io' }
        maven { url 'https://developer.huawei.com/repo/' }
    }
}
```

### Gradle config

```kotlin
android {
    defaultConfig {
        minSdk = 28
    }
}
```

Add the following to your `AndroidManifest.xml` to avoid manifest-merger issues:

```xml
<application
    android:allowBackup="true"
    tools:replace="android:allowBackup" />
```

> Contact NearPay to register your `applicationId` and obtain credentials.

---

## Initialization

```dart
import 'package:flutter_terminal_sdk/flutter_terminal_sdk.dart';

final sdk = FlutterTerminalSdk();

await sdk.initialize(
  environment: Environment.sandbox,
  country: Country.sa,
  googleCloudProjectNumber: 1234567890,       // Android only
  huaweiSafetyDetectApiKey: 'YOUR_API_KEY',   // Android only, optional
  requireNfc: true,                           // Android only, optional, default true
);
```

Set `requireNfc: false` to start the SDK on Android devices without NFC.

`Country.uae` is Android-only. iOS still has no UAE country and treats unknown values as `Country.sa`.

Check device readiness before transacting:

```dart
await sdk.checkRequiredPermissions();
final nfcReady = await sdk.isNfcEnabled();
final wifiReady = await sdk.isWifiEnabled();

// Read the native SDK version.
final version = await sdk.getVersion();
```

---

## Authentication

The SDK supports OTP (mobile/email) and JWT authentication.

### OTP

```dart
// Mobile
await sdk.sendMobileOtp('<MOBILE_NUMBER>');
final user = await sdk.verifyMobileOtp(mobileNumber: '<MOBILE_NUMBER>', code: '<OTP_CODE>');

// Email
await sdk.sendEmailOtp('<EMAIL_ADDRESS>');
final user = await sdk.verifyEmailOtp(email: '<EMAIL_ADDRESS>', code: '<OTP_CODE>');
```

### JWT

```dart
final terminal = await sdk.jwtLogin(jwt: '<YOUR_JWT_TOKEN>');
```

### Users

```dart
final user = await sdk.getUserByUUID(uuid: user.userUUID);
final users = await sdk.getUsers();          // Android only
await sdk.logout(userUUID: user.userUUID);
```

> Persisting the user UUID is the integrating app's responsibility, not the SDK's.

---

## Terminals

### List terminals

```dart
final terminals = await sdk.getTerminalList(user.userUUID, page: 1, pageSize: 10);
```

### Connect a terminal

```dart
final terminal = await sdk.connectTerminal(
  tid: t.tid,
  userUUID: t.userUUID,
  terminalUUID: t.uuid,
  linkingCallbacks: LinkingCallbacks(
    onLinkingStarted: () {},
    onLinkingCompleted: (_) {},
    onLinkingFailure: (error) {},
  ), // optional
);
```

### Get / refresh a terminal

```dart
final terminal = await sdk.getTerminal(terminalUUID: '<TERMINAL_UUID>');
```

### Terminal-interface helpers

Once connected, the same lookups and config are available on the terminal:

```dart
final user = await terminal.getUser(user.userUUID);
final config = await terminal.getTerminalConfig();
await sdk.disconnectTerminal();
```

---

## Transactions

All transactional flows are **intent-centric**: an intent groups every attempt, event, and receipt of a payment journey. Generate an `intentUUID` and reuse it across related operations. `amount`, `amountOther` and `surchargeAmount` are in minor units (halalas/cents), while `taxPercentage` is a rate scaled by 100, so `400` means 4.00%.

`amount` is the pre-tax basket total. The SDK charges `amount * taxPercentage / 10000` in tax, adds it and `surchargeAmount` to the amount the cardholder approves, and the receipt reports the subtotal, the fees, and the fee-inclusive total. Do not add the fees to `amount` yourself, or they will be charged twice.

### Purchase

```dart
import 'package:uuid/uuid.dart';

final intentUUID = const Uuid().v4();

final response = await terminal.purchase(
  intentUUID: intentUUID,
  amount: 1455,                 // 14.55
  scheme: PaymentScheme.VISA,
  surchargeAmount: 100,         // optional
  taxPercentage: 400,           // optional
  callbacks: PurchaseCallbacks(
    cardReaderCallbacks: CardReaderCallbacks(
      onReadingStarted: () {},
      onReaderReading: () {},
      onCardReadSuccess: () {},
      onReaderError: (message) {},
    ),
    onTransactionPurchaseCompleted: (res) {},
    onSendTransactionFailure: (message) {},
  ),
);
```

### Purchase with tip

```dart
await terminal.purchaseWithTip(
  intentUUID: const Uuid().v4(),
  amount: 1455,
  amountOther: 200,             // tip
  scheme: PaymentScheme.VISA,
  callbacks: PurchaseCallbacks(/* ... */),
);
```

### Purchase with tokenization — *US only*

Pass `withTokenization: true` to `purchase(...)` to tokenize the card while
charging it; the resulting `tokenizationID` is returned on the USA/EPX receipt
and can be charged later without a card present:

```dart
await terminal.purchase(
  intentUUID: const Uuid().v4(),
  amount: 1455,
  withTokenization: true,
  callbacks: PurchaseCallbacks(/* ... */),
);

await terminal.purchaseWithTokenization(
  intentUUID: const Uuid().v4(),
  tokenizationID: '<TOKENIZATION_ID>', // from a previous tokenized receipt
  amount: 1455,
  surchargeAmount: 100,         // optional
  taxPercentage: 400,           // optional
  callbacks: PurchaseCallbacks(
    onTransactionPurchaseCompleted: (res) {},
    onSendTransactionFailure: (message) {},
  ),
);
```

`purchaseWithTokenization` is card-less, so no `CardReaderCallbacks` fire. The
operation is restricted to US terminals and fails locally on every other
country.

### Installments — *Android only*

```dart
await terminal.installments(
  intentUUID: const Uuid().v4(),
  amount: 1455,
  numberOfInstallments: 3,
  scheme: PaymentScheme.VISA,
  callbacks: PurchaseCallbacks(/* ... */),
);
```

### Refund

```dart
await terminal.refund(
  intentUUID: '<ORIGINAL_INTENT_UUID>', // original purchase intent
  refundUUID: const Uuid().v4(),        // new refund intent
  amount: 1000,
  scheme: PaymentScheme.VISA,
  callbacks: RefundCallbacks(
    onTransactionRefundCompleted: (res) {},
    onSendTransactionFailure: (message) {},
  ),
);
```

### Open refund

The SDK generates the refund UUID for you:

```dart
await terminal.openRefund(
  intentUUID: '<INTENT_UUID>',
  amount: 1000,
  callbacks: OpenRefundCallbacks(/* ... */),
);
```

### Tip an existing transaction

```dart
await terminal.tipTransaction(id: '<ORIGINAL_INTENT_ID>', amount: 200);
```

### Void purchase / refund — *Android only*

```dart
await terminal.purchaseVoid(
  intentUUID: '<INTENT_UUID>',
  amount: 1455,
  callbacks: PurchaseVoidCallbacks(/* ... */),
);

await terminal.refundVoid(
  intentUUID: '<INTENT_UUID>',
  amount: 1000,
  callbacks: RefundVoidCallbacks(/* ... */),
);
```

### Reverse / cancel

```dart
await terminal.reverseTransaction(intent: '<INTENT_ID>');
await terminal.cancelTransaction(id: '<INTENT_ID>');
await terminal.dismissReaderUi();   // hide the reader UI programmatically
```

---

## Reconciliation

```dart
final list = await terminal.getReconcileList(page: 1, pageSize: 10);
final details = await terminal.getReconcileDetails(uuid: '<RECONCILE_ID>');
final result = await terminal.reconcile();
```

---

## Queries

```dart
final intents = await terminal.getIntentList(page: 1, pageSize: 10);
final details = await terminal.getIntentDetails(intentUUID: '<INTENT_UUID>');
```

Every transactional response also exposes an `IntentDetails` object, so you can inspect the latest transactions and receipts without an extra network call.

---

## Authorizations

Reserve funds, then capture, increment, or void them later. Use the returned authorization UUID for follow-up calls.

```dart
// Authorize
final auth = await terminal.authorize(
  uuid: const Uuid().v4(),
  amount: 5000,
  callbacks: AuthorizedCallbacks(/* ... */),
);

// Capture
await terminal.captureAuthorization(
  uuid: const Uuid().v4(),
  authorizationUuid: '<AUTHORIZATION_UUID>',
  amount: 5000,
);

// Increment
await terminal.incrementAuthorization(
  uuid: const Uuid().v4(),
  authorizationUuid: '<AUTHORIZATION_UUID>',
  amount: 500,
);

// Void
await terminal.voidAuthorization(uuid: '<AUTHORIZATION_UUID>');

// Pending total
final pending = await terminal.getPendingTotal();
```

`captureAuthorizationWithTap` and `voidAuthorizationWithTap` provide the same results with live tap-to-pay reader updates on both platforms.

---

## Callbacks

Transaction methods accept rich callback objects so you can react to reader and linking lifecycle events.

**Card reader** (`CardReaderCallbacks`):

```dart
CardReaderCallbacks(
  onReaderDisplayed: () {},
  onReadingStarted: () {},
  onReaderWaiting: () {},
  onReaderReading: () {},
  onReaderRetry: () {},
  onPinEntering: () {},
  onReaderFinished: () {},
  onReaderClosed: () {},
  onReaderDismissed: () {},
  onCardReadSuccess: () {},
  onCardReadFailure: (message) {},
  onReaderError: (message) {},
);
```

**Linking** (`LinkingCallbacks`, primarily iOS):

```dart
LinkingCallbacks(
  onLinkingStarted: () {},
  onPreparingToLink: (data) {},
  onLinkingProgress: (progress) {},
  onLinkingCompleted: (data) {},
  onRelinking: (data) {},
  onLinkingFailure: (error) {},
);
```

Each transaction type also has its own completion/failure callback (e.g. `onTransactionPurchaseCompleted`, `onTransactionRefundCompleted`).

---

## Error Handling

Async methods throw `NearpayException` on failure. Wrap calls in `try/catch`:

```dart
try {
  await terminal.purchase(/* ... */);
} on NearpayException catch (e) {
  print('NearPay error: ${e.message}');
}
```

Features that are unavailable on the current platform also throw `NearpayException` with a descriptive message.

---

## Utilities

### Generate QR code

```dart
final qr = await terminal.generateQrCode(
  id: const Uuid().v4(),
  amount: '1455',
);
final status = await terminal.qrStatus(transactionId: qr.transactionId);

await terminal.qrVoid(
  intentId: const Uuid().v4(),
  originalIntentId: qr.transactionId,
  callbacks: QrVoidCallbacks(
    onQrVoidSuccess: (status) {},
    onQrVoidFailure: (error) {},
  ),
);
```

### Render a receipt to an image — *Android only*

```dart
final Uint8List bytes = await receipt.toImage(receiptWidth: 384, fontSize: 12);

final reconciliation = await terminal.getReconciliation(
  uuid: '<RECONCILIATION_UUID>',
);
final Uint8List reconciliationBytes = await reconciliation.toImage(
  receiptWidth: 384,
  fontSize: 12,
);
```

---

## Platform Availability

The following are **Android only** and throw `NearpayException` on iOS:

- `installments`, `purchaseVoid`, `refundVoid`
- `routingLookup`, `routingExecute`, `routingInstallments`, `getRoutingProfile`
- receipt `toImage`, `printMadaReceipt`, `getUsers`
- `shareInvoice`, NFC receipt share, `createProxyRoom`

The following are **iOS only** and throw `NearpayException` on Android:

- `authenticator`
- `getProduct`

Always test on a physical device.
