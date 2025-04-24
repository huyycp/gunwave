import UIKit
import Flutter
import AVFoundation
import MediaPipeTasksVision

@main
@objc class AppDelegate: FlutterAppDelegate {
  var flutterMethodChannel: FlutterMethodChannel?
  private var cameraFeedService: CameraFeedService?
  private var gestureRecognizerService: GestureRecognizerService?
  private let backgroundQueue = DispatchQueue(label: "com.google.mediapipe.appdelegate.backgroundQueue")

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // Force landscape orientation at startup
    UIDevice.current.setValue(UIInterfaceOrientation.landscapeRight.rawValue, forKey: "orientation")
    
    // Initialize FlutterViewController
    let controller = window?.rootViewController as! FlutterViewController
    
    // Create a MethodChannel for communication between Flutter and native iOS
    flutterMethodChannel = FlutterMethodChannel(
      name: "gesture_recognizer",
      binaryMessenger: controller.binaryMessenger
    )

    // Handle MethodChannel calls
    flutterMethodChannel?.setMethodCallHandler { [weak self] (call, result) in
      guard let self = self else { return }

      switch call.method {
      case "startGestureRecognition":
        self.startGestureRecognition()
        result(nil)
      case "stopGestureRecognition":
        self.stopGestureRecognition()
        result(nil)
      default:
        result(FlutterMethodNotImplemented)
      }
    }

    // Register Flutter plugins
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  private func startGestureRecognition() {
    // Request camera permissions
    AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
      guard let self = self else { return }
      if granted {
        DispatchQueue.main.async {
          self.initializeCameraFeedService()
          self.initializeGestureRecognizerService()
        }
      } else {
        self.presentCameraPermissionsDeniedAlert()
      }
    }
  }

  private func stopGestureRecognition() {
    cameraFeedService?.stopSession()
    gestureRecognizerService = nil
  }

  private func initializeCameraFeedService() {
    // Create a preview view for the camera feed
    let previewView = UIView(frame: UIScreen.main.bounds)
    previewView.backgroundColor = .black
    // Comment out the line below to prevent the preview from being added
    // window?.rootViewController?.view.addSubview(previewView)

    // Initialize the CameraFeedService
    cameraFeedService = CameraFeedService(previewView: previewView)
    cameraFeedService?.delegate = self
    cameraFeedService?.startLiveCameraSession { [weak self] cameraConfiguration in
      DispatchQueue.main.async {
        switch cameraConfiguration {
        case .failed:
          self?.presentVideoConfigurationErrorAlert()
        case .permissionDenied:
          self?.presentCameraPermissionsDeniedAlert()
        default:
          break
        }
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
    window?.rootViewController?.present(alertController, animated: true, completion: nil)
  }

  private func presentVideoConfigurationErrorAlert() {
    let alert = UIAlertController(
      title: "Camera Configuration Failed",
      message: "There was an error while configuring the camera.",
      preferredStyle: .alert
    )
    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
    window?.rootViewController?.present(alert, animated: true, completion: nil)
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
      if let firstGesture = gestureRecognizerResult.gestures.first {
        let recognizedGesture = firstGesture.first?.categoryName
        // Send the recognized gesture back to Flutter
        self.flutterMethodChannel?.invokeMethod("onGestureRecognized", arguments: recognizedGesture)
      }
    }
  }
}
