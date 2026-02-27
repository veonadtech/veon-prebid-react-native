const { withDangerousMod } = require('@expo/config-plugins');
const fs = require('fs');
const path = require('path');

/**
 * Expo config plugin for setupad-prebid-react-native
 *
 * Automatically configures the consumer's iOS Podfile with:
 * - use_frameworks! :linkage => :static (required for Swift module resolution)
 * - Explicit VeonPrebid pod dependencies
 * - post_install hooks for DEFINES_MODULE and Swift module resolution
 */
module.exports = function withVeonPrebid(config) {
  return withDangerousMod(config, [
    'ios',
    async (cfg) => {
      const podfilePath = path.join(
        cfg.modRequest.platformProjectRoot,
        'Podfile'
      );

      if (!fs.existsSync(podfilePath)) {
        return cfg;
      }

      let podfile = fs.readFileSync(podfilePath, 'utf8');

      // 1. Add use_frameworks! directly in Podfile
      //    Cannot rely on Podfile.properties.json because pod install reads it
      //    BEFORE dangerous mods write to it during first prebuild.
      if (!podfile.includes("use_frameworks! :linkage => :static")) {
        podfile = podfile.replace(
          /use_react_native!\(/,
          `use_frameworks! :linkage => :static\n\n  use_react_native!(`
        );
      }

      // 2. Add explicit Veon Prebid pod dependencies
      if (!podfile.includes("pod 'VeonPrebidMobile'")) {
        podfile = podfile.replace(
          /use_react_native!\(/,
          `# Veon Prebid Dependencies\n  pod 'Google-Mobile-Ads-SDK', '12.3.0'\n  pod 'VeonPrebidMobile', '0.0.4'\n  pod 'VeonPrebidMobileGAMEventHandlers', '0.0.4'\n\n  use_react_native!(`
        );
      }

      // 3. Add post_install hook for VeonPrebid module fixes
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

        podfile = podfile.replace(
          /(react_native_post_install\([^)]*\)[\s\S]*?\))/,
          `$1\n${postInstallHook}`
        );
      }

      fs.writeFileSync(podfilePath, podfile);
      return cfg;
    },
  ]);
};