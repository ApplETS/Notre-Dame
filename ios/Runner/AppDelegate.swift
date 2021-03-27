import UIKit
import Flutter
import GoogleMaps
#import "FlutterConfigPlugin.h"

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  NSString *apiMaps = [FlutterConfigPlugin envFor:@"MAPS_API_KEY"];
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GMSServices.provideAPIKey(Bundle.main.object(forInfoDictionaryKey: "MAPS_API_KEY") as? String ?? "@apiMaps")
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
