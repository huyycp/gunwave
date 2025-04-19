package com.huyvowkm.gunwave

import android.content.Context
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.media.Image
import android.util.Log
import androidx.camera.core.ImageProxy
import com.google.mediapipe.tasks.vision.gesturerecognizer.GestureRecognizer
import com.google.mediapipe.tasks.vision.core.RunningMode
import com.google.mediapipe.framework.image.BitmapImageBuilder
import com.google.mediapipe.framework.image.MPImage
import com.google.mediapipe.tasks.core.BaseOptions
import java.io.File
import java.nio.ByteBuffer
import java.util.concurrent.Executor
import java.util.concurrent.Executors

class GestureRecognizerService(
    private val context: Context,
    private val modelPath: String,
    private val onGestureRecognized: (String) -> Unit
) {
    private val TAG = "GestureRecognizerService"
    private var gestureRecognizer: GestureRecognizer? = null
    private var isProcessing = false
    private val executor = Executors.newSingleThreadExecutor()

    init {
        initializeGestureRecognizer()
    }

    private fun initializeGestureRecognizer() {
        try {
            Log.d(TAG, "Initializing gesture recognizer with model: $modelPath")
            
            // Check if the model file exists
            val assetsPath = modelPath
            val file = File(assetsPath)
            
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

    fun processImage(imageProxy: ImageProxy) {
        if (isProcessing || gestureRecognizer == null) {
            imageProxy.close()
            return
        }
        
        isProcessing = true
        
        executor.execute {
            try {
                Log.d(TAG, "Processing image...")
                val bitmap = imageProxy.toBitmap()
                val mpImage = BitmapImageBuilder(bitmap).build()
                
                // Process the image
                val result = gestureRecognizer?.recognize(mpImage)
                
                // Handle the result
                if (result != null && !result.gestures().isEmpty()) {
                    val topGesture = result.gestures().get(0)
                    if (topGesture.isNotEmpty()) {
                        val category = topGesture[0]
                        val gestureName = category.categoryName()
                        val score = category.score()
                        Log.d(TAG, "Detected gesture: $gestureName with score: $score")
                        onGestureRecognized(gestureName)
                    } else {
                        Log.d(TAG, "No gesture detected in hand")
                    }
                } else {
                    Log.d(TAG, "No hand detected")
                }
            } catch (e: Exception) {
                Log.e(TAG, "Error processing image: ${e.message}")
                e.printStackTrace()
            } finally {
                isProcessing = false
                imageProxy.close()
            }
        }
    }

    private fun ImageProxy.toBitmap(): Bitmap {
        val yBuffer = planes[0].buffer
        val uBuffer = planes[1].buffer
        val vBuffer = planes[2].buffer
        
        val ySize = yBuffer.remaining()
        val uSize = uBuffer.remaining()
        val vSize = vBuffer.remaining()
        
        val nv21 = ByteArray(ySize + uSize + vSize)
        
        // U and V are swapped
        yBuffer.get(nv21, 0, ySize)
        vBuffer.get(nv21, ySize, vSize)
        uBuffer.get(nv21, ySize + vSize, uSize)
        
        val yuvImage = android.graphics.YuvImage(nv21, android.graphics.ImageFormat.NV21, width, height, null)
        val out = java.io.ByteArrayOutputStream()
        yuvImage.compressToJpeg(android.graphics.Rect(0, 0, width, height), 100, out)
        val imageBytes = out.toByteArray()
        return BitmapFactory.decodeByteArray(imageBytes, 0, imageBytes.size)
    }

    fun release() {
        try {
            Log.d(TAG, "Releasing gesture recognizer...")
            gestureRecognizer?.close()
            gestureRecognizer = null
            executor.shutdown()
            Log.d(TAG, "Gesture recognizer released successfully")
        } catch (e: Exception) {
            Log.e(TAG, "Error releasing gesture recognizer: ${e.message}")
        }
    }
}