require "json"

package = JSON.parse(File.read(File.join(__dir__, "package.json")))

Pod::Spec.new do |s|
  s.name         = "VeonPrebidReactNative"
  s.version      = package["version"]
  s.summary      = package["description"]
  s.description  = <<-DESC
                  React Native bridge for Veon Prebid SDK
                   DESC
  s.homepage     = "https://github.com/veonadtech/veon-prebid-react-native"
  s.license      = "MIT"
  s.authors      = { "Veon" => "info@veon.com" }
  s.platforms    = { :ios => "12.0" }
  s.source       = { :git => "https://github.com/veonadtech/veon-prebid-react-native.git", :tag => "#{s.version}" }

  s.source_files = "ios/**/*.{h,m,mm,swift}"

  # Install all dependencies
  s.dependency "React-Core"

  # Fabric (New Architecture) dependencies
  install_modules_dependencies(s)
  s.dependency "Google-Mobile-Ads-SDK", "12.3.0"
  s.dependency "VeonPrebidMobileGAMEventHandlers", "0.0.4"
  s.dependency "VeonPrebidMobile", "0.0.4"
  
  s.static_framework = true
  s.swift_version = "5.0"
  
  # When consumer uses `use_frameworks!`, headers are inside .framework bundles
  # and need explicit search paths for React Native internal C++ headers
  if ENV['USE_FRAMEWORKS']
    s.pod_target_xcconfig = {
      'DEFINES_MODULE' => 'YES',
      'SWIFT_OBJC_INTERFACE_HEADER_NAME' => 'VeonPrebidReactNative-Swift.h',
      'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386',
      'HEADER_SEARCH_PATHS' => [
        '"$(PODS_CONFIGURATION_BUILD_DIR)/React-utils/React_utils.framework/Headers"',
        '"$(PODS_CONFIGURATION_BUILD_DIR)/React-debug/React_debug.framework/Headers"',
        '"$(PODS_CONFIGURATION_BUILD_DIR)/React-featureflags/React_featureflags.framework/Headers"',
        '"$(PODS_CONFIGURATION_BUILD_DIR)/React-rendererdebug/React_rendererdebug.framework/Headers"',
        '"$(PODS_CONFIGURATION_BUILD_DIR)/React-Fabric/React_Fabric.framework/Headers"',
        '"$(PODS_CONFIGURATION_BUILD_DIR)/React-FabricComponents/React_FabricComponents.framework/Headers"',
        '"$(PODS_CONFIGURATION_BUILD_DIR)/React-graphics/React_graphics.framework/Headers"',
        '"$(PODS_CONFIGURATION_BUILD_DIR)/React-graphics/React_graphics.framework/Headers/react/renderer/graphics/platform/ios"',
        '"$(PODS_CONFIGURATION_BUILD_DIR)/ReactCommon/ReactCommon.framework/Headers/react/nativemodule/core"',
        '"$(PODS_CONFIGURATION_BUILD_DIR)/ReactCommon/ReactCommon.framework/Headers/react/nativemodule/core/platform/ios"',
        '"$(PODS_ROOT)/DoubleConversion"',
        '"$(PODS_ROOT)/RCT-Folly"',
      ].join(' ')
    }
  else
    s.pod_target_xcconfig = {
      'DEFINES_MODULE' => 'YES',
      'SWIFT_OBJC_INTERFACE_HEADER_NAME' => 'VeonPrebidReactNative-Swift.h',
      'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386',
    }
  end
end
