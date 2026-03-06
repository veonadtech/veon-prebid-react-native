/**
 * This script generates a plain JavaScript version of VeonPrebidReactNativeViewNativeComponent
 * after bob build. Builder-bob may skip codegen spec files, so we need to ensure
 * the lib/module/ output contains a valid .js file without TypeScript syntax.
 *
 * Bare React Native CLI projects require clean JS for codegen validation,
 * otherwise 'Commands' is not recognized as a valid codegenNativeCommands export.
 */

const fs = require('fs');
const path = require('path');

const outputPath = path.join(
  __dirname,
  '..',
  'lib',
  'module',
  'VeonPrebidReactNativeViewNativeComponent.js'
);

// Only generate if the .js file doesn't exist or still contains TypeScript syntax
const needsGeneration = (() => {
  if (!fs.existsSync(outputPath)) return true;
  const content = fs.readFileSync(outputPath, 'utf8');
  // If it contains TypeScript-only syntax, it needs to be regenerated
  return content.includes('interface ') || content.includes(': NativeCommands');
})();

if (needsGeneration) {
  const jsContent = `import codegenNativeComponent from 'react-native/Libraries/Utilities/codegenNativeComponent';
import codegenNativeCommands from 'react-native/Libraries/Utilities/codegenNativeCommands';

export const Commands = codegenNativeCommands({
  supportedCommands: [
    'loadBanner',
    'showBanner',
    'hideBanner',
    'loadInterstitial',
    'showInterstitial',
    'hideInterstitial',
    'pauseAuction',
    'resumeAuction',
    'destroyAuction',
  ],
});

export default codegenNativeComponent('VeonPrebidReactNativeView');
`;

  fs.writeFileSync(outputPath, jsContent, 'utf8');
  console.log(
    'Generated clean JS for VeonPrebidReactNativeViewNativeComponent'
  );
}
