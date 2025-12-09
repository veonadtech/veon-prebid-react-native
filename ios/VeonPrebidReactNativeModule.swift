import Foundation
import React
import PrebidMobile
import GoogleMobileAds

@objc(VeonPrebidReactNativeModule)
class VeonPrebidReactNativeModule: RCTEventEmitter {

    private var isInitialized = false

    override init() {
        super.init()
    }

    @objc
    override static func requiresMainQueueSetup() -> Bool {
        return true
    }

    override func supportedEvents() -> [String]! {
        return ["prebidSdkInitialized", "prebidSdkInitializeFailed"]
    }

    // MARK: - SDK Initialization

    @objc
    func initializeSDK(
        _ prebidHost: String,
        configHost: String,
        accountId: String,
        timeoutMillis: NSNumber,
        pbsDebug: Bool,
        resolve: @escaping RCTPromiseResolveBlock,
        reject: @escaping RCTPromiseRejectBlock
    ) {
        // Prevent multiple initializations
        if isInitialized {
            resolve("already initialized")
            return
        }

        DispatchQueue.main.async { [weak self] in
            guard let self = self else {
                reject("INIT_ERROR", "Module deallocated", nil)
                return
            }

            print("Initializing Veon Prebid SDK...")
            print("Host: \(prebidHost)")
            print("Config Host: \(configHost)")
            print("Account ID: \(accountId)")
            print("Timeout: \(timeoutMillis) ms")
            print("Debug: \(pbsDebug)")

            // Set Prebid account ID
            Prebid.shared.prebidServerAccountId = accountId

            // Set timeout (must be set before initialization)
            Prebid.shared.timeoutMillis = timeoutMillis.intValue

            // Set debug mode
            Prebid.shared.pbsDebug = pbsDebug

            // Enable geo location sharing
            Prebid.shared.shareGeoLocation = true
          
          do {
              try Prebid.initializeSDK(
                serverURL: prebidHost,
                  gadMobileAdsVersion: string(for: MobileAds.shared.versionNumber)
              ) { status, error in
                print("Prebid Mobile SDK initialized successfully!")
                self.isInitialized = true
                self.sendEvent(withName: "prebidSdkInitialized", body: "successfully")
                resolve("successfully") // Return success
              }
          } catch {
            let errorMessage = "Initialization failed"
            print(errorMessage)
            self.sendEvent(withName: "prebidSdkInitializeFailed", body: errorMessage)
            reject("INIT_FAILED", errorMessage, nil)
          }

        }
    }

    // MARK: - SDK Version

    @objc
    func getSDKVersion(
        _ resolve: @escaping RCTPromiseResolveBlock,
        reject: @escaping RCTPromiseRejectBlock
    ) {
        do {
            let version = Prebid.shared.version
            resolve(version)
        } catch { 
            reject("VERSION_ERROR", "Failed to get SDK version: \(error.localizedDescription)", error)
        }
    }
}
