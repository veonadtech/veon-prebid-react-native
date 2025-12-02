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

            do {
                print("Initializing Veon Prebid SDK...")
                print("Host: \(prebidHost)")
                print("Config Host: \(configHost)")
                print("Account ID: \(accountId)")
                print("Timeout: \(timeoutMillis) ms")
                print("Debug: \(pbsDebug)")

                // Set Prebid account ID
                Prebid.shared.prebidServerAccountId = accountId

                // Set Prebid server host
                if let url = URL(string: prebidHost) {
                    let host = PrebidHost.Custom
                    host.name = url.host ?? prebidHost
                    Prebid.shared.prebidServerHost = host
                } else {
                    throw NSError(domain: "VeonPrebid", code: -1, userInfo: [
                        NSLocalizedDescriptionKey: "Invalid prebidHost URL"
                    ])
                }

                // Initialize SDK with config
                Prebid.initializeSDK(configHost) { [weak self] status in
                    switch status {
                    case .succeeded:
                        print("Prebid Mobile SDK initialized successfully!")
                        self?.isInitialized = true
                        self?.sendEvent(withName: "prebidSdkInitialized", body: "successfully")
                        resolve("successfully")

                    case .serverStatusWarning(let message):
                        print("Server status warning: \(message)")
                        self?.isInitialized = true
                        self?.sendEvent(withName: "prebidSdkInitialized", body: message)
                        resolve(message)

                    case .failed(let error):
                        let errorMessage = "Initialization failed: \(error.localizedDescription)"
                        print(errorMessage)
                        self?.sendEvent(withName: "prebidSdkInitializeFailed", body: errorMessage)
                        reject("INIT_FAILED", errorMessage, error)
                    }
                }

                // Set timeout
                Prebid.shared.timeoutMillis = timeoutMillis.intValue

                // Set debug mode
                Prebid.shared.pbsDebug = pbsDebug

                // Enable geo location sharing
                Prebid.shared.shareGeoLocation = true

                // Initialize Google Mobile Ads
                GADMobileAds.sharedInstance().start { status in
                    print("Google Mobile Ads initialized")
                }

            } catch {
                print("Error initializing Prebid SDK: \(error.localizedDescription)")
                reject("INIT_ERROR", "Failed to initialize SDK: \(error.localizedDescription)", error)
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
