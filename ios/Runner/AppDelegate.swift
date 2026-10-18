import UIKit
import Flutter
import AVFoundation
import MediaPipeTasksVision

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  var flutterMethodChannel: FlutterMethodChannel?
  private var cameraFeedService: CameraFeedService?
  private var gestureRecognizerService: GestureRecognizerService?
  private var lastEmittedGesture: String?
  private let backgroundQueue = DispatchQueue(label: "com.google.mediapipe.appdelegate.backgroundQueue")

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  /// Registers plugins and the gesture channel after Flutter creates its implicit engine.
  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)

    flutterMethodChannel = FlutterMethodChannel(
      name: "gesture_recognizer",
      binaryMessenger: engineBridge.applicationRegistrar.messenger()
    )

    // Handle MethodChannel calls
    flutterMethodChannel?.setMethodCallHandler { [weak self] (call, result) in
      guard let self = self else { return }

      switch call.method {
      case "startGestureRecognition":
        self.startGestureRecognition { started in
          if started {
            result(nil)
          } else {
            result(FlutterError(
              code: "PERMISSION_OR_CAMERA_ERROR",
              message: "Camera access is required for gesture recognition",
              details: nil
            ))
          }
        }
      case "stopGestureRecognition":
        self.stopGestureRecognition()
        result(nil)
      default:
        result(FlutterMethodNotImplemented)
      }
    }
  }

  private func startGestureRecognition(completion: @escaping (Bool) -> Void) {
    lastEmittedGesture = nil
    // Request camera permissions
    AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
      guard let self = self else { return }
      guard granted else {
        DispatchQueue.main.async {
          self.presentCameraPermissionsDeniedAlert()
          completion(false)
        }
        return
      }

      DispatchQueue.main.async {
        self.initializeCameraFeedService { status in
          guard status == .success else {
            if status == .permissionDenied {
              self.presentCameraPermissionsDeniedAlert()
            } else {
              self.presentVideoConfigurationErrorAlert()
            }
            completion(false)
            return
          }
          self.initializeGestureRecognizerService()
          completion(true)
        }
      }
    }
  }

  private func stopGestureRecognition() {
    emitGestureIfChanged("Unknown")
    cameraFeedService?.stopSession()
    gestureRecognizerService = nil
  }

  private func emitGestureIfChanged(_ gesture: String) {
    guard gesture != lastEmittedGesture else { return }
    lastEmittedGesture = gesture
    flutterMethodChannel?.invokeMethod("onGestureRecognized", arguments: gesture)
  }

  private func initializeCameraFeedService(
    completion: @escaping (CameraFeedService.CameraConfigurationStatus) -> Void
  ) {
    // Create a preview view for the camera feed
    let previewView = UIView(frame: UIScreen.main.bounds)
    previewView.backgroundColor = .black
    // Comment out the line below to prevent the preview from being added
    // window?.rootViewController?.view.addSubview(previewView)

    // Initialize the CameraFeedService
    cameraFeedService = CameraFeedService(previewView: previewView)
    cameraFeedService?.delegate = self
    cameraFeedService?.startLiveCameraSession { cameraConfiguration in
      DispatchQueue.main.async {
        completion(cameraConfiguration)
      }
    }
  }

  private func initializeGestureRecognizerService() {
    // Get the model path from the app bundle
    guard let modelPath = Bundle.main.path(forResource: "gesture_recognizer", ofType: "task") else {
      print("Failed to find gesture recognizer model in bundle")
      return
    }

    // Create delegate for gesture recognizer
    let delegate = DefaultConstants.delegate
    
    gestureRecognizerService = GestureRecognizerService.liveStreamGestureRecognizerService(
      modelPath: modelPath,
      minHandDetectionConfidence: 0.5,
      minHandPresenceConfidence: 0.5,
      minTrackingConfidence: 0.5,
      liveStreamDelegate: self,
      delegate: delegate
    )
  }

  private func presentCameraPermissionsDeniedAlert() {
    let alertController = UIAlertController(
      title: "Camera Permissions Denied",
      message: "Camera permissions have been denied for this app. You can change this by going to Settings.",
      preferredStyle: .alert
    )
    let settingsAction = UIAlertAction(title: "Settings", style: .default) { _ in
      UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
    }
    let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
    alertController.addAction(settingsAction)
    alertController.addAction(cancelAction)
    presentAlertFromActiveScene(alertController)
  }

  private func presentVideoConfigurationErrorAlert() {
    let alert = UIAlertController(
      title: "Camera Configuration Failed",
      message: "There was an error while configuring the camera.",
      preferredStyle: .alert
    )
    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
    presentAlertFromActiveScene(alert)
  }

  /// Presents native permission and camera errors from the active scene's key window.
  private func presentAlertFromActiveScene(_ alert: UIAlertController) {
    guard let windowScene = UIApplication.shared.connectedScenes
      .compactMap({ $0 as? UIWindowScene })
      .first(where: { $0.activationState == .foregroundActive }),
      let rootViewController = windowScene.windows.first(where: \.isKeyWindow)?.rootViewController
    else {
      return
    }

    var presenter = rootViewController
    while let presentedViewController = presenter.presentedViewController {
      presenter = presentedViewController
    }
    presenter.present(alert, animated: true)
  }
}

extension AppDelegate: CameraFeedServiceDelegate {
  func didOutput(sampleBuffer: CMSampleBuffer, orientation: UIImage.Orientation) {
    let currentTimeMs = Int(Date().timeIntervalSince1970 * 1000)
    backgroundQueue.async { [weak self] in
      guard let self = self else { return }
      do {
        try self.gestureRecognizerService?.recognizeAsync(
          sampleBuffer: sampleBuffer,
          orientation: orientation,
          timeStamps: currentTimeMs
        )
      } catch {
        print("Error during gesture recognition: \(error)")
      }
    }
  }

  func sessionWasInterrupted(canResumeManually resumeManually: Bool) {
    // Handle session interruption
  }

  func sessionInterruptionEnded() {
    // Handle session interruption end
  }

  func didEncounterSessionRuntimeError() {
    // Handle runtime errors
  }
}

extension AppDelegate: GestureRecognizerServiceLiveStreamDelegate {
  func gestureRecognizerService(
    _ gestureRecognizerService: GestureRecognizerService,
    didFinishRecognition result: ResultBundle?,
    error: Error?
  ) {
    DispatchQueue.main.async { [weak self] in
      guard let self = self else { return }
      if let error = error {
        print("Gesture recognition error: \(error)")
        return
      }
      
      guard let gestureRecognizerResult = result?.gestureRecognizerResults.first as? GestureRecognizerResult else { return }
      let recognizedGesture = gestureRecognizerResult.gestures.first?.first?.categoryName ?? "Unknown"
      self.emitGestureIfChanged(recognizedGesture)
    }
  }
}
