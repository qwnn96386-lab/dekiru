import UIKit
import Flutter

@UIApplicationMain // 使用標準的入口標籤
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // 這是最關鍵的一行，確保所有 Flutter 插件（定位、通知等）被正確註冊
    GeneratedPluginRegistrant.register(with: self)
    
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}