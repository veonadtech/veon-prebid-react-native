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
                "loadBanner": 1,
                "showBanner": 2,
                "hideBanner": 3,
                "loadInterstitial": 4,
                "showInterstitial": 5,
                "hideInterstitial": 6,
                "pauseAuction": 7,
                "resumeAuction": 8,
                "destroyAuction": 9
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
