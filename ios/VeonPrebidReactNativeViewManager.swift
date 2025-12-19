import React

@objc(VeonPrebidReactNativeViewManager)
class VeonPrebidReactNativeViewManager: RCTViewManager {

    override func view() -> UIView! {
        return VeonPrebidReactNativeView()
    }

    override static func requiresMainQueueSetup() -> Bool {
        return true
    }

    // MARK: - Command Constants

    override func constantsToExport() -> [AnyHashable : Any]! {
        return [
            "Commands": [
                "loadBanner": 0,
                "showBanner": 1,
                "hideBanner": 2,
                "loadInterstitial": 3,
                "showInterstitial": 4,
                "hideInterstitial": 5,
                "pauseAuction": 6,
                "resumeAuction": 7,
                "destroyAuction": 8
            ]
        ]
    }

    // MARK: - Commands

    @objc func loadBanner(_ node: NSNumber) {
        DispatchQueue.main.async {
            if let view = self.bridge.uiManager.view(forReactTag: node) as? VeonPrebidReactNativeView {
                view.loadBanner()
            }
        }
    }

    @objc func showBanner(_ node: NSNumber) {
        DispatchQueue.main.async {
            if let view = self.bridge.uiManager.view(forReactTag: node) as? VeonPrebidReactNativeView {
                view.showBanner()
            }
        }
    }

    @objc func hideBanner(_ node: NSNumber) {
        DispatchQueue.main.async {
            if let view = self.bridge.uiManager.view(forReactTag: node) as? VeonPrebidReactNativeView {
                view.hideBanner()
            }
        }
    }

    @objc func loadInterstitial(_ node: NSNumber) {
        DispatchQueue.main.async {
            if let view = self.bridge.uiManager.view(forReactTag: node) as? VeonPrebidReactNativeView {
                view.loadInterstitial()
            }
        }
    }

    @objc func showInterstitial(_ node: NSNumber) {
        DispatchQueue.main.async {
            if let view = self.bridge.uiManager.view(forReactTag: node) as? VeonPrebidReactNativeView {
                view.showInterstitial()
            }
        }
    }

    @objc func hideInterstitial(_ node: NSNumber) {
        DispatchQueue.main.async {
            if let view = self.bridge.uiManager.view(forReactTag: node) as? VeonPrebidReactNativeView {
                view.hideInterstitial()
            }
        }
    }

    @objc func pauseAuction(_ node: NSNumber) {
        DispatchQueue.main.async {
            if let view = self.bridge.uiManager.view(forReactTag: node) as? VeonPrebidReactNativeView {
                view.pauseAuction()
            }
        }
    }

    @objc func resumeAuction(_ node: NSNumber) {
        DispatchQueue.main.async {
            if let view = self.bridge.uiManager.view(forReactTag: node) as? VeonPrebidReactNativeView {
                view.resumeAuction()
            }
        }
    }

    @objc func destroyAuction(_ node: NSNumber) {
        DispatchQueue.main.async {
            if let view = self.bridge.uiManager.view(forReactTag: node) as? VeonPrebidReactNativeView {
                view.destroyAuction()
            }
        }
    }
}
