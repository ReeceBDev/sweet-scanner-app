import Flutter
import UIKit
import Vision

let ocrChannelName = "sweet_scanner_app/ocr"

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  static var ocrChannel: FlutterMethodChannel?

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)

    let registrar = engineBridge.pluginRegistry.registrar(forPlugin: "SweetScannerOcrChannel")
    let channel = FlutterMethodChannel(name: ocrChannelName, binaryMessenger: registrar.messenger())
    channel.setMethodCallHandler { (call: FlutterMethodCall, result: @escaping FlutterResult) in
      switch call.method {
      case "recognizeText":
        guard let args = call.arguments as? [String: Any],
              let path = args["path"] as? String else {
          result(FlutterError(code: "bad_arguments", message: "A photo path is required.", details: nil))
          return
        }
        AppDelegate.recognizeText(at: path, result: result)
      default:
        result(FlutterMethodNotImplemented)
      }
    }
    AppDelegate.ocrChannel = channel
  }

  /// Runs the phone's built-in OCR (Apple Vision, VNRecognizeTextRequest) on
  /// the photo at `path` and hands the recognised text back over the channel.
  private static func recognizeText(at path: String, result: @escaping FlutterResult) {
    guard let image = UIImage(contentsOfFile: path), let cgImage = image.cgImage else {
      result(FlutterError(code: "image_load_failed", message: "The captured photo could not be loaded.", details: nil))
      return
    }

    let request = VNRecognizeTextRequest { (request, error) in
      if let error = error {
        DispatchQueue.main.async {
          result(FlutterError(code: "recognition_failed", message: error.localizedDescription, details: nil))
        }
        return
      }
      let observations = (request.results as? [VNRecognizedTextObservation]) ?? []
      let lines = observations.compactMap { $0.topCandidates(1).first?.string }
      let text = lines.joined(separator: "\n")
      DispatchQueue.main.async {
        result(text)
      }
    }
    request.recognitionLevel = .accurate
    request.usesLanguageCorrection = true

    let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
    DispatchQueue.global(qos: .userInitiated).async {
      do {
        try handler.perform([request])
      } catch {
        DispatchQueue.main.async {
          result(FlutterError(code: "recognition_failed", message: error.localizedDescription, details: nil))
        }
      }
    }
  }
}
