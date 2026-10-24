import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
    if let registrar = engineBridge.pluginRegistry.registrar(forPlugin: "CoursatyBackgroundDownloads") {
      BackgroundDownloadTask.register(with: registrar)
    }
  }
}

/// Asks iOS for extra time to keep a video download running after the app
/// leaves the foreground. iOS grants only a short window (about 30 seconds);
/// when it ends the download pauses and the Dart side resumes it once the
/// app is active again.
final class BackgroundDownloadTask: NSObject {
  private var taskId: UIBackgroundTaskIdentifier = .invalid

  static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(
      name: "coursaty/background_downloads",
      binaryMessenger: registrar.messenger()
    )
    let instance = BackgroundDownloadTask()
    channel.setMethodCallHandler { call, result in
      switch call.method {
      case "start":
        instance.begin()
        result(true)
      case "stop":
        instance.end()
        result(true)
      default:
        result(FlutterMethodNotImplemented)
      }
    }
  }

  private func begin() {
    guard taskId == .invalid else { return }
    taskId = UIApplication.shared.beginBackgroundTask(withName: "coursaty.video-download") {
      [weak self] in
      self?.end()
    }
  }

  private func end() {
    guard taskId != .invalid else { return }
    UIApplication.shared.endBackgroundTask(taskId)
    taskId = .invalid
  }
}
