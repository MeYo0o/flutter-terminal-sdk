import Flutter
import UIKit

public class FlutterTerminalSdkPlugin: NSObject, FlutterPlugin {
  private let channel: FlutterMethodChannel
  private let bridge: NearpayFlutterBridge

  init(channel: FlutterMethodChannel, bridge: NearpayFlutterBridge) {
    self.channel = channel
    self.bridge = bridge
  }

  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(
      name: "nearpay_plugin",
      binaryMessenger: registrar.messenger()
    )
    let bridge = NearpayFlutterBridge(methodChannel: channel)
    let instance = FlutterTerminalSdkPlugin(channel: channel, bridge: bridge)
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    let args = normalizeArguments(call.arguments)

    switch call.method {
    case "initialize":
      bridge.initialize(args, resolver: result, rejecter: result)
    case "getVersion":
      result("unsupported")
    default:
      bridge.executeOperation(call.method, args: args, resolver: result, rejecter: result)
    }
  }

  private func normalizeArguments(_ arguments: Any?) -> NSDictionary {
    guard let dictionary = arguments as? [String: Any] else {
      return NSDictionary()
    }
    return NSDictionary(dictionary: dictionary)
  }
}
