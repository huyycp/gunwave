import Flutter
import MediaPipeTasksVision

@objc class GestureRecognizerPlugin: NSObject {
    private var gestureRecognizer: GestureRecognizer?
    private var resultCallback: FlutterResult?
    
    @objc static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "gesture_recognizer", binaryMessenger: registrar.messenger())
        let instance = GestureRecognizerPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
}

extension GestureRecognizerPlugin: FlutterPlugin {
    func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "loadModel":
            guard let args = call.arguments as? [String: Any],
                  let modelPath = args["modelPath"] as? String else {
                result(FlutterError(code: "INVALID_ARGUMENTS",
                                  message: "Model path is required",
                                  details: nil))
                return
            }
            
            do {
                // Create base options
                let baseOptions = BaseOptions(modelPath: modelPath)
                
                // Create gesture recognizer options
                let options = GestureRecognizerOptions(baseOptions: baseOptions)
                
                // Create gesture recognizer
                gestureRecognizer = try GestureRecognizer(options: options)
                
                result(true)
            } catch {
                result(FlutterError(code: "MODEL_LOAD_ERROR",
                                  message: error.localizedDescription,
                                  details: nil))
            }
            
        case "recognize":
            guard let args = call.arguments as? [String: Any],
                  let imageData = args["imageData"] as? FlutterStandardTypedData,
                  let width = args["width"] as? Int,
                  let height = args["height"] as? Int else {
                result(FlutterError(code: "INVALID_ARGUMENTS",
                                  message: "Image data, width, and height are required",
                                  details: nil))
                return
            }
            
            do {
                // Create MPImage from the image data
                let image = try MPImage(imageData: imageData.data,
                                      width: width,
                                      height: height,
                                      orientation: .up)
                
                // Recognize gesture
                let gestureResult = try gestureRecognizer?.recognize(image: image)
                
                // Convert result to dictionary
                var resultDict: [String: Any] = [:]
                
                if let gestures = gestureResult?.gestures {
                    var gestureArray: [[String: Any]] = []
                    for gesture in gestures {
                        var gestureDict: [String: Any] = [:]
                        gestureDict["categoryName"] = gesture.categoryName
                        gestureDict["score"] = gesture.score
                        gestureArray.append(gestureDict)
                    }
                    resultDict["gestures"] = gestureArray
                }
                
                if let handLandmarks = gestureResult?.handLandmarks {
                    var landmarksArray: [[[String: Double]]] = []
                    for landmarks in handLandmarks {
                        var handLandmarksArray: [[String: Double]] = []
                        for landmark in landmarks {
                            handLandmarksArray.append([
                                landmark.x,
                                landmark.y,
                                landmark.z
                            ])
                        }
                        landmarksArray.append(handLandmarksArray)
                    }
                    resultDict["handLandmarks"] = landmarksArray
                }
                
                result(resultDict)
            } catch {
                result(FlutterError(code: "RECOGNITION_ERROR",
                                  message: error.localizedDescription,
                                  details: nil))
            }
            
        case "dispose":
            gestureRecognizer = nil
            result(nil)
            
        default:
            result(FlutterMethodNotImplemented)
        }
    }
} 