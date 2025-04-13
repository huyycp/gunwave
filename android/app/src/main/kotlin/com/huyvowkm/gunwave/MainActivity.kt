package com.huyvowkm.gunwave

import android.Manifest
import android.content.pm.PackageManager
import android.os.Bundle
import android.widget.Toast
import android.util.Log
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File

class MainActivity : FlutterActivity() {
    private val TAG = "MainActivity"
    private val CHANNEL = "gesture_recognizer"
    private var gestureRecognizerService: GestureRecognizerService? = null
    private var cameraService: CameraService? = null
    private val CAMERA_PERMISSION_REQUEST_CODE = 100
    private var methodChannel: MethodChannel? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        Log.d(TAG, "onCreate called")
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        Log.d(TAG, "Configuring Flutter engine")
        
        methodChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
        methodChannel?.setMethodCallHandler { call, result ->
            Log.d(TAG, "Method call received: ${call.method}")
            
            when (call.method) {
                "startGestureRecognition" -> {
                    if (checkCameraPermission()) {
                        Log.d(TAG, "Camera permission granted, starting gesture recognition")
                        // Use a asset path that's definitely accessible
                        startGestureRecognizer("gesture_recognizer.task")
                        result.success(true)
                    } else {
                        Log.d(TAG, "Requesting camera permission")
                        requestCameraPermission()
                        result.error("PERMISSION_DENIED", "Camera permission not granted", null)
                    }
                }
                "stopGestureRecognition" -> {
                    Log.d(TAG, "Stopping gesture recognition")
                    stopGestureRecognizer()
                    result.success(true)
                }
                else -> {
                    Log.d(TAG, "Method not implemented: ${call.method}")
                    result.notImplemented()
                }
            }
        }
    }

    private fun startGestureRecognizer(modelPath: String) {
        try {
            Log.d(TAG, "Starting gesture recognizer with model: $modelPath")
            
            // Create the GestureRecognizerService
            gestureRecognizerService = GestureRecognizerService(
                context = this,
                modelPath = modelPath,
                onGestureRecognized = { gesture ->
                    Log.d(TAG, "Gesture recognized: $gesture")
                    runOnUiThread {
                        methodChannel?.invokeMethod("onGestureRecognized", gesture)
                    }
                }
            )
            
            // Create the CameraService
            cameraService = CameraService(
                context = this,
                lifecycleOwner = this,
                onImageCaptured = { imageProxy ->
                    gestureRecognizerService?.processImage(imageProxy)
                }
            )
            
            // Start the camera
            cameraService?.startCamera()
            Log.d(TAG, "Gesture recognition started successfully")
        } catch (e: Exception) {
            Log.e(TAG, "Error starting gesture recognizer: ${e.message}")
            e.printStackTrace()
        }
    }

    private fun stopGestureRecognizer() {
        try {
            Log.d(TAG, "Stopping gesture recognizer")
            cameraService?.stopCamera()
            cameraService = null
            gestureRecognizerService?.release()
            gestureRecognizerService = null
            Log.d(TAG, "Gesture recognizer stopped successfully")
        } catch (e: Exception) {
            Log.e(TAG, "Error stopping gesture recognizer: ${e.message}")
            e.printStackTrace()
        }
    }

    private fun checkCameraPermission(): Boolean {
        val permission = ContextCompat.checkSelfPermission(
            this,
            Manifest.permission.CAMERA
        ) == PackageManager.PERMISSION_GRANTED
        
        Log.d(TAG, "Camera permission check result: $permission")
        return permission
    }

    private fun requestCameraPermission() {
        Log.d(TAG, "Requesting camera permission")
        ActivityCompat.requestPermissions(
            this,
            arrayOf(Manifest.permission.CAMERA),
            CAMERA_PERMISSION_REQUEST_CODE
        )
    }

    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<out String>,
        grantResults: IntArray
    ) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        
        if (requestCode == CAMERA_PERMISSION_REQUEST_CODE) {
            if (grantResults.isNotEmpty() && grantResults[0] == PackageManager.PERMISSION_GRANTED) {
                Log.d(TAG, "Camera permission granted in onRequestPermissionsResult")
                startGestureRecognizer("gesture_recognizer.task")
            } else {
                Log.d(TAG, "Camera permission denied in onRequestPermissionsResult")
                Toast.makeText(this, "Camera permission is required to use this feature", Toast.LENGTH_SHORT).show()
            }
        }
    }

    override fun onDestroy() {
        Log.d(TAG, "onDestroy called")
        stopGestureRecognizer()
        super.onDestroy()
    }
}