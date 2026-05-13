import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_terminal_sdk/flutter_terminal_sdk.dart';
import 'package:flutter_terminal_sdk/models/authorized_callbacks.dart';
import 'package:flutter_terminal_sdk/models/capture_authorization_with_tap_callbacks.dart';
import 'package:flutter_terminal_sdk/models/card_reader_callbacks.dart';
import 'package:flutter_terminal_sdk/models/data/authorize_response.dart';
import 'package:flutter_terminal_sdk/models/data/dto/transaction_response_turkey.dart';
import 'package:flutter_terminal_sdk/models/data/payment_scheme.dart';
import 'package:flutter_terminal_sdk/models/data/purchase_response.dart';
import 'package:flutter_terminal_sdk/models/data/refund_response.dart';
import 'package:flutter_terminal_sdk/models/data/transaction_response.dart';
import 'package:flutter_terminal_sdk/models/data/ui_dock_position.dart';
import 'package:flutter_terminal_sdk/models/intents_list_response.dart';
import 'package:flutter_terminal_sdk/models/nearpay_user_response.dart';
import 'package:flutter_terminal_sdk/models/open_refund_callbacks.dart';
import 'package:flutter_terminal_sdk/models/purchase_callbacks.dart';
import 'package:flutter_terminal_sdk/models/purchase_void_callbacks.dart';
import 'package:flutter_terminal_sdk/models/purchase_with_qr_callbacks.dart';
import 'package:flutter_terminal_sdk/models/refund_callbacks.dart';
import 'package:flutter_terminal_sdk/models/refund_void_callbacks.dart';
import 'package:flutter_terminal_sdk/models/terminal_connection_response.dart';
import 'package:flutter_terminal_sdk/models/terminal_response.dart';
import 'package:flutter_terminal_sdk/models/terminal_sdk_initialization_listener.dart';
import 'package:flutter_terminal_sdk_example/sst.dart';
import 'package:shared_preferences/shared_preferences.dart';

// import 'package:url_launcher/url_launcher.dart';
import 'package:uuid/uuid.dart';

// lunch url
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: PluginExample());
  }
}

class PluginExample extends StatefulWidget {
  const PluginExample({super.key});

  @override
  _PluginExampleState createState() => _PluginExampleState();
}

class _PluginExampleState extends State<PluginExample> {
  final FlutterTerminalSdk _terminalSdk = FlutterTerminalSdk();

  String _status = "Ready";
  String? transactionUuid;
  String? intentId;
  String? authTransactionUuid;
  String? authIntentId;
  bool? isConnected = false;
  String? refundUuid;
  String? reconcileId;
  PurchaseResponse? purchaseResponse;

  //logoBytes
  Uint8List? logoBytes;

  // _prefs
  late SharedPreferences _prefs;

  // Initialize SharedPreferences
  Future<void> initPrefs() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // check if there is a saved terminal in prefs
  Future<void> loadTerminalFromPrefs() async {
    final tid = _prefs.getString('terminal_tid');
    final uuid = _prefs.getString('terminal_uuid');
    final terminalName = _prefs.getString('terminal_name');

    if (tid != null && uuid != null && terminalName != null) {
      // If we have saved terminal info, connect to it
      // create a TerminalConnectionModel
      _connectedTerminal = TerminalModel(
        tid: tid,
        name: terminalName,
        terminalUUID: uuid,
      );
    }
  }

  @override
  void initState() {
    initPrefs();
    super.initState();
  }

  final TextEditingController _mobileController =
      TextEditingController(text: "");
  final TextEditingController _emailController =
      TextEditingController(text: "");
  final TextEditingController _otpController = TextEditingController(text: "");
  final TextEditingController _amountController =
      TextEditingController(text: "");
  final TextEditingController _tipAmountController =
      TextEditingController(text: "");
  final TextEditingController _numberOfInstallmentsController =
      TextEditingController(text: "");
  final TextEditingController result = TextEditingController(text: "");
  final TextEditingController _jwtController = TextEditingController(text: "");
  final TextEditingController _imageWidthController =
      TextEditingController(text: "");
  final TextEditingController _fontSizeController =
      TextEditingController(text: "");

  PaymentScheme _selectedScheme = PaymentScheme.VISA;

  NearpayUser? _verifiedUser;

  List<TerminalConnectionModel> _terminals = [];
  List<NearpayUser> _users = [];

  TerminalModel? _connectedTerminal;

  Future<void> _initializeSdk() async {
    try {
      setState(() => _status = "Initializing...");
      await _terminalSdk.initialize(
          environment: Environment.sandbox,
          googleCloudProjectNumber: 0,
          // huaweiSafetyDetectApiKey: "",
          country: Country.sa,
          pinPosition: UiDockPosition.BOTTOM_RIGHT,
          uiDockPosition: UiDockPosition.BOTTOM_RIGHT,
          supportSecondDisplay: SupportSecondDisplay.enable,
          secondDisplayDockPosition: UiDockPosition.TOP_CENTER,
          // initializationListener: TerminalSDKInitializationListener(
          //   onInitializationSuccess: () {
          //     print("SDK Initialization Success");
          //     setState(() => _status = "SDK Initialization Success");
          //   },
          //   onInitializationFailure: (message) {
          //     print("SDK Initialization Failure: $message");
          //     setState(() => _status = "SDK Initialization Failure: $message");
          //   },
          // )
      );
      setState(() => _status = "SDK Initialized ");
    } catch (e) {
      setState(() => _status = "Error initializing: $e");
    }
  }

  Future<void> _requestPermissions() async {
    try {
      setState(() => _status = "checkRequiredPermissions...");

      var permissions = await _terminalSdk.checkRequiredPermissions();
      String permission = "";
      for (var element in permissions) {
        print("permissions: ${element.permission}, ${element.isGranted}");
        permission = "$permission${element.permission} ${element.isGranted}\n";
      }
      setState(() => _status = "permissions: $permission");
    } catch (e) {
      setState(() => _status = "Error initializing: $e");
    }
  }

  Future<void> _checkWifi() async {
    try {
      setState(() => _status = "checkWifi...");

      var wifi = await _terminalSdk.isWifiEnabled();

      setState(() => _status = "wifi: $wifi");
    } catch (e) {
      setState(() => _status = "Error initializing: $e");
    }
  }

  // check nfc
  Future<void> _checkNfc() async {
    try {
      setState(() => _status = "checkNfc...");

      var nfc = await _terminalSdk.isNfcEnabled();

      setState(() => _status = "nfc: $nfc");
    } catch (e) {
      setState(() => _status = "Error initializing: $e");
    }
  }

  /// Send Mobile OTP
  Future<void> _sendMobileOtp() async {
    if (!_terminalSdk.isInitialized) {
      setState(() => _status = "SDK not initialized yet");
      return;
    }

    final mobile = _mobileController.text;
    if (mobile.isEmpty) {
      setState(() => _status = "Please enter a mobile number");
      return;
    }

    try {
      setState(() => _status = "Sending OTP...");
      await _terminalSdk.sendMobileOtp(mobile);
      setState(() => _status = "OTP sent to $mobile");
    } catch (e) {
      setState(() => _status = "Error sending OTP: $e");
    }
  }

  /// Verify Mobile OTP
  Future<void> _verifyMobileOtp() async {
    if (!_terminalSdk.isInitialized) {
      setState(() => _status = "SDK not initialized yet");
      return;
    }

    final mobile = _mobileController.text.trim();
    final code = _otpController.text.trim();
    if (mobile.isEmpty || code.isEmpty) {
      setState(() => _status = "Please enter mobile number AND OTP code");
      return;
    }

    try {
      setState(() => _status = "Verifying OTP...");
      final user = await _terminalSdk.verifyMobileOtp(
        mobileNumber: mobile,
        code: code,
      );
      setState(() {
        _verifiedUser = user;
        _status =
            "OTP verified! User: ${user.name} \n ${user.mobile} \n ${user.email}";
      });
    } catch (e) {
      setState(() => _status = "Error verifying OTP: $e");
    }
  }

  /// Verify Mobile OTP
  Future<void> _verifyJWT() async {
    if (!_terminalSdk.isInitialized) {
      setState(() => _status = "SDK not initialized yet");
      return;
    }

    final jwt = _jwtController.text.trim();
    if (jwt.isEmpty) {
      setState(() => _status = "Please enter jwt");
      return;
    }

    try {
      setState(() => _status = "Verifying jwt...");
      final terminalModel =
          await _terminalSdk.jwtLogin(jwt: _jwtController.text);

      // save terminalModel to _sharedPreferences

      saveTerminalToPrefs(terminalModel);
      setState(() {
        _connectedTerminal = terminalModel;
        _status = "jwt verified! terminal: ${terminalModel.toString()}";
        print("jwt verified! terminal: ${terminalModel.toString()}");
      });
    } catch (ex) {
      setState(() => _status = "Error verifying OTP: $ex");
    }
  }

