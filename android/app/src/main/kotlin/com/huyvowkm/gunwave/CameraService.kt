package com.huyvowkm.gunwave

import android.content.Context
import android.util.Log
import androidx.camera.core.Camera
import androidx.camera.core.CameraSelector
import androidx.camera.core.ImageAnalysis
import androidx.camera.core.ImageProxy
import androidx.camera.core.Preview
import androidx.camera.lifecycle.ProcessCameraProvider
import androidx.core.content.ContextCompat
import androidx.lifecycle.LifecycleOwner
import java.util.concurrent.ExecutorService
import java.util.concurrent.Executors
import java.util.concurrent.TimeUnit

class CameraService(
    private val context: Context,
    private val lifecycleOwner: LifecycleOwner,
    private val onImageCaptured: (ImageProxy) -> Unit
) {
    private val TAG = "CameraService"
    private var cameraExecutor: ExecutorService = Executors.newSingleThreadExecutor()
    private var camera: Camera? = null
    private var cameraProvider: ProcessCameraProvider? = null
    private var imageAnalysis: ImageAnalysis? = null

    fun startCamera() {
        Log.d(TAG, "Starting camera...")
        val cameraProviderFuture = ProcessCameraProvider.getInstance(context)
        cameraProviderFuture.addListener({
            try {
                cameraProvider = cameraProviderFuture.get()
                Log.d(TAG, "Camera provider obtained")
                
                // Create and configure the image analysis use case
                imageAnalysis = ImageAnalysis.Builder()
                    .setBackpressureStrategy(ImageAnalysis.STRATEGY_KEEP_ONLY_LATEST)
                    .build()
                
                imageAnalysis?.setAnalyzer(cameraExecutor) { imageProxy ->
                    try {
                        // Process the image
                        onImageCaptured(imageProxy)
                    } catch (e: Exception) {
                        Log.e(TAG, "Error processing image: ${e.message}")
                        imageProxy.close()
                    }
                }
                
                // Select the front camera
                val cameraSelector = CameraSelector.DEFAULT_FRONT_CAMERA
                
                try {
                    // Unbind any previous use cases
                    cameraProvider?.unbindAll()
                    
                    // Bind the camera to lifecycle and use cases
                    camera = cameraProvider?.bindToLifecycle(
                        lifecycleOwner,
                        cameraSelector,
                        imageAnalysis
                    )
                    Log.d(TAG, "Camera successfully bound to lifecycle")
                } catch (e: Exception) {
                    Log.e(TAG, "Failed to bind camera use cases: ${e.message}")
                }
            } catch (e: Exception) {
                Log.e(TAG, "Failed to get camera provider: ${e.message}")
            }
        }, ContextCompat.getMainExecutor(context))
    }

    fun stopCamera() {
        Log.d(TAG, "Stopping camera...")
        try {
            cameraProvider?.unbindAll()
            cameraExecutor.shutdown()
            try {
                // Wait for tasks to complete
                if (!cameraExecutor.awaitTermination(500, TimeUnit.MILLISECONDS)) {
                    cameraExecutor.shutdownNow()
                }
            } catch (e: InterruptedException) {
                cameraExecutor.shutdownNow()
            }
            Log.d(TAG, "Camera stopped successfully")
        } catch (e: Exception) {
            Log.e(TAG, "Error stopping camera: ${e.message}")
        }
    }
}