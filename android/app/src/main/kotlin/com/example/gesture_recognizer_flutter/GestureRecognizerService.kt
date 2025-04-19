package com.example.gesture_recognizer_flutter

import android.content.Context
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.media.Image
import androidx.camera.core.ImageAnalysis
import androidx.camera.core.ImageProxy
import com.google.mediapipe.tasks.vision.gesturerecognizer.GestureRecognizer
import com.google.mediapipe.tasks.vision.gesturerecognizer.GestureRecognizerResult
import com.google.mediapipe.tasks.vision.core.ImageProcessingOptions
import com.google.mediapipe.tasks.vision.core.RunningMode
import com.google.mediapipe.framework.image.MPImage
import com.google.mediapipe.framework.image.BitmapImageBuilder
import com.google.mediapipe.tasks.core.BaseOptions
import java.io.File
import java.nio.ByteBuffer

class GestureRecognizerService(
    private val context: Context,
    private val modelPath: String,
    private val onGestureRecognized: (String) -> Unit
) {
    private var gestureRecognizer: GestureRecognizer? = null
    private var isProcessing = false

    init {
        initializeGestureRecognizer()
    }

    private fun initializeGestureRecognizer() {
        try {
            val baseOptions = BaseOptions.builder()
                .setModelAssetPath(modelPath)
                .build()

            val options = GestureRecognizer.GestureRecognizerOptions.builder()
                .setBaseOptions(baseOptions)
                .setRunningMode(RunningMode.LIVE_STREAM)
                .setMinHandDetectionConfidence(0.5f)
                .setMinHandPresenceConfidence(0.5f)
                .setMinTrackingConfidence(0.5f)
                .build()
            gestureRecognizer = GestureRecognizer.createFromOptions(context, options)
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }

    fun processImage(image: ImageProxy) {
        if (isProcessing) return
        isProcessing = true

        try {
            val bitmap = image.toBitmap()
            val mpImage = BitmapImageBuilder(bitmap).build()

            val result = gestureRecognizer?.recognize(mpImage)
            result?.gestures()?.firstOrNull()?.let { gesture ->
                onGestureRecognized(gesture.firstOrNull()?.categoryName() ?: "Unknown")
            }
        } catch (e: Exception) {
            e.printStackTrace()
        } finally {
            isProcessing = false
            image.close()
        }
    }

    private fun ImageProxy.toBitmap(): Bitmap {
        val buffer = planes[0].buffer
        val bytes = ByteArray(buffer.remaining())
        buffer.get(bytes)
        return BitmapFactory.decodeByteArray(bytes, 0, bytes.size)
    }

    fun release() {
        gestureRecognizer?.close()
    }
}