  /// Send Email OTP
  Future<void> _sendEmailOtp() async {
    if (!_terminalSdk.isInitialized) {
      setState(() => _status = "SDK not initialized yet");
      return;
    }

    final email = _emailController.text;
    if (email.isEmpty) {
      setState(() => _status = "Please enter an email address");
      return;
    }

    try {
      setState(() => _status = "Sending OTP...");
      await _terminalSdk.sendEmailOtp(email);
      setState(() => _status = "OTP sent to $email");
    } catch (e) {
      setState(() => _status = "Error sending OTP: $e");
    }
  }

  /// Verify Mobile OTP
  Future<void> _verifyEmailOtp() async {
    if (!_terminalSdk.isInitialized) {
      setState(() => _status = "SDK not initialized yet");
      return;
    }

    final email = _emailController.text.trim();
    final code = _otpController.text.trim();
    if (email.isEmpty || code.isEmpty) {
      setState(() => _status = "Please enter email address AND OTP code");
      return;
    }

    try {
      setState(() => _status = "Verifying OTP...");
      final user = await _terminalSdk.verifyEmailOtp(
        email: email,
        code: code,
      );
      setState(() {
        _verifiedUser = user;
        _status = "OTP verified! User: ${user.name}";
      });
    } catch (e) {
      setState(() => _status = "Error verifying OTP: $e");
    }
  }

  /// get User
  Future<void> _getUser() async {
    if (!_terminalSdk.isInitialized) {
      setState(() => _status = "SDK not initialized yet");
      return;
    }

    try {
      setState(() => _status = "getting user...");
      final user = await _terminalSdk.getUserByUUID(
        uuid: _verifiedUser!.userUUID!,
      );
      setState(() {
        _verifiedUser = user;
        _status = "User: ${user.name} ${user.email} ${user.mobile}";
      });
    } catch (e) {
      setState(() => _status = "$e");
    }
  }

  /// get Users
  Future<void> _getUsers() async {
    if (!_terminalSdk.isInitialized) {
      setState(() => _status = "SDK not initialized yet");
      return;
    }

    try {
      setState(() => _status = "getting user...");
      final listOfUsers = await _terminalSdk.getUsers();
      for (var item in listOfUsers) {
        print(item.name);
      }
      setState(() {
        if (listOfUsers.isNotEmpty) {
          _users = listOfUsers;
          _status = "listOfUsers: ${listOfUsers.length} ";
        } else {
          _status = "No user found";
        }
      });
    } catch (e) {
      setState(() => _status = "$e");
    }
  }

  /// logout
  Future<void> _logout() async {
    if (!_terminalSdk.isInitialized) {
      setState(() => _status = "SDK not initialized yet");
      return;
    }

    try {
      setState(() => _status = "logging out...");
      final message = await _terminalSdk.logout(
        userUUID: _verifiedUser!.userUUID!,
      );
      setState(() {
        _verifiedUser = null;
        _status = message;
      });
    } catch (e) {
      setState(() => _status = "$e");
    }
  }

  /// Get Terminals for the verified user
  Future<void> _getTerminals() async {
    if (_verifiedUser == null) {
      setState(() => _status = "No verified user yet");
      return;
    }
    try {
      setState(() => _status = "Fetching terminals...");
      print("_verifiedUser!.userUUID! ${_verifiedUser!.userUUID}");
      final terminalList = await _terminalSdk
          .getTerminalList(_verifiedUser!.userUUID!, page: 1, pageSize: 10);
      setState(() {
        _terminals = terminalList.terminals;
        _status = "Fetched ${_terminals.length} terminals";
      });
    } catch (e) {
      setState(() => _status = "Error fetching terminals: $e");
    }
  }

  // _getPendingTotal
  Future<void> _getPendingTotal() async {
    if (!_terminalSdk.isInitialized) {
      setState(() => _status = "SDK not initialized yet");
      return;
    }

    if (_connectedTerminal == null) {
      setState(() => _status =
          "No connected terminal. Please connect to a terminal first.");
      return;
    }

    var total = await _connectedTerminal?.getPendingTotal();

    setState(() {
      _status = "Total pending = $total";
    });
  }

  // _getTerminalConfig
  Future<void> _getTerminalConfig() async {
    if (!_terminalSdk.isInitialized) {
      setState(() => _status = "SDK not initialized yet");
      return;
    }

    if (_connectedTerminal == null) {
      setState(() => _status =
          "No connected terminal. Please connect to a terminal first.");
      return;
    }

    final config = await _connectedTerminal!.getTerminalConfig();

    setState(() {
      _status = "Terminal config: ${config.currencyNumericCode} / "
          "${config.currencyDefaultFractionDigits} decimals, "
          "${config.schemes.length} scheme(s)";
    });
  }

  /// Get Terminals for the verified user
  Future<void> _getTerminal() async {
    try {
      if (!_terminalSdk.isInitialized) {
        setState(() => _status = "SDK not initialized yet");
        return;
      }

      if (_connectedTerminal == null) {
        setState(() => _status = "Please connect to a terminal first");
        return;
      }

      print("get Terminal Terminal... ${_connectedTerminal?.terminalUUID}");

      setState(() => _status = "get Terminal Terminal...");
      final fetchedTerminal = await _terminalSdk.getTerminal(
        terminalUUID: _connectedTerminal!.terminalUUID!,
      );

      setState(() {
        _connectedTerminal = fetchedTerminal;
        _status = "Fetched terminal ${_connectedTerminal?.tid}  }";
      });
    } catch (e) {
      setState(() => _status = "Error fetching terminal: $e");
    }
  }

  /// Example reverse
  Future<void> _reverse() async {
    if (!_terminalSdk.isInitialized) {
      setState(() => _status = "SDK not initialized yet");
      return;
    }

    if (_connectedTerminal == null) {
      setState(() => _status =
          "No connected terminal. Please connect to a terminal first.");
      return;
    }

    if (intentId == null) {
      setState(() => _status = "No intentId to reverse.");
      return;
    }

    print("intentId $intentId");
    try {
      final reverseResponse =
          await _connectedTerminal!.reverseTransaction(intentId: intentId!);
      setState(() => _status =
          "reverse Successful! ${reverseResponse.details.transactions?[0].id}");
    } catch (e) {
      setState(() => _status = "Error in reverse: $e");
      return;
    }
  }

  /// Connect to a specific terminal
  Future<void> _connectToTerminal(TerminalConnectionModel terminal) async {
    if (_verifiedUser == null) {
      setState(() => _status = "No verified user yet");
      return;
    }

    try {
      setState(() => _status =
          "Connecting to terminal ${terminal.name ?? terminal.tid}...");

      print(
          "terminal.tid ${terminal.tid} terminal.uuid ${terminal.uuid} userUUID ${terminal.userUUID}");

      final connectedTerminal = await _terminalSdk.connectTerminal(
        tid: terminal.tid,
        userUUID: terminal.userUUID,
        terminalUUID: terminal.uuid,
      );

      print("connectedTerminal tid ${connectedTerminal.tid}");
      print("connectedTerminal terminalUUID ${connectedTerminal.terminalUUID}");
      setState(() {
        isConnected = true;
        _connectedTerminal = connectedTerminal;
        _status = "Connected to TID: ${connectedTerminal.tid}}";
      });
    } catch (e) {
      setState(() => _status = "Error connecting: $e");
    }
  }

  /// Connect to a specific terminal
  Future<void> _connectToTerminal2(
      {required String tid,
      required String userUUID,
      required String terminalUuid}) async {
    // if (_verifiedUser == null) {
    //   setState(() => _status = "No verified user yet");
    //   return;
    // }

    try {
      setState(() => _status = "Connecting to terminal $tid...");

      print("terminal.tid $tid terminal.uuid $terminalUuid userUUID $userUUID");

      final connectedTerminal = await _terminalSdk.connectTerminal(
        tid: tid,
        userUUID: userUUID,
        terminalUUID: terminalUuid,
      );

      print("connectedTerminal tid ${connectedTerminal.tid}");
      print("connectedTerminal terminalUUID ${connectedTerminal.terminalUUID}");
      setState(() {
        _connectedTerminal = connectedTerminal;
        _status = "Connected to TID: ${connectedTerminal.tid},}";
      });
    } catch (e) {
      setState(() => _status = "Error connecting: $e");
    }
  }

  // convert receipt to image
  Future<void> _convertReceiptToImage() async {
    try {
      var width = _imageWidthController.text.trim();
      var font = _fontSizeController.text.trim();

      var image =
          await purchaseResponse?.getLastReceipt()?.getMadaReceipt().toImage(
                receiptWidth: width.isNotEmpty ? int.parse(width) : 384,
                fontSize: font.isNotEmpty ? int.parse(font) : 12,
              );

      setState(() {
        logoBytes = image;
      });
    } catch (e) {
      print("Error converting receipt to image: $e");
    }
  }

