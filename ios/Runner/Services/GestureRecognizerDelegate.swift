import Foundation
import MediaPipeTasksVision

class GestureRecognizerDelegate: NSObject, GestureRecognizerDelegate {
    func gestureRecognizer(
        _ gestureRecognizer: GestureRecognizer,
        didFinishRecognition result: GestureRecognizerResult?,
        error: Error?
    ) {
        // This method is called when gesture recognition is complete
        // The actual handling is done in the AppDelegate's GestureRecognizerServiceLiveStreamDelegate
    }
} 