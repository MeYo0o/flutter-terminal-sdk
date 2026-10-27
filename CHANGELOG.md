## 0.2.6

* Bump Android native `terminalsdk-release` to `0.2.6`.
* Add `requireNfc` to `initialize`. Android only. Set it to `false` to start the SDK on devices without NFC. Omit it to keep the native default (`true`). iOS ignores it.
* Android can initialize `Country.uae` (production host, AED 50k cap, Aani QR). iOS still has no UAE country and maps unknown values to SA.
* Align Android QR UI callbacks with native `PurchaseResponse` (still emit intent details to Dart).
* Render transaction and reconciliation receipts through the public Android `toImage` APIs.
* `amount` is the pre-tax basket total: the native SDKs now add `surchargeAmount` and the tax to the amount the cardholder approves, and report the subtotal, the fees and the fee-inclusive total on the receipt. Both fees were previously dropped, because the switch backs them out of the authorized amount instead of adding them.
* `taxPercentage` is a percentage scaled by 100, so `400` is 4.00%. The tax charged is `amount * taxPercentage / 10000`, rounded half up, matching the amount the switch derives for the receipt.
* iOS reports the tip inside `ios_data` so the backend can fill EMV tag 9F03 with it. Apple's reader authorizes a single amount and exposes no tip tag, so tipped purchases arrived with the right total but a 0.00 tip on the receipt.
* The iOS request now reports the fee-inclusive amount (subtotal plus surcharge plus tax) instead of the bare subtotal, and carries the tip only inside `ios_data`, matching the payload the switch expects.
* Android hands the reader the subtotal plus fees, without the tip. The kernel already folds the tip into EMV tag 9F02, so a tipped tap reported the tip twice and the hub receipt showed an inflated total and tax. The reader screen still shows the tipped total.
* iOS keeps the location fresh in the background while the app is open: it refreshes every 5 minutes and retries every minute after a failure. Operations use the last saved location right away and never wait for GPS, matching Android.
* iOS asks for location at SDK setup. `login`, OTP send and verify, and terminal `connect` wait for the user's answer, then fail with `location_permission_denied` (code `7001`) if location is denied or Location Services are off, matching Android setup. Operations are not blocked later. They use the last saved location. On iOS the error's `invalidType` is `locationPermissionDenied`.
* iOS always sends `is_mock`, including `false` for a real location, matching Android.
* iOS now supports iOS 15.5 and later (was 17.0). Tap to Pay still needs a device and iOS version that Apple supports.
* Add `onQrPaymentStatusCancelled` to `PurchaseWithQrCallbacks`. iOS only for now.

## 0.0.216

* Add `batchCapture()` and `isOperationSupported(operation)` end-to-end (Dart, Android, iOS). Country gating follows Android native `TerminalOperation`: `batchCapture` and `cancelTransaction` are not in that enum, so both platforms report them as supported once a terminal is available.
* Unlock iOS for routing (`routingLookup` / `routingExecute` / `routingInstallments` / `getRoutingProfile`), `installments`, `purchaseVoid`, and `refundVoid` (previously Android-only in the Flutter bridge).
* iOS `batchCapture` / `isOperationSupported` resolve the terminal by `terminalUUID`, matching Android instead of using only `currentTerminal`.
* `refundWithoutTap(...)` now accepts an optional `amount` (minor units) for a partial refund, on both platforms. The iOS bridge already read it, but Dart never sent it and the Android operation never forwarded it, so every call refunded the original transaction in full. Omitting `amount` keeps that behaviour.
* `isTerminalReady()` on iOS now reports real readiness — the terminal you asked about is connected and its reader is linked — instead of returning `true` whenever any terminal was connected. It turns `false` after a disconnect or once the backend rejects the session, as on Android. Both natives now return the same `{isReady: bool}` payload. Both platforms throw `INVALID_TERMINAL` on an unknown UUID.
* Fix `routingLookup` sending no location when the caller omits `lat`/`long`. The bridge passed an explicit null, which suppressed the location the native SDK had cached; it now omits the argument so that fix is used, which is what geofencing checks expect.
* iOS now always sends a location: the freshest fix, otherwise the last known fix, otherwise `0,0`, matching Android instead of omitting the field when no fix is available.
* iOS serves a stored fix less than 5 minutes old immediately and refreshes it in the background, so an operation no longer waits up to 10 seconds for GPS indoors.
* Forward `isLocationFromMock` from Dart to the native SDK on `generateQrCode`, `generateQrCodeWithUi` and `qrVoid`, so mocked fixes are reported as `is_mock` on iOS as they already were on Android.
* Fix the iOS intent list failing with "The response could not be decoded" when any intent had a transaction without `scheme`, `transaction_type`, `currency`, `amount_authorized` or `is_reconcilied`, or a non-UUID `original_intent_id`.
* iOS intent-list transactions now report the real currency (`code`, `decimals`, `name`, `number`) instead of empty values, matching Android.
* Bump Android native `terminalsdk-release` to `0.0.216`.

## 0.0.214

* Add tokenization support: new `purchaseWithTokenization(...)` (switch-only, US-only) and a `withTokenization` flag on `purchase(...)`, mirroring the native SDKs.
* Surface `tokenizationID` on the USA/EPX receipt model (alongside the existing `token`). The Mada receipt model accepts the field too.
* Bump Android native `terminalsdk-release` to `0.0.214`.

## 0.0.213

* Add `qrRefund` end-to-end (Dart, Android, iOS) with `QrRefundCallbacks` and native refund UI.
* Align `generateQrCodeWithUi` with React Native: forward `lat`/`long`/`isLocationFromMock`, default `enableUiDismiss` to `true`, rename `onQrUiClosed` to `onUiClosed`, and route failures/parse errors to `onNearpayException` (replaces `onQrPaymentFailure`/`onParsingFailed`).
* Bump Android native `terminalsdk-release` to `0.0.213`.

## 0.0.212

* Unlock iOS for `captureAuthorizationWithTap`, `voidAuthorizationWithTap`, and `refundWithoutTap` (RN parity).
* Add `qrVoid` end-to-end (Dart, Android, iOS) with `QrVoidCallbacks`.
* Align package version with Android native `terminalsdk-release:0.0.212`.

## 0.0.211

* Align plugin version with the bundled native `terminal-sdk` (Android `0.0.211`, iOS `TerminalSDK 1.0`).

## 0.0.1

* TODO: Describe initial release.