  /// Example purchase
  Future<void> _purchase() async {
    if (!_terminalSdk.isInitialized) {
      setState(() => _status = "SDK not initialized yet");
      return;
    }

    if (_connectedTerminal == null) {
      setState(() => _status =
          "No connected terminal. Please connect to a terminal first.");
      return;
    }

    final amountText = _amountController.text.trim();
    if (amountText.isEmpty) {
      setState(() => _status = "Please enter an amount.");
      return;
    }

    final amount = int.tryParse(amountText);
    if (amount == null) {
      setState(() => _status = "Invalid amount entered.");
      return;
    }

    try {
      setState(() => _status = "Purchasing...");

      // Define the callbacks for purchase events
      transactionUuid = const Uuid().v4();
      intentId = const Uuid().v4();

      print("transactionUuid $transactionUuid");
      print("intentId $intentId");

      // var isTerminalReadyCheck = await _connectedTerminal?.isTerminalReady();
      // print("isTerminalReadyCheck: $isTerminalReadyCheck");
      // if (isTerminalReadyCheck == false) {
      //   setState(() => _status = "Terminal is not ready");
      //   return;
      // }

      await _connectedTerminal!.purchase(
        intentUUID: intentId!,
        amount: amount,
        customerReferenceNumber: intentId,
        callbacks: PurchaseCallbacks(
          cardReaderCallbacks: CardReaderCallbacks(
            onReaderDismissed: () {
              setState(() => _status = "Reader dismissed...");
              print("Reader dismissed...");
            },
            onReaderDisplayed: () {
              setState(() => _status = "Reader displayed...");
              print("Reader displayed...");
            },
            onReaderClosed: () {
              // setState(() => _status = "Reader closed...");
              print("Reader closed...");
            },
            onReadingStarted: () {
              setState(() => _status = "Reading started...");
              print("Reading started...");
            },
            onReaderWaiting: () {
              setState(() => _status = "Reader waiting...");
              print("Reader waiting...");
            },
            onReaderReading: () {
              setState(() => _status = "Reader reading...");
              print("Reader reading...");
            },
            onReaderRetry: () {
              setState(() => _status = "Reader retrying...");
              print("Reader retrying...");
            },
            onPinEntering: () {
              setState(() => _status = "Entering PIN...");
              print("Entering PIN...");
            },
            onReaderFinished: () {
              setState(() => _status = "Reader finished.");
              print("Reader finished...");
            },
            onReaderError: (message) {
              print("Reader error: $message");
              setState(() => _status = "Reader error: $message");
            },
            onCardReadSuccess: () {
              print("Card read successfully.");
              setState(() => _status = "Card read successfully.");
            },
            onCardReadFailure: (message) {
              setState(() => _status = "Card read failure: $message");
              print("Card read failure: $message");
            },
          ),
          onSendTransactionFailure: (message) {
            print("Transaction failed message: $message");
            setState(() => _status = "Transaction failed: $message");
          },
          onTransactionPurchaseCompleted: (PurchaseResponse response) async {
            print("NotDismissReaderUi");

            // _connectedTerminal?.dismissReaderUi();
            if (response.getLastTransaction() != null) {
              // _showTransactionDialog(response.getLastTransaction()!);
              purchaseResponse = response;
              print(
                  "Purchase Successful Mada receipt:  ${response.getLastReceipt()?.getBKMReceipt().toString()}");
              print(
                  "Purchase Successful isApproved:  ${response.getLastReceipt()?.getBKMReceipt().transactionUuid}");
              print(
                  "Purchase Successful installments:  ${response.getLastReceipt()?.getBKMReceipt().installmentAmount} "
                  "${response.getLastReceipt()?.getBKMReceipt().installmentsCount} ${response.getLastReceipt()?.getBKMReceipt().installmentCalculation}");
              print(
                  "actionCode : ${response.getLastReceipt()?.getBKMReceipt().replyMessage}");
              print(
                  "actionCode : ${response.getLastReceipt()?.getBKMReceipt().replyMessageExplanation}");
              print(
                  "Purchase Successful actionCode: ${response.getLastReceipt()?.getBKMReceipt().actionCode}");
              print(
                  "Purchase Successful actionCodeMessage:  ${response.getLastReceipt()?.getBKMReceipt().actionCodeMessage}");
              print(
                  "Purchase Successful isApproved:  ${response.getLastReceipt()?.getBKMReceipt().isApproved}");

              // intient id
              print("Intent ID: ${response.details?.intentId}");

              print("transaction id: ${response.getLastTransaction()?.id}");

              print(
                  "transaction orderId: ${response.getLastTransaction()!.orderId}");

              print(
                  "transaction referenceId: ${response.getLastTransaction()!.referenceId}");

              setState(() {
                intentId = response.details?.intentId;
                transactionUuid = response.getLastTransaction()!.id;
              });
              setState(() => _status =
                  "Purchase Successful! ${response.status}: ${response.getLastTransaction()!.id}  -- ${response.getLastReceipt()?.getBKMReceipt().replyMessage} ");
              setState(() {
                result.text = response.getLastReceipt()!.data.toString();
              });
            } else {
              setState(() => _status =
                  "Purchase Failed! No transaction found in response.");
            }
          },
        ),
      );
    } catch (e) {
      setState(() => _status = "Error in purchase: $e");
    }
  }

  Future<void> _purchaseWithQr() async {
    if (!_terminalSdk.isInitialized) {
      setState(() => _status = "SDK not initialized yet");
      return;
    }

    if (_connectedTerminal == null) {
      setState(() => _status =
          "No connected terminal. Please connect to a terminal first.");
      return;
    }

    final amountText = _amountController.text.trim();
    if (amountText.isEmpty) {
      setState(() => _status = "Please enter an amount.");
      return;
    }

    // final amount = int.tryParse(amountText);
    // if (amount == null) {
    //   setState(() => _status = "Invalid amount entered.");
    //   return;
    // }

    try {
      setState(() => _status = "Purchasing with qr...");

      // Define the callbacks for purchase events
      var id = const Uuid().v4();

      print("id $id");

      // var isTerminalReadyCheck = await _connectedTerminal?.isTerminalReady();
      // print("isTerminalReadyCheck: $isTerminalReadyCheck");
      // if (isTerminalReadyCheck == false) {
      //   setState(() => _status = "Terminal is not ready");
      //   return;
      // }

      await _connectedTerminal!.generateQrCodeWithUi(
        customerReferenceNumber: id,
        id: id,
        amount: amountText,
        enableUiDismiss: true,
        callbacks: PurchaseWithQrCallbacks(
          onQrUiPresented: (qrData) {
            setState(() => _status = "$_status QR UI Presented...");
            print("QR UI Presented...");
          },
          onQrPaymentApproved: (response) {
            setState(() => _status =
                "$_status QR Payment Approved! Transaction ID: ${response}");
            print("QR Payment Approved! Transaction ID: ${response}");
            _connectedTerminal?.dismissReaderUi();
          },
          onQrPaymentDeclined: (response) {
            setState(() => _status =
                "$_status QR Payment Declined! Transaction ID: ${response}");
            print("QR Payment Declined! Transaction ID: ${response}");
          },
          onQrPaymentFailure: (message) {
            setState(() => _status = "$_status QR Payment Failure: $message");
            print("QR Payment Failure: $message");
          },
          onParsingFailed: (message) {
            setState(() => _status = "$_status QR Parsing Failed: $message");
            print("QR Parsing Failed: $message");
          },
          onQrPaymentStatusCompleted: (status) {
            setState(() => _status =
                "$_status QR Payment Status Completed: \n ${status.receipt?.getBKMReceipt().isApproved}");
            print("QR Payment Status Completed: $status");
            _connectedTerminal?.dismissReaderUi();
          },
          onQrPaymentStatusExpired: (status) {
            setState(() =>
                _status = "$_status \n QR Payment Status Expired: $status");
            print("QR Payment Status Expired: $status");
            _connectedTerminal?.dismissReaderUi();
          },
          onQrPaymentStatusFailed: (status) {
            setState(() =>
                _status = "$_status \n QR Payment Status Failed: $status");
            print("QR Payment Status Failed: $status");
            _connectedTerminal?.dismissReaderUi();
          },
          onQrPaymentStatusUpdated: (status) {
            setState(() =>
                _status = "$_status \n QR Payment Status Updated: $status");
            print("QR Payment Status Updated: $status");
          },
          onQrUiClosed: () {
            setState(() => _status = "$_status QR UI Closed");
            print("QR UI Closed");
          },
        ),
      );
    } catch (e) {
      setState(() => _status = "Error in purchase: $e");
    }
  }

