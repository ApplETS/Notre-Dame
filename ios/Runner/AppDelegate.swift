import UIKit
import Flutter

@main
@objc class AppDelegate: FlutterAppDelegate, @MainActor FlutterImplicitEngineDelegate {

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    // Register generated plugins for Flutter.
    // MSAL redirect URLs are handled by the msal_auth plugin through FlutterSceneDelegate.
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
  }
}
