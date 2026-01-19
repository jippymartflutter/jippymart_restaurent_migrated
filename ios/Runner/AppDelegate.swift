import UIKit
import Flutter
import Firebase
import GoogleMaps

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {

    // ✅ Initialize Firebase
    FirebaseApp.configure()

    // ✅ Initialize Google Maps SDK
    if let googleMapsApiKey = Bundle.main.object(forInfoDictionaryKey: "GoogleMapsApiKey") as? String {
      GMSServices.provideAPIKey(googleMapsApiKey)
      print("✅ Google Maps SDK initialized successfully")
    } else if let googleMapsApiKey = Bundle.main.object(forInfoDictionaryKey: "GMSApiKey") as? String {
      // Some projects use "GMSApiKey" instead of "GoogleMapsApiKey"
      GMSServices.provideAPIKey(googleMapsApiKey)
      print("✅ Google Maps SDK initialized successfully with GMSApiKey")
    } else {
      print("⚠️ Warning: Google Maps API key not found in Info.plist")
      // Try to look for any potential key names
      if let keys = Bundle.main.infoDictionary {
        for (key, value) in keys {
          if let stringValue = value as? String,
             (key.lowercased().contains("google") && key.lowercased().contains("map")) ||
             key.lowercased().contains("gms") {
            print("Found potential key: \(key) = \(stringValue)")
            GMSServices.provideAPIKey(stringValue)
            break
          }
        }
      }
    }

    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}