  /// Example purchase
  Future<void> _purchaseWithTip() async {
    if (!_terminalSdk.isInitialized) {
      setState(() => _status = "SDK not initialized yet");
      return;
    }

    if (_connectedTerminal == null) {
      setState(() => _status =
          "No connected terminal. Please connect to a terminal first.");
      return;
    }

    final amountText = _amountController.text.trim();
    if (amountText.isEmpty) {
      setState(() => _status = "Please enter an amount.");
      return;
    }

    final amount = int.tryParse(amountText);
    if (amount == null) {
      setState(() => _status = "Invalid amount entered.");
      return;
    }

    final tipAmountText = _tipAmountController.text.trim();
    if (tipAmountText.isEmpty) {
      setState(() => _status = "Please enter an tip Amount.");
      return;
    }

    final tipAmount = int.tryParse(tipAmountText);
    if (tipAmount == null) {
      setState(() => _status = "Invalid tip amount entered.");
      return;
    }

    try {
      setState(() => _status = "Purchasing...");

      // Define the callbacks for purchase events
      intentId = const Uuid().v4();

      print("intentId $intentId");

      await _connectedTerminal!.purchaseWithTip(
        intentUUID: intentId!,
        amount: amount,
        amountOther: tipAmount,
        customerReferenceNumber: intentId,
        callbacks: PurchaseCallbacks(
          cardReaderCallbacks: CardReaderCallbacks(
            onReaderDismissed: () {
              setState(() => _status = "Reader dismissed...");
              print("Reader dismissed...");
            },
            onReaderDisplayed: () {
              setState(() => _status = "Reader displayed...");
              print("Reader displayed...");
            },
            onReaderClosed: () {
              // setState(() => _status = "Reader closed...");
              print("Reader closed...");
            },
            onReadingStarted: () {
              setState(() => _status = "Reading started...");
              print("Reading started...");
            },
            onReaderWaiting: () {
              setState(() => _status = "Reader waiting...");
              print("Reader waiting...");
            },
            onReaderReading: () {
              setState(() => _status = "Reader reading...");
              print("Reader reading...");
            },
            onReaderRetry: () {
              setState(() => _status = "Reader retrying...");
              print("Reader retrying...");
            },
            onPinEntering: () {
              setState(() => _status = "Entering PIN...");
              print("Entering PIN...");
            },
            onReaderFinished: () {
              setState(() => _status = "Reader finished.");
              print("Reader finished...");
            },
            onReaderError: (message) {
              print("Reader error: $message");
              setState(() => _status = "Reader error: $message");
            },
            onCardReadSuccess: () {
              print("Card read successfully.");
              setState(() => _status = "Card read successfully.");
            },
            onCardReadFailure: (message) {
              setState(() => _status = "Card read failure: $message");
              print("Card read failure: $message");
            },
          ),
          onSendTransactionFailure: (message) {
            print("Transaction failed message: $message");
            setState(() => _status = "Transaction failed: $message");
          },
          onTransactionPurchaseCompleted: (PurchaseResponse response) async {
            print("NotDismissReaderUi");
            // _connectedTerminal?.dismissReaderUi();
            if (response.getLastTransaction() != null) {
              // _showTransactionDialog(response.getLastTransaction()!);
              purchaseResponse = response;
              print(
                  "Purchase Successful Mada receipt:  ${response.getLastReceipt()?.getBKMReceipt().toString()}");
              print(
                  "Purchase Successful isApproved:  ${response.getLastReceipt()?.getBKMReceipt().transactionUuid}");
              print(
                  "actionCode : ${response.getLastReceipt()?.getBKMReceipt().replyMessage}");
              print(
                  "actionCode : ${response.getLastReceipt()?.getBKMReceipt().replyMessageExplanation}");
              print(
                  "Purchase Successful actionCode: ${response.getLastReceipt()?.getBKMReceipt().actionCode}");
              print(
                  "Purchase Successful actionCodeMessage:  ${response.getLastReceipt()?.getBKMReceipt().actionCode}");

              // intient id
              print("Intent ID: ${response.details?.intentId}");

              print("transaction id: ${response.getLastTransaction()?.id}");

              print(
                  "transaction orderId: ${response.getLastTransaction()!.orderId}");

              print(
                  "transaction referenceId: ${response.getLastTransaction()!.referenceId}");

              setState(() {
                intentId = response.details?.intentId;
                transactionUuid = response.getLastTransaction()!.id;
              });
              setState(() => _status =
                  "Purchase Successful! ${response.status}: ${response.getLastTransaction()!.id}  -- ${response.getLastReceipt()?.getBKMReceipt().replyMessage} ");
              setState(() {
                result.text = response.getLastReceipt()!.data.toString();
              });
            } else {
              setState(() => _status =
                  "Purchase Failed! No transaction found in response.");
            }
          },
        ),
      );
    } catch (e) {
      setState(() => _status = "Error in purchase: $e");
    }
  }

  /// Example purchase
  Future<void> _installmentPurchase() async {
    if (!_terminalSdk.isInitialized) {
      setState(() => _status = "SDK not initialized yet");
      return;
    }

    if (_connectedTerminal == null) {
      setState(() => _status =
          "No connected terminal. Please connect to a terminal first.");
      return;
    }

    final amountText = _amountController.text.trim();
    if (amountText.isEmpty) {
      setState(() => _status = "Please enter an amount.");
      return;
    }

    final amount = int.tryParse(amountText);
    if (amount == null) {
      setState(() => _status = "Invalid amount entered.");
      return;
    }

    final numberOfInstallmentsText =
        _numberOfInstallmentsController.text.trim();
    if (numberOfInstallmentsText.isEmpty) {
      setState(() => _status = "Please enter an tip Amount.");
      return;
    }

    final numberOfInstallments = int.tryParse(numberOfInstallmentsText);
    if (numberOfInstallments == null) {
      setState(() => _status = "Invalid number of installments entered.");
      return;
    }

    try {
      setState(() => _status = "Purchasing installments...");

      // Define the callbacks for purchase events
      intentId = const Uuid().v4();

      print("intentId $intentId");

      await _connectedTerminal!.installments(
        intentUUID: intentId!,
        amount: amount,
        numberOfInstallments: numberOfInstallments,
        customerReferenceNumber: intentId,
        callbacks: PurchaseCallbacks(
          cardReaderCallbacks: CardReaderCallbacks(
            onReaderDismissed: () {
              setState(() => _status = "Reader dismissed...");
              print("Reader dismissed...");
            },
            onReaderDisplayed: () {
              setState(() => _status = "Reader displayed...");
              print("Reader displayed...");
            },
            onReaderClosed: () {
              // setState(() => _status = "Reader closed...");
              print("Reader closed...");
            },
            onReadingStarted: () {
              setState(() => _status = "Reading started...");
              print("Reading started...");
            },
            onReaderWaiting: () {
              setState(() => _status = "Reader waiting...");
              print("Reader waiting...");
            },
            onReaderReading: () {
              setState(() => _status = "Reader reading...");
              print("Reader reading...");
            },
            onReaderRetry: () {
              setState(() => _status = "Reader retrying...");
              print("Reader retrying...");
            },
            onPinEntering: () {
              setState(() => _status = "Entering PIN...");
              print("Entering PIN...");
            },
            onReaderFinished: () {
              setState(() => _status = "Reader finished.");
              print("Reader finished...");
            },
            onReaderError: (message) {
              print("Reader error: $message");
              setState(() => _status = "Reader error: $message");
            },
            onCardReadSuccess: () {
              print("Card read successfully.");
              setState(() => _status = "Card read successfully.");
            },
            onCardReadFailure: (message) {
              setState(() => _status = "Card read failure: $message");
              print("Card read failure: $message");
            },
          ),
          onSendTransactionFailure: (message) {
            print("Transaction failed message: $message");
            setState(() => _status = "Transaction failed: $message");
          },
          onTransactionPurchaseCompleted: (PurchaseResponse response) async {
            print("NotDismissReaderUi");
            // _connectedTerminal?.dismissReaderUi();
            if (response.getLastTransaction() != null) {
              // _showTransactionDialog(response.getLastTransaction()!);
              purchaseResponse = response;
              print(
                  "Purchase Successful Mada receipt:  ${response.getLastReceipt()?.getBKMReceipt().toString()}");
              print(
                  "Purchase Successful isApproved:  ${response.getLastReceipt()?.getBKMReceipt().transactionUuid}");
              print(
                  "Purchase Successful installments:  ${response.getLastReceipt()?.getBKMReceipt().installmentAmount} "
                  "${response.getLastReceipt()?.getBKMReceipt().installmentsCount} ${response.getLastReceipt()?.getBKMReceipt().installmentCalculation}");
              print(
                  "actionCode : ${response.getLastReceipt()?.getBKMReceipt().replyMessage}");
              print(
                  "actionCode : ${response.getLastReceipt()?.getBKMReceipt().replyMessageExplanation}");

              print(
                  "actionCode : ${response.getLastReceipt()?.getBKMReceipt().replyMessage}");
              print(
                  "actionCode : ${response.getLastReceipt()?.getBKMReceipt().replyMessageExplanation}");
              print(
                  "Purchase Successful actionCode: ${response.getLastReceipt()?.getBKMReceipt().actionCode}");
              print(
                  "Purchase Successful actionCodeMessage:  ${response.getLastReceipt()?.getBKMReceipt().actionCode}");

              // intient id
              print("Intent ID: ${response.details?.intentId}");

              print("transaction id: ${response.getLastTransaction()?.id}");

              print(
                  "transaction orderId: ${response.getLastTransaction()!.orderId}");

              print(
                  "transaction referenceId: ${response.getLastTransaction()!.referenceId}");

              setState(() {
                intentId = response.details?.intentId;
                transactionUuid = response.getLastTransaction()!.id;
              });
              setState(() => _status =
                  "Purchase Successful! ${response.status}: ${response.getLastTransaction()!.id}  -- ${response.getLastReceipt()?.getBKMReceipt().replyMessage} ");
              setState(() {
                result.text = response.getLastReceipt()!.data.toString();
              });
            } else {
              setState(() => _status =
                  "Purchase Failed! No transaction found in response.");
            }
          },
        ),
      );
    } catch (e) {
      setState(() => _status = "Error in purchase: $e");
    }
  }

