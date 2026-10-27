#
# Flutter Terminal SDK iOS podspec — mirrors nearpay-rn-terminal-sdk integration.
#
Pod::Spec.new do |s|
  base_xcconfig = {
    "BUILD_LIBRARY_FOR_DISTRIBUTION" => "YES"
  }

  s.name             = "flutter_terminal_sdk"
  s.version          = "0.2.6"
  s.summary          = "Nearpay Terminal SDK Flutter plugin"
  s.description      = <<-DESC
Flutter plugin for Nearpay Terminal SDK on iOS and Android.
                       DESC
  s.homepage         = "https://gitlab.com/nearcorp/flutter-terminal-sdk"
  s.license          = { :file => "../LICENSE" }
  s.author           = { "Nearpay" => "support@nearpay.io" }
  s.source           = { :path => "." }
  s.source_files     = "Classes/**/*"
  s.preserve_paths   = "Frameworks/TerminalSDK.xcframework"
  s.vendored_frameworks = "Frameworks/TerminalSDK.xcframework"
  s.platform         = :ios, "15.5"
  s.swift_version    = "5.0"
  s.dependency "Flutter"
  s.dependency "DeviceKit", "5.6.0"

  slice_dir = "$(PODS_TARGET_SRCROOT)/Frameworks/TerminalSDK.xcframework/ios-arm64"
  unified_headers = "#{slice_dir}/TerminalSDK.framework/Headers"
  unified_xcconfig = {
    "FRAMEWORK_SEARCH_PATHS" => "$(inherited) \"#{slice_dir}\"",
    "HEADER_SEARCH_PATHS" => "$(inherited) \"#{unified_headers}\"",
    "OTHER_SWIFT_FLAGS" => "$(inherited) -F\"#{slice_dir}\"",
    "OTHER_LDFLAGS" => "$(inherited) -framework \"TerminalSDK\" -lc++",
    "DEFINES_MODULE" => "YES",
    "EXCLUDED_ARCHS[sdk=iphonesimulator*]" => "i386"
  }

  s.pod_target_xcconfig = base_xcconfig.merge(unified_xcconfig)
  s.user_target_xcconfig = {
    "LD_RUNPATH_SEARCH_PATHS" => "$(inherited) @executable_path/Frameworks",
    "OTHER_LDFLAGS" => "$(inherited) -framework \"TerminalSDK\" -lc++"
  }
end
