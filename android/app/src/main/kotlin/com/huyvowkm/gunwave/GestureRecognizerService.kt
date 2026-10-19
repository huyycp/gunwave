package com.huyvowkm.gunwave

import android.content.Context
import android.util.Log
import androidx.camera.core.ImageProxy
import com.google.mediapipe.framework.image.MediaImageBuilder
import com.google.mediapipe.tasks.core.BaseOptions
import com.google.mediapipe.tasks.vision.core.ImageProcessingOptions
import com.google.mediapipe.tasks.vision.core.RunningMode
import com.google.mediapipe.tasks.vision.gesturerecognizer.GestureRecognizer
import java.util.concurrent.RejectedExecutionException
import java.util.concurrent.Executors

/**
 * Runs MediaPipe gesture recognition for CameraX frames and emits gesture-name changes.
 *
 * Pass each [ImageProxy] from the camera analyzer to [processImage]. This service takes
 * ownership of that frame and closes it after recognition or when it is skipped. Call
 * [release] after stopping the camera so the recognizer closes after any active inference.
 */
class GestureRecognizerService(
    private val context: Context,
    private val modelPath: String,
    private val onGestureRecognized: (String) -> Unit
) {
    private val TAG = "GestureRecognizerService"
    private var gestureRecognizer: GestureRecognizer? = null
    @Volatile private var isProcessing = false
    @Volatile private var releaseRequested = false
    private var lastEmittedGesture: String? = null
    private val executor = Executors.newSingleThreadExecutor()

    init {
        initializeGestureRecognizer()
    }

    /** Creates the IMAGE-mode recognizer from the model packaged in the app assets. */
    private fun initializeGestureRecognizer() {
        try {
            Log.d(TAG, "Initializing gesture recognizer with model: $modelPath")
            
            // Build model options
            val baseOptionsBuilder = BaseOptions.builder()
            
            // Use model asset path for packaged models
            baseOptionsBuilder.setModelAssetPath(modelPath)
            
            val baseOptions = baseOptionsBuilder.build()
            
            // Configure gesture recognizer options
            val options = GestureRecognizer.GestureRecognizerOptions.builder()
                .setBaseOptions(baseOptions)
                .setRunningMode(RunningMode.IMAGE)  // Use IMAGE mode for simpler implementation
                .setMinHandDetectionConfidence(0.5f)
                .setMinHandPresenceConfidence(0.5f)
                .setMinTrackingConfidence(0.5f)
                .build()
            
            // Create the gesture recognizer
            gestureRecognizer = GestureRecognizer.createFromOptions(context, options)
            Log.d(TAG, "Gesture recognizer initialized successfully")
        } catch (e: Exception) {
            Log.e(TAG, "Error initializing gesture recognizer: ${e.message}")
            e.printStackTrace()
        }
    }

    /**
     * Recognizes one CameraX frame without converting it to a bitmap or compressed JPEG.
     *
     * The incoming [ImageProxy] is always closed by this method. Frames are dropped while
     * another inference is running, and [ImageProxy.imageInfo] rotation is passed to
     * MediaPipe so the model receives the camera frame in the correct orientation.
     */
    fun processImage(imageProxy: ImageProxy) {
        if (releaseRequested || isProcessing || gestureRecognizer == null) {
            imageProxy.close()
            return
        }
        
        isProcessing = true
        
        try {
            executor.execute {
                try {
                    val mediaImage = imageProxy.image ?: return@execute
                    val mpImage = MediaImageBuilder(mediaImage).build()
                    try {
                        val imageOptions = ImageProcessingOptions.builder()
                            .setRotationDegrees(imageProxy.imageInfo.rotationDegrees)
                            .build()
                        val result = gestureRecognizer?.recognize(mpImage, imageOptions)
                        val gesture = result?.gestures()?.firstOrNull()?.firstOrNull()
                        emitGestureIfChanged(gesture?.categoryName() ?: "Unknown")
                    } finally {
                        mpImage.close()
                    }
                } catch (e: Exception) {
                    Log.e(TAG, "Error processing image: ${e.message}")
                    e.printStackTrace()
                } finally {
                    isProcessing = false
                    imageProxy.close()
                }
            }
        } catch (e: RejectedExecutionException) {
            // release() may shut down the executor while a camera callback is arriving.
            isProcessing = false
            imageProxy.close()
        }
    }

    /** Emits only changes so an unchanged gesture does not trigger repeated UI updates. */
    private fun emitGestureIfChanged(gesture: String) {
        if (gesture == lastEmittedGesture) return
        lastEmittedGesture = gesture
        onGestureRecognized(gesture)
    }

    /**
     * Stops accepting frames and closes MediaPipe after any queued inference completes.
     *
     * Call this after stopping the camera. Cleanup runs on the recognition executor so
     * the native recognizer is never closed while an inference is using it.
     */
    @Synchronized
    fun release() {
        if (releaseRequested) return
        releaseRequested = true
        try {
            Log.d(TAG, "Releasing gesture recognizer...")
            executor.execute {
                try {
                    emitGestureIfChanged("Unknown")
                } catch (e: Exception) {
                    Log.e(TAG, "Error resetting gesture state during release: ${e.message}")
                } finally {
                    try {
                        gestureRecognizer?.close()
                    } catch (e: Exception) {
                        Log.e(TAG, "Error closing gesture recognizer: ${e.message}")
                    } finally {
                        gestureRecognizer = null
                        Log.d(TAG, "Gesture recognizer released")
                    }
                }
            }
            executor.shutdown()
        } catch (e: Exception) {
            Log.e(TAG, "Error releasing gesture recognizer: ${e.message}")
        }
    }
}