  /// Example purchase
  Future<void> _purchaseVoid() async {
    if (!_terminalSdk.isInitialized) {
      setState(() => _status = "SDK not initialized yet");
      return;
    }

    if (_connectedTerminal == null) {
      setState(() => _status =
          "No connected terminal. Please connect to a terminal first.");
      return;
    }

    final amountText = _amountController.text.trim();
    if (amountText.isEmpty) {
      setState(() => _status = "Please enter an amount.");
      return;
    }

    final amount = int.tryParse(amountText);
    if (amount == null) {
      setState(() => _status = "Invalid amount entered.");
      return;
    }

    //intentId
    if (intentId == null) {
      setState(() => _status = "No intentId to void.");
      return;
    }

    try {
      setState(() => _status = "Purchasing...");

      // Define the callbacks for purchase events

      print("intentId $intentId");
      await _connectedTerminal!.purchaseVoid(
        amount: amount,
        intentUUID: intentId!,
        callbacks: PurchaseVoidCallbacks(
          cardReaderCallbacks: CardReaderCallbacks(
            onReadingStarted: () {
              setState(() => _status = "Reading started...");
            },
            onReaderWaiting: () {
              setState(() => _status = "Reader waiting...");
            },
            onReaderReading: () {
              setState(() => _status = "Reader reading...");
            },
            onReaderRetry: () {
              setState(() => _status = "Reader retrying...");
            },
            onPinEntering: () {
              setState(() => _status = "Entering PIN...");
            },
            onReaderFinished: () {
              setState(() => _status = "Reader finished.");
            },
            onReaderError: (message) {
              print("Reader error: $message");
              setState(() => _status = "Reader error: $message");
            },
            onCardReadSuccess: () {
              setState(() => _status = "Card read successfully.");
            },
            onCardReadFailure: (message) {
              setState(() => _status = "Card read failure: $message");
            },
          ),
          onSendPurchaseVoidFailure: (message) {
            setState(() => _status = "Transaction failed: $message");
          },
          onSendPurchaseVoidCompleted: (response) {
            print("response length : ${response.getLastTransaction()}");
            print(
                "Purchase Void Successful isApproved:  ${response.getLastReceipt()}");
            print(
                "Purchase Void Successful response: ${response.getLastReceipt()}");
            _showVoidTransactionDialog(response.getLastTransaction()!);
            setState(() => _status =
                "Purchase Void Successful! ${response.getLastTransaction()!.id} ${response.getLastTransaction()!.amountOther} ");
          },
        ),
      );
    } catch (e) {
      setState(() => _status = "Error in purchase Void: $e");
    }
  }

