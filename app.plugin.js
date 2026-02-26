const { withDangerousMod, withPlugins } = require('@expo/config-plugins');
const fs = require('fs');
const path = require('path');

/**
 * Expo config plugin for setupad-prebid-react-native
 *
 * Automatically configures the consumer's iOS Podfile with:
 * - Explicit VeonPrebid pod dependencies
 * - post_install hooks for DEFINES_MODULE and Swift module resolution
 */
function withVeonPrebidIOS(config) {
  return withDangerousMod(config, [
    'ios',
    async (cfg) => {
      const podfilePath = path.join(cfg.modRequest.platformProjectRoot, 'Podfile');

      if (!fs.existsSync(podfilePath)) {
        return cfg;
      }

      let podfile = fs.readFileSync(podfilePath, 'utf8');

      // Add explicit Veon Prebid pod dependencies if not already present
      if (!podfile.includes("pod 'VeonPrebidMobile'")) {
        podfile = podfile.replace(
          /use_react_native!\(/,
          `# Veon Prebid Dependencies\n  pod 'Google-Mobile-Ads-SDK', '12.3.0'\n  pod 'VeonPrebidMobile', '0.0.4'\n  pod 'VeonPrebidMobileGAMEventHandlers', '0.0.4'\n\n  use_react_native!(`
        );
      }

      // Add post_install hook for VeonPrebid module fixes
      if (!podfile.includes('VeonPrebidMobile Swift module')) {
        const postInstallHook = `
    # Fix for VeonPrebidMobile Swift module resolution
    installer.pods_project.targets.each do |target|
      if ['VeonPrebidMobile', 'VeonPrebidMobileGAMEventHandlers'].include?(target.name)
        target.build_configurations.each do |build_config|
          build_config.build_settings['DEFINES_MODULE'] = 'YES'
          build_config.build_settings['SWIFT_VERSION'] = '5.0'
          build_config.build_settings['BUILD_LIBRARY_FOR_DISTRIBUTION'] = 'YES'
          build_config.build_settings['OTHER_SWIFT_FLAGS'] = '$(inherited) -no-verify-emitted-module-interface'
        end
      end
    end`;

        // Insert before the last `end` of post_install block
        podfile = podfile.replace(
          /(react_native_post_install\([^)]*\)[\s\S]*?\))/,
          `$1\n${postInstallHook}`
        );
      }

      fs.writeFileSync(podfilePath, podfile);
      return cfg;
    },
  ]);
}

module.exports = function withVeonPrebid(config) {
  return withPlugins(config, [withVeonPrebidIOS]);
};
