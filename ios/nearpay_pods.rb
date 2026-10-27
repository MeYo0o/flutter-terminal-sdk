# Shared CocoaPods post_install hooks for Nearpay Terminal SDK consumers.
# Usage in your app Podfile (inside post_install):
#   nearpay_sdk_root = File.expand_path('../node_modules/nearpay-rn-terminal-sdk/ios', __dir__)
#   require File.join(nearpay_sdk_root, 'nearpay_pods')
#   NearpayPods.apply_post_install(installer)

module NearpayPods
  module_function

  MIN_IOS = '15.5'

  def apply_post_install(installer)
    apply_min_deployment_target(installer)
    apply_non_modular_include_workaround(installer)
    apply_fmt_header_paths(installer)
  end

  # Xcode 27 rejects pod targets below iOS 15.0 (e.g. DeviceKit at 13.0).
  def apply_min_deployment_target(installer)
    installer.pods_project.targets.each do |target|
      target.build_configurations.each do |config|
        current = config.build_settings['IPHONEOS_DEPLOYMENT_TARGET']
        next if current && Gem::Version.new(current) >= Gem::Version.new(MIN_IOS)
        config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = MIN_IOS
      end
    end
  end

  # NOTE: TerminalSDK.xcframework is now a single merged binary (the Nearpay
  # dependency modules are folded into TerminalSDK's Mach-O via Mergeable
  # Libraries). There are no nested dependency frameworks to re-sign, so the
  # previous "[Nearpay] Sign Nested Frameworks" build phase is no longer needed.

  def apply_non_modular_include_workaround(installer)
    keys = {
      'CLANG_ALLOW_NON_MODULAR_INCLUDES_IN_FRAMEWORK_MODULES' => 'YES',
      'CLANG_WARN_NON_MODULAR_INCLUDE_IN_FRAMEWORK_MODULE' => 'NO',
    }

    installer.pods_project.targets.each do |target|
      target.build_configurations.each do |config|
        keys.each { |k, v| config.build_settings[k] = v }
      end
    end

    installer.aggregate_targets.each do |aggregate_target|
      aggregate_target.user_project.native_targets.each do |native_target|
        native_target.build_configurations.each do |config|
          keys.each { |k, v| config.build_settings[k] = v }
        end
      end
    end
  end

  def apply_fmt_header_paths(installer)
    installer.pods_project.targets.each do |target|
      next unless ['RCT-Folly', 'fmt', 'ReactCodegen'].include?(target.name)

      target.build_configurations.each do |config|
        header_search_paths = config.build_settings['HEADER_SEARCH_PATHS'] || '$(inherited)'
        header_search_paths = header_search_paths.join(' ') if header_search_paths.is_a?(Array)
        unless header_search_paths.include?('$(PODS_ROOT)/fmt/include')
          header_search_paths = "#{header_search_paths} $(PODS_ROOT)/fmt/include"
        end
        config.build_settings['HEADER_SEARCH_PATHS'] = header_search_paths
      end
    end
  end

  def apply_unified_force_load(installer)
    force_load = '-force_load $(PODS_XCFRAMEWORKS_BUILD_DIR)/nearpay-rn-terminal-sdk/TerminalSDK.framework/TerminalSDK'

    installer.aggregate_targets.each do |aggregate_target|
      aggregate_target.xcconfigs.each do |_config_name, xcconfig|
        flags = xcconfig.attributes['OTHER_LDFLAGS'] || '$(inherited)'
        next if flags.include?('nearpay-rn-terminal-sdk/TerminalSDK.framework/TerminalSDK')

        xcconfig.attributes['OTHER_LDFLAGS'] = "#{flags} #{force_load} -lc++"
      end
    end
  end
end
