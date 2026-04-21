import Foundation
import React
import PrebidMobile
import GoogleMobileAds

@objc(VeonPrebidReactNativeModule)
class VeonPrebidReactNativeModule: RCTEventEmitter {

    // All reads/writes for these flags happen on DispatchQueue.main.
    private var isInitialized = false
    private var isInitializing = false

    // Native safety-timer deadline (defense-in-depth behind the JS guard).
    private static let nativeInitTimeoutSeconds: TimeInterval = 20

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
        DispatchQueue.main.async { [weak self] in
            guard let self = self else {
                reject("INIT_ERROR", "Module deallocated", nil)
                return
            }

            if self.isInitialized {
                resolve("already initialized")
                return
            }
            if self.isInitializing {
                reject("INIT_IN_PROGRESS", "Prebid SDK initialization already in progress", nil)
                return
            }
            self.isInitializing = true

            print("Initializing Veon Prebid SDK...")
            print("Host: \(prebidHost)")
            print("Config Host: \(configHost)")
            print("Account ID: \(accountId)")
            print("Timeout: \(timeoutMillis) ms")
            print("Debug: \(pbsDebug)")

            // Apply settings BEFORE init so they are active during the first auction.
            Prebid.shared.prebidServerAccountId = accountId
            Prebid.shared.timeoutMillis = timeoutMillis.intValue
            Prebid.shared.pbsDebug = pbsDebug
            Prebid.shared.shareGeoLocation = true

            if let bundleIdentifier = Bundle.main.bundleIdentifier {
                Targeting.shared.sourceapp = bundleIdentifier
            }

            // `didSettle` serializes the Prebid callback vs. the native safety
            // timer. Both run on main queue, so a plain Bool is sufficient.
            var didSettle = false

            let settleSuccess: (String) -> Void = { result in
                if didSettle { return }
                didSettle = true
                self.isInitializing = false
                self.isInitialized = true
                self.sendEvent(withName: "prebidSdkInitialized", body: result)
                resolve(result)
            }

            let settleFailure: (String, String, Error?) -> Void = { code, message, error in
                if didSettle { return }
                didSettle = true
                self.isInitializing = false
                self.sendEvent(withName: "prebidSdkInitializeFailed", body: message)
                reject(code, message, error)
            }

            // Defense-in-depth: if Prebid's callback never fires, reject after N s.
            DispatchQueue.main.asyncAfter(deadline: .now() + Self.nativeInitTimeoutSeconds) {
                settleFailure(
                    "INIT_TIMEOUT_NATIVE",
                    "Prebid SDK initialization exceeded \(Int(Self.nativeInitTimeoutSeconds))s (native guard)",
                    nil
                )
            }

            do {
                try Prebid.initializeSDK(
                    serverURL: prebidHost,
                    gadMobileAdsVersion: string(for: MobileAds.shared.versionNumber)
                ) { status, error in
                    DispatchQueue.main.async {
                        switch status {
                        case .succeeded:
                            print("Prebid Mobile SDK initialized successfully!")
                            settleSuccess("successfully")
                        case .serverStatusWarning:
                            let detail = error?.localizedDescription ?? "server status warning"
                            print("Prebid Mobile SDK init: serverStatusWarning — \(detail)")
                            settleSuccess("warning: \(detail)")
                        case .serverStatusSkipped:
                            print("Prebid Mobile SDK init: serverStatusSkipped")
                            settleSuccess("skipped")
                        case .failed:
                            let detail = error?.localizedDescription ?? "Prebid init failed"
                            print("Prebid Mobile SDK init FAILED — \(detail)")
                            settleFailure("INIT_FAILED", detail, error)
                        @unknown default:
                            let detail = error?.localizedDescription ?? "unknown init status"
                            print("Prebid Mobile SDK init: unknown status — \(detail)")
                            settleFailure("INIT_FAILED", detail, error)
                        }
                    }
                }
            } catch {
                settleFailure("INIT_FAILED", "Initialization threw: \(error.localizedDescription)", error)
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