  void _showTransactionDialog(TransactionResponse response) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Transaction Successful"),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text("ID: ${response.id}"),
                Text(
                    "Is Approved: ${response.events?[0].receipt?.getBKMReceipt().isApproved}"),
                Text(
                    "Action Code: ${response.events?[0].receipt?.getBKMReceipt().actionCode}"),
                Text(
                    "Action Code Message: ${response.events?[0].receipt?.getBKMReceipt().actionCode}"),
                Text(
                    "receipt BKM: ${response.events?[0].receipt?.getBKMReceipt().merchant ?? 'N/A'}"),
                // Add more fields as needed
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text("OK"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showOpenRefundTransactionDialog(RefundResponse response) {
    var receipt = response.getLastReceipt();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Transaction Successful"),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text("ID: ${receipt?.id}"),
                Text("Is Approved: ${receipt?.getBKMReceipt().isApproved}"),
                Text("Action Code: ${receipt?.getBKMReceipt().actionCode}"),
                Text(
                    "Action Code Message: ${receipt?.getBKMReceipt().actionCode}"),
                Text(
                    "receipt BKM: ${receipt?.getBKMReceipt().merchant ?? 'N/A'}"),
                // Add more fields as needed
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text("OK"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showVoidTransactionDialog(TransactionResponseTurkey response) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Transaction Successful"),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text("ID: ${response.id}"),
                Text("Is Approved: ${response.getBKMReceipt().isApproved}"),
                Text("Action Code: ${response.getBKMReceipt().actionCode}"),
                Text(
                    "Action Code Message: ${response.getBKMReceipt().actionCodeMessage?.turkish}"),
                Text("receipt BKM: ${response.getBKMReceipt().id ?? 'N/A'}"),
                // Add more fields as needed
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text("OK"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showTransactionListDialog(IntentsListResponse response) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Transaction Successful"),
          content: SingleChildScrollView(
            child: ListBody(
              children: response.data.map((e) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Column(
                    children: [
                      Text("ID: ${e.id}"),
                      Text("Type: ${e.type}"),
                      Text("Amount: ${e.amount}"),
                      Text("Status: ${e.status}"),
                      Text("Created At: ${e.createdAt}"),
                      Text("Completed At: ${e.completedAt}"),
                      Text("Cancelled At: ${e.cancelledAt}"),
                      // show list of transactions
                      Column(
                        children: e.transactions!.map((tx) {
                          return Container(
                            margin: const EdgeInsets.only(top: 5),
                            padding: const EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.blueAccent),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Column(children: [
                              Text("  Transaction ID: ${tx.uuid}"),
                              Text("  Amount: ${tx.amountAuthorized}"),
                              Text("  Status: ${tx.isApproved}"),
                              Text("  isReversed: ${tx.isReversed}"),
                              Text(
                                  "  customerReferenceNumber: ${tx.customerReferenceNumber}")
                            ]),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text("OK"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  /// Example open refund
  Future<void> _openRefund() async {
    if (!_terminalSdk.isInitialized) {
      setState(() => _status = "SDK not initialized yet");
      return;
    }

    final amountText = _amountController.text.trim();
    if (amountText.isEmpty) {
      setState(() => _status = "Please enter an amount for refund.");
      return;
    }

    final amount = int.tryParse(amountText);
    if (amount == null) {
      setState(() => _status = "Invalid amount entered.");
      return;
    }

    var intentId = const Uuid().v4();
    try {
      setState(() => _status = "Open Refunding...");
      final result = await _connectedTerminal?.openRefund(
        intentUUID: intentId,
        amount: amount,
        callbacks: OpenRefundCallbacks(
          cardReaderCallbacks: CardReaderCallbacks(
            onReadingStarted: () {
              setState(() => _status = "Reading started...");
            },
            onReaderWaiting: () {
              setState(() => _status = "Reader waiting...");
            },
            onReaderReading: () {
              setState(() => _status = "Reader reading...");
            },
            onReaderRetry: () {
              setState(() => _status = "Reader retrying...");
            },
            onPinEntering: () {
              setState(() => _status = "Entering PIN...");
            },
            onReaderFinished: () {
              setState(() => _status = "Reader finished.");
            },
            onReaderError: (message) {
              setState(() => _status = "Reader error: $message");
            },
            onCardReadSuccess: () {
              setState(() => _status = "Card read successfully.");
            },
            onCardReadFailure: (message) {
              setState(() => _status = "Card read failure: $message");
            },
          ),
          onTransactionOpenRefundCompleted: (RefundResponse response) {
            if (response.getLastTransaction() == null) {
              setState(() => _status =
                  "Open Refund Failed! No transaction found in response.");
              return;
            }
            _showOpenRefundTransactionDialog(response);
            setState(() => _status =
                "Open Refund Successful! ${response.getLastReceipt()?.getBKMReceipt().actionCode} ${response.getLastReceipt()?.getBKMReceipt().amountAuthorized} ${response.getLastReceipt()?.getBKMReceipt().isApproved}");
          },
          onSendTransactionFailure: (message) {
            setState(() => _status = "Refund failed: $message");
          },
        ),
      );
      setState(() => _status = "Open Refund Successful: ${result.toString()}");
    } catch (e) {
      setState(() => _status = "Error in refund: $e");
    }
  }

  /// Example refund
  Future<void> _refund() async {
    if (!_terminalSdk.isInitialized) {
      setState(() => _status = "SDK not initialized yet");
      return;
    }

    // Ensure that you have a valid transactionUuid. This example uses a placeholder.
    if (intentId == null) {
      setState(() => _status = "No intentId to refund.");
      return;
    }
    final amountText = _amountController.text.trim();
    if (amountText.isEmpty) {
      setState(() => _status = "Please enter an amount for refund.");
      return;
    }

    final amount = int.tryParse(amountText);
    if (amount == null) {
      setState(() => _status = "Invalid amount entered.");
      return;
    }
    refundUuid = const Uuid().v4();

    try {
      setState(() => _status = "Refunding...");
      final result = await _connectedTerminal?.refund(
        refundUuid: refundUuid!,
        intentUUID: intentId!,
        amount: amount,
        // scheme: _selectedScheme,
        //onReaderClosed
        callbacks: RefundCallbacks(
          cardReaderCallbacks: CardReaderCallbacks(
            onReaderClosed: () {
              print("Reader closed...");
              setState(() => _status = "Reader closed...");
            },
            onReadingStarted: () {
              setState(() => _status = "Reading started...");
            },
            onReaderWaiting: () {
              setState(() => _status = "Reader waiting...");
            },
            onReaderReading: () {
              setState(() => _status = "Reader reading...");
            },
            onReaderRetry: () {
              setState(() => _status = "Reader retrying...");
            },
            onPinEntering: () {
              setState(() => _status = "Entering PIN...");
            },
            onReaderFinished: () {
              setState(() => _status = "Reader finished.");
            },
            onReaderError: (message) {
              setState(() => _status = "Reader error: $message");
            },
            onCardReadSuccess: () {
              setState(() => _status = "Card read successfully.");
            },
            onCardReadFailure: (message) {
              setState(() => _status = "Card read failure: $message");
            },
          ),
          onTransactionRefundCompleted: (RefundResponse response) {
            if (response.getLastTransaction() == null) {
              setState(() =>
                  _status = "Refund Failed! No transaction found in response.");
              return;
            }
            _showTransactionDialog(response.getLastTransaction()!);
            setState(() => _status =
                "Refund Successful! ${response.getLastReceipt()?.getBKMReceipt().actionCode} ${response.getLastReceipt()?.getBKMReceipt().amountAuthorized} ${response.getLastReceipt()?.getBKMReceipt().isApproved}");
          },
          onSendTransactionFailure: (message) {
            setState(() => _status = "Refund failed: $message");
          },
        ),
      );
      setState(() => _status = "Refund Successful: ${result.toString()}");
    } catch (e) {
      setState(() => _status = "Error in refund: $e");
    }
  }

  /// Example refund
  Future<void> _refundVoid() async {
    if (!_terminalSdk.isInitialized) {
      setState(() => _status = "SDK not initialized yet");
      return;
    }

    final amountText = _amountController.text.trim();
    if (amountText.isEmpty) {
      setState(() => _status = "Please enter an amount for refund.");
      return;
    }

    final amount = int.tryParse(amountText);
    if (amount == null) {
      setState(() => _status = "Invalid amount entered.");
      return;
    }

    if (intentId == null) {
      setState(() => _status = "No intentId to refund.");
      return;
    }

    // if (refundUuid == null) {
    //   setState(() => _status = "No refundUuid to refund.");
    //   return;
    // }
    try {
      setState(() => _status = "Refunding...");
      final result = await _connectedTerminal?.refundVoid(
        intentUUID: intentId!,
        amount: amount,
        scheme: _selectedScheme,
        callbacks: RefundVoidCallbacks(
          cardReaderCallbacks: CardReaderCallbacks(
            onReadingStarted: () {
              setState(() => _status = "Reading started...");
            },
            onReaderWaiting: () {
              setState(() => _status = "Reader waiting...");
            },
            onReaderReading: () {
              setState(() => _status = "Reader reading...");
            },
            onReaderRetry: () {
              setState(() => _status = "Reader retrying...");
            },
            onPinEntering: () {
              setState(() => _status = "Entering PIN...");
            },
            onReaderFinished: () {
              setState(() => _status = "Reader finished.");
            },
            onReaderError: (message) {
              setState(() => _status = "Reader error: $message");
            },
            onCardReadSuccess: () {
              setState(() => _status = "Card read successfully.");
            },
            onCardReadFailure: (message) {
              setState(() => _status = "Card read failure: $message");
            },
          ),
          onRefundVoidCompleted: (response) {
            print("response length : ${response.getLastTransaction()}");
            setState(() => _status =
                "Refund Void Successful! ${response.getLastTransaction()!.id} ${response.getLastTransaction()!.amountOther} ");
          },
          onRefundVoidFailure: (message) {
            setState(() => _status = "Refund failed: $message");
          },
        ),
      );
      setState(() => _status = "Refund Successful: ${result.toString()}");
    } catch (e) {
      setState(() => _status = "Error in refund: $e");
    }
  }

  /// Example getTransactionDetails
  Future<void> _getTransactionDetails() async {
    if (!_terminalSdk.isInitialized) {
      setState(() => _status = "SDK not initialized yet");
      return;
    }

    // Ensure that you have a valid transactionUuid. This example uses a placeholder.
    if (transactionUuid == null) {
      setState(() => _status = "No transaction to get details.");
      return;
    }

    try {
      setState(() => _status = "GetTransaction...");
      final result = await _connectedTerminal?.getIntent(
        intentUUID: intentId!,
      );

      setState(() =>
          _status = "GetTransaction Successful: ${result?.transactions[0].id}");
    } catch (e) {
      setState(() => _status = "Error in getTransaction: $e");
    }
  }

  /// Example get Transaction List
  Future<void> _getTransactionList() async {
    if (!_terminalSdk.isInitialized) {
      setState(() => _status = "SDK not initialized yet");
      return;
    }

    try {
      setState(() => _status = "GetTransactionList...");
      final result = await _connectedTerminal?.getIntentList(
        page: 1,
        pageSize: 10,
        // startDate: "2025-09-27 18:00:00.000",
        // endDate: "2025-10-04 18:00:00.000",
      );
      _showTransactionListDialog(result!);

      setState(() => _status = "GetTransactions Successful: $result");
    } catch (e) {
      setState(() => _status = "Error in getTransactions: $e");
    }
  }

  /// get Reconciliation list
  Future<void> _getReconciliationList() async {
    if (!_terminalSdk.isInitialized) {
      setState(() => _status = "SDK not initialized yet");
      return;
    }

    try {
      setState(() => _status = "GetReconciliationList...");
      final result = await _connectedTerminal?.getReconciliationList(
        page: 1,
        pageSize: 10,
        // startDate: 1756592281,
        // endDate: 1756801135,
      );
      setState(() =>
          _status = "GetReconciliation Successful: ${result?.data[0].id}");
    } catch (e) {
      setState(() => _status = "Error in getReconciliation: $e");
    }
  }

  /// get Reconcile details
  Future<void> _getReconcileDetails() async {
    if (!_terminalSdk.isInitialized) {
      setState(() => _status = "SDK not initialized yet");
      return;
    }

    if (reconcileId == null) {
      setState(() => _status = "No reconcileId to get details.");
      return;
    }

    try {
      setState(() => _status = "GetReconciliation...");
      final result =
          await _connectedTerminal?.getReconciliation(uuid: reconcileId ?? "");
      setState(() => _status = "GetReconciliation Successful: ${result?.id}");
    } catch (e) {
      setState(() => _status = "Error in GetReconciliation: $e");
    }
  }

  /// reconcile
  Future<void> _reconcile() async {
    if (!_terminalSdk.isInitialized) {
      setState(() => _status = "SDK not initialized yet");
      return;
    }

    try {
      setState(() => _status = "Reconcile...");
      final result = await _connectedTerminal?.reconcile();
      reconcileId = result?.receipt?.reconciliation.id;
      setState(() => _status = "Reconcile Successful: ${result.toString()}");
    } catch (e) {
      setState(() => _status = "Error in Reconcile: $e");
    }
  }

  /// Builds a list view of available terminals
  Widget _buildTerminalsList() {
    if (_terminals.isEmpty) {
      return const Text("No terminals fetched yet.");
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(), // Prevent inner scrolling
      itemCount: _terminals.length,
      itemBuilder: (context, index) {
        final terminal = _terminals[index];
        return Card(
          child: ListTile(
            title: Text(terminal.name ?? "Unnamed Terminal"),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("TID: ${terminal.tid}"),
                Text("UUID: ${terminal.uuid}"),
                Text("Merchant UUID: ${terminal.merchant.toString()}"),
                Text("client: ${terminal.client}"),
                Text("user uuid: ${terminal.userUUID}"),
              ],
            ),
            onTap: () => _connectToTerminal(terminal),
          ),
        );
      },
    );
  }

  /// Builds a list view of available terminals
  Widget _buildUserList() {
    if (_users.isEmpty) {
      return const Text("No users fetched yet.");
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(), // Prevent inner scrolling
      itemCount: _users.length,
      itemBuilder: (context, index) {
        final user = _users[index];
        return Card(
          child: ListTile(
            title: Text(user.name ?? "Unnamed Terminal"),
            subtitle: Text("mail: ${user.email} \n mobile: ${user.mobile}"),
            onTap: () {
              print("user.uuid ${user.userUUID}");
              setState(() {
                _verifiedUser = user;
              });
            },
          ),
        );
      },
    );
  }

  /// Example purchase
  Future<void> _authorize() async {
    if (!_terminalSdk.isInitialized) {
      setState(() => _status = "SDK not initialized yet");
      return;
    }

    if (_connectedTerminal == null) {
      setState(() => _status =
          "No connected terminal. Please connect to a terminal first.");
      return;
    }

    final amountText = _amountController.text.trim();
    if (amountText.isEmpty) {
      setState(() => _status = "Please enter an amount.");
      return;
    }
// amount is long
    final amount = int.tryParse(amountText);
    if (amount == null) {
      setState(() => _status = "Invalid amount entered.");
      return;
    }

    try {
      setState(() => _status = "Authorization...");

      // Define the callbacks for purchase events
      transactionUuid = const Uuid().v4();

      // var isTerminalReadyCheck = await _connectedTerminal?.isTerminalReady();
      // print("isTerminalReadyCheck: $isTerminalReadyCheck");
      // if (isTerminalReadyCheck == false) {
      //   setState(() => _status = "Terminal is not ready");
      //   return;
      // }

      await _connectedTerminal!.authorize(
        uuid: transactionUuid!,
        amount: amount,
        customerReferenceNumber: "Me2025-customerReferenceNumber",
        callbacks: AuthorizedCallbacks(
          cardReaderCallbacks: CardReaderCallbacks(
            onReaderDisplayed: () {
              setState(() => _status = "Reader displayed...");
              print("Reader displayed...");
            },
            onReaderClosed: () {
              // setState(() => _status = "Reader closed...");
              print("Reader closed...");
            },
            onReadingStarted: () {
              setState(() => _status = "Reading started...");
            },
            onReaderWaiting: () {
              setState(() => _status = "Reader waiting...");
            },
            onReaderReading: () {
              setState(() => _status = "Reader reading...");
            },
            onReaderRetry: () {
              setState(() => _status = "Reader retrying...");
            },
            onPinEntering: () {
              setState(() => _status = "Entering PIN...");
            },
            onReaderFinished: () {
              setState(() => _status = "Reader finished.");
            },
            onReaderError: (message) {
              print("Reader error: $message");
              setState(() => _status = "Reader error: $message");
            },
            onCardReadSuccess: () {
              setState(() => _status = "Card read successfully.");
            },
            onCardReadFailure: (message) {
              setState(() => _status = "Card read failure: $message");
            },
          ),
          onSendTransactionFailure: (message) {
            setState(() => _status = "Transaction failed: $message");
          },
          onSendAuthorizedCompleted: (AuthorizeResponse response) {
            setState(() {
              authIntentId = response.details?.intentId;
            });
            print(
                "Authorize Successful isApproved:  ${response.getLastReceipt()?.getBKMReceipt().isApproved}");
            print(
                "Authorize Successful Mada receipt:  ${response.getLastReceipt()?.getBKMReceipt().toString()}");

            setState(() => _status =
                "Authorize Successful! ${response.getLastTransaction()!.id} ${response.getLastTransaction()!.amountOther} ");
          },
        ),
      );
    } catch (e) {
      print("Error in authorize: $e");
      setState(() => _status = "Error in purchase: $e");
    }
  }

  //tipTransaction
  Future<void> _tipTransaction() async {
    if (!_terminalSdk.isInitialized) {
      setState(() => _status = "SDK not initialized yet");
      return;
    }

    if (_connectedTerminal == null) {
      setState(() => _status =
          "No connected terminal. Please connect to a terminal first.");
      return;
    }

    final amountText = _amountController.text.trim();
    if (amountText.isEmpty) {
      setState(() => _status = "Please enter an amount.");
      return;
    }

    final amount = int.tryParse(amountText);
    if (amount == null) {
      setState(() => _status = "Invalid amount entered.");
      return;
    }

    //intentId
    if (intentId == null) {
      setState(() => _status = "No intentId to tip.");
      return;
    }

    try {
      setState(() => _status = "Tip Transaction...");

      final tipResponse = await _connectedTerminal!.tipTransaction(
        amount: amount,
        id: intentId!,
      );

      setState(() => _status =
          "Tip Transaction Successful ${tipResponse.getLastTransaction()?.id}");
    } catch (e) {
      setState(() => _status = "Error in Tip Transaction: $e");
    }
  }

  @override
  void dispose() {
    // _terminalSdk.dispose();
    _connectedTerminal?.dispose();
    _mobileController.dispose();
    _emailController.dispose();
    _otpController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  // Future<void> _launchUrl(url) async {
  //   if (!await launchUrl(url)) {
  //     throw Exception('Could not launch $url');
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Flutter Terminal SDK Example"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (logoBytes != null)
                Image.memory(
                  logoBytes!,
                  height: 400,
                  fit: BoxFit.contain,
                  gaplessPlayback: true, // <- prevents flicker when bytes swap
                ),
              // Usage example in a build method:
              ScrollableSizedText(
                text: _status,
                fontSize: 18,
                height: 200,
                // fixed height -> enables scrolling when content overflows
                width: double.infinity,
                // optional
                selectable: true, // optional
              ),
              const SizedBox(height: 20),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // const SizedBox(height: 20),
                      // ElevatedButton(
                      //   onPressed: () async {
                      //     await loadTerminalFromPrefs();
                      //   },
                      //   child: const Text("loadTerminalFromPrefs"),
                      // ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () async {
                          print("Initializing SDK start");
                          await _initializeSdk();
                          print("Initializing SDK end");
                        },
                        child: const Text("Initialize SDK"),
                      ),
                      const SizedBox(height: 20),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton(
                              onPressed: _requestPermissions,
                              child: const Text("Check Permission"),
                            ),
                            const SizedBox(width: 5),
                            ElevatedButton(
                              onPressed: _checkNfc,
                              child: const Text("Check NFC"),
                            ),
                            const SizedBox(width: 5),
                            ElevatedButton(
                              onPressed: _checkWifi,
                              child: const Text("Check WIFI"),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),
                      TextField(
                        controller: _mobileController,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(
                          labelText: "Mobile Number",
                          hintText: "+966xxxxxxxxx",
                        ),
                      ),
                      ElevatedButton(
                        onPressed: _sendMobileOtp,
                        child: const Text("Send Mobile OTP"),
                      ),
                      TextField(
                        controller: _emailController,
                        decoration: const InputDecoration(
                          labelText: "Email Address",
                          hintText: "email@x.com",
                        ),
                      ),
                      ElevatedButton(
                        onPressed: _sendEmailOtp,
                        child: const Text("Send Email OTP"),
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: _otpController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: "OTP Code",
                          hintText: "1234",
                        ),
                      ),
                      ElevatedButton(
                        onPressed: _verifyMobileOtp,
                        child: const Text("Verify Mobile OTP"),
                      ),
                      ElevatedButton(
                        onPressed: _verifyEmailOtp,
                        child: const Text("Verify Email OTP"),
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: _jwtController,
                        decoration: const InputDecoration(
                          labelText: "jwt",
                          hintText: "342FDSF234WEFSADF",
                        ),
                      ),
                      ElevatedButton(
                        onPressed: _verifyJWT,
                        child: const Text("Verify JWT"),
                      ),
                      ElevatedButton(
                        onPressed: _getTerminal,
                        child: const Text("Get Terminal by TID"),
                      ),
                      ElevatedButton(
                        onPressed: _getPendingTotal,
                        child: const Text("get Pending Total"),
                      ),
                      ElevatedButton(
                        onPressed: _getTerminalConfig,
                        child: const Text("get Terminal Config"),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          _connectToTerminal2(
                              tid: '1266Z259',
                              userUUID: 'b2f5cc34-d593-4a17-9131-1ff9659262c2',
                              terminalUuid:
                                  '976b3f37-2013-413e-a79a-c16a65ca5858');
                        },
                        child: const Text("connect To Specific Terminal"),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _getUsers,
                        child: const Text("Get Users"),
                      ),
                      const SizedBox(height: 20),
                      _buildUserList(),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _logout,
                        child: const Text("logout"),
                      ),
                      const SizedBox(height: 20),
                      // Only show "Get Terminals" if we have a verified user
                      if (_verifiedUser != null) ...[
                        ElevatedButton(
                          onPressed: _getUser,
                          child: const Text("Get User"),
                        ),
                        ElevatedButton(
                          onPressed: _logout,
                          child: const Text("logout"),
                        ),
                        ElevatedButton(
                          onPressed: _getTerminals,
                          child: const Text("Get Terminals"),
                        ),
                        const SizedBox(height: 20),
                        // Display the terminals list
                        _buildTerminalsList(),
                        const SizedBox(height: 20),
                        isConnected == true
                            ? Column(
                                children: [
                                  ElevatedButton(
                                    onPressed: () {
                                      _authorize();
                                    },
                                    child: const Text("Authorize"),
                                  ),
                                  authIntentId != null
                                      ? ElevatedButton(
                                          onPressed: () async {
                                            if (_connectedTerminal != null) {
                                              try {
                                                var voidInfo =
                                                    await _connectedTerminal!
                                                        .voidAuthorization(
                                                            uuid:
                                                                authIntentId ??
                                                                    "");
                                                print(
                                                    "voidAuthorization: ${voidInfo.toString()}");
                                                setState(() => _status =
                                                    "authorizeVoid Successful: ${voidInfo.getLastReceipt()?.getBKMReceipt().transactionUuid}");
                                              } catch (e) {
                                                setState(() => _status =
                                                    "Error in authorizeVoid: $e");
                                              }
                                            }
                                          },
                                          child: Text(
                                              "voidAuthorization ${_connectedTerminal?.tid}"))
                                      : const SizedBox(),
                                  authIntentId != null
                                      ? ElevatedButton(
                                          onPressed: () async {
                                            if (_connectedTerminal != null) {
                                              var info =
                                                  await _connectedTerminal!
                                                      .incrementAuthorization(
                                                uuid: const Uuid().v4(),
                                                authorizationUuid:
                                                    authIntentId ?? "",
                                                amount: 2000,
                                              );

                                              print(
                                                  "incrementAuthorization: ${info.toString()}");
                                              setState(() => _status =
                                                  "incrementAuthorization Successful: ${info.getLastReceipt()?.getBKMReceipt().transactionUuid}");
                                            }
                                          },
                                          child: Text(
                                              "incrementAuthorization ${_connectedTerminal?.tid}"),
                                        )
                                      : const SizedBox(),
                                  authIntentId != null
                                      ? Column(
                                          children: [
                                            ElevatedButton(
                                                onPressed: () async {
                                                  if (_connectedTerminal !=
                                                      null) {
                                                    var response =
                                                        await _connectedTerminal!
                                                            .captureAuthorization(
                                                      authorizationUuid:
                                                          authIntentId ?? "",
                                                      amount: 3000,
                                                      uuid: const Uuid().v4(),
                                                    );

                                                    print(
                                                        "captureAuthorization: ${response.toString()}");
                                                    setState(() => _status =
                                                        "captureAuthorization Successful: ${response.getLastReceipt()?.getBKMReceipt().transactionUuid}");
                                                  }
                                                },
                                                child: Text(
                                                    "captureAuthorization ${_connectedTerminal?.tid}")),
                                            const SizedBox(height: 10),
                                            ElevatedButton(
                                                onPressed: () async {
                                                  if (_connectedTerminal !=
                                                      null) {
                                                    await _connectedTerminal!
                                                        .captureAuthorizationWithTap(
                                                      authorizationUuid:
                                                          authIntentId ?? "",
                                                      amount: 3000,
                                                      uuid: const Uuid().v4(),
                                                      callbacks:
                                                          CaptureAuthorizationWithTapCallbacks(
                                                        cardReaderCallbacks:
                                                            CardReaderCallbacks(
                                                          onReaderDisplayed:
                                                              () {
                                                            setState(() => _status =
                                                                "Reader displayed...");
                                                            print(
                                                                "Reader displayed...");
                                                          },
                                                          onReaderClosed: () {
                                                            // setState(() => _status = "Reader closed...");
                                                            print(
                                                                "Reader closed...");
                                                          },
                                                          onReadingStarted: () {
                                                            setState(() => _status =
                                                                "Reading started...");
                                                          },
                                                          onReaderWaiting: () {
                                                            setState(() => _status =
                                                                "Reader waiting...");
                                                          },
                                                          onReaderReading: () {
                                                            setState(() => _status =
                                                                "Reader reading...");
                                                          },
                                                          onReaderRetry: () {
                                                            setState(() => _status =
                                                                "Reader retrying...");
                                                          },
                                                          onPinEntering: () {
                                                            setState(() => _status =
                                                                "Entering PIN...");
                                                          },
                                                          onReaderFinished: () {
                                                            setState(() => _status =
                                                                "Reader finished.");
                                                          },
                                                          onReaderError:
                                                              (message) {
                                                            print(
                                                                "Reader error: $message");
                                                            setState(() => _status =
                                                                "Reader error: $message");
                                                          },
                                                          onCardReadSuccess:
                                                              () {
                                                            setState(() => _status =
                                                                "Card read successfully.");
                                                          },
                                                          onCardReadFailure:
                                                              (message) {
                                                            setState(() => _status =
                                                                "Card read failure: $message");
                                                          },
                                                        ),
                                                        onAuthorizedResponseWithTapCompleted:
                                                            (response) {
                                                          print(
                                                              "Transaction Completed: $response");
                                                          setState(() => _status =
                                                              "captureAuthorizationWithTap Successful: ${response.getLastReceipt()?.getBKMReceipt().transactionUuid}");
                                                        },
                                                        onSendTransactionFailure:
                                                            (message) {
                                                          print(
                                                              "Transaction Failed: $message");
                                                          setState(() => _status =
                                                              "captureAuthorizationWithTap Failed: $message");
                                                        },
                                                      ),
                                                    );
                                                  }
                                                },
                                                child: Text(
                                                    "captureAuthorizationWithTap ${_connectedTerminal?.tid}")),
                                          ],
                                        )
                                      : const SizedBox(),
                                ],
                              )
                            : const Text("Not connected to any terminal"),
                        const SizedBox(height: 20),
                        //  tipTransaction
                        ElevatedButton(
                          onPressed: _tipTransaction,
                          child: const Text("Tip Transaction"),
                        ),
                      ],

                      // Purchase inputs
                      TextField(
                        controller: _amountController,
                        keyboardType: TextInputType.number, // Correct placement
                        decoration: const InputDecoration(
                          labelText: "Amount",
                          hintText: "5000",
                        ),
                      ),
                      const SizedBox(height: 10),
                      // Purchase inputs
                      TextField(
                        controller: _tipAmountController,
                        keyboardType: TextInputType.number, // Correct placement
                        decoration: const InputDecoration(
                          labelText: "Tip Amount",
                          hintText: "5000",
                        ),
                      ),
                      const SizedBox(height: 10), // Purchase inputs
                      TextField(
                        controller: _numberOfInstallmentsController,
                        keyboardType: TextInputType.number, // Correct placement
                        decoration: const InputDecoration(
                          labelText: "Number of Installments",
                          hintText: "4",
                        ),
                      ),
                      const SizedBox(height: 10),
                      DropdownButtonFormField<PaymentScheme>(
                        decoration: const InputDecoration(
                          labelText: "Payment Scheme",
                        ),
                        value: _selectedScheme,
                        items: PaymentScheme.values.map((PaymentScheme value) {
                          return DropdownMenuItem<PaymentScheme>(
                            value: value,
                            child: Text(value.name),
                          );
                        }).toList(),
                        onChanged: (newValue) {
                          setState(() {
                            _selectedScheme = newValue!;
                          });
                        },
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _purchase,
                        child: const Text("Purchase"),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _purchaseWithQr,
                        child: const Text("PurchaseWithQr"),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          _connectedTerminal?.dismissReaderUi();
                        },
                        child: const Text("Dismiss Reader UI"),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _purchaseWithTip,
                        child: const Text("PurchaseWithTip"),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _installmentPurchase,
                        child: const Text("installment Purchase"),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _imageWidthController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: "Image Width",
                                hintText: "600",
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              controller: _fontSizeController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: "Font Size",
                                hintText: "12",
                              ),
                            ),
                          ),
                        ],
                      ),
                      ElevatedButton(
                        onPressed: _convertReceiptToImage,
                        child: const Text("convert receipt to image"),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _purchaseVoid,
                        child: const Text("PurchaseVoid"),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _refund,
                        child: const Text("Refund"),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _openRefund,
                        child: const Text("OpenRefund"),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _refundVoid,
                        child: const Text("RefundVoid"),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _reverse,
                        child: const Text("Reverse"),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _getTransactionDetails,
                        child: const Text("Get Transaction Details"),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _getTransactionList,
                        child: const Text("Get Transaction List"),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _getReconciliationList,
                        child: const Text("Get Reconciliation List"),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _getReconcileDetails,
                        child: const Text("Get Reconciliation Details"),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _reconcile,
                        child: const Text("Reconcile"),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void saveTerminalToPrefs(TerminalModel terminalModel) {
    // Save terminal details to SharedPreferences
    _prefs.setString('terminal_uuid', terminalModel.terminalUUID ?? "");
    _prefs.setString('terminal_tid', terminalModel.tid ?? "");
    _prefs.setString('terminal_name', terminalModel.name ?? '');
  }
}
