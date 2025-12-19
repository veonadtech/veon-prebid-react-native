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
  
  s.pod_target_xcconfig = {
    'DEFINES_MODULE' => 'YES',
    'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386'
  }
end
