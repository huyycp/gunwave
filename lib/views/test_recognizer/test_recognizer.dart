import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class GestureRecognizerApp extends StatefulWidget {
  const GestureRecognizerApp({super.key});

  @override
  State createState() => _GestureRecognizerAppState();
}

class _GestureRecognizerAppState extends State<GestureRecognizerApp> with WidgetsBindingObserver {
  static const MethodChannel _channel = MethodChannel('gesture_recognizer');
  String _recognizedGesture = "No gesture recognized";
  bool _isRecognizing = false;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    
    // Register for app lifecycle events
    WidgetsBinding.instance.addObserver(this);
    
    // Force landscape WITHOUT using MediaQuery
    _setLandscapeOrientation();
    
    _setupMethodChannel();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    // Safe to use MediaQuery here
    if (_isInitialized) {
      _checkAndForceOrientation();
    }
    _isInitialized = true;
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Re-enforce landscapeRight orientation whenever app state changes
    if (state == AppLifecycleState.resumed) {
      _setLandscapeOrientation();
      debugPrint("📱 Re-enforced landscape right orientation after resume");
    } else if (state == AppLifecycleState.inactive) {
      // Force landscape even when app becomes inactive
      _setLandscapeOrientation();
    }
  }

  // This method doesn't use context or MediaQuery
  void _setLandscapeOrientation() {
    debugPrint("📱 Setting app to landscape right orientation");
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }
  
  // This method uses MediaQuery and should only be called after initState
  void _checkAndForceOrientation() {
    if (!mounted) return;
    
    final orientation = MediaQuery.of(context).orientation;
    final size = MediaQuery.of(context).size;
    debugPrint("Current orientation: ${orientation == Orientation.landscape ? 'LANDSCAPE' : 'PORTRAIT'}, size: ${size.width.toInt()}x${size.height.toInt()}");
    
    // If somehow not in landscape, force it again after a delay
    if (orientation != Orientation.landscape) {
      debugPrint("⚠️ Detected portrait orientation - forcing landscape");
      Future.delayed(const Duration(milliseconds: 100), () {
        _setLandscapeOrientation();
      });
    }
  }

  void _setupMethodChannel() {
    _channel.setMethodCallHandler((call) async {
      if (call.method == "onGestureRecognized") {
        setState(() {
          _recognizedGesture = call.arguments as String;
          debugPrint("Gesture recognized: $_recognizedGesture");
        });
      }
    });
  }
  
  void _startGestureRecognition() async {
    if (_isRecognizing) return;
    
    try {
      await _channel.invokeMethod('startGestureRecognition');
      setState(() {
        _isRecognizing = true;
      });
    } catch (e) {
      debugPrint('Failed to start gesture recognition: $e');
    }
  }

  void _stopGestureRecognition() async {
    if (!_isRecognizing) return;
    
    try {
      await _channel.invokeMethod('stopGestureRecognition');
      setState(() {
        _isRecognizing = false;
      });
    } catch (e) {
      debugPrint('Failed to stop gesture recognition: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Safe to check orientation here
    _checkAndForceOrientation();
    
    return MaterialApp(
      builder: (context, child) {
        // Check orientation when rebuilding
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _checkAndForceOrientation();
        });
        return child!;
      },
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Gesture Recognizer'),
        ),
        body: Stack(
          children: [
            Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Add orientation information display
                    Text(
                      'Orientation: ${MediaQuery.of(context).orientation == Orientation.landscape ? "LANDSCAPE" : "PORTRAIT"}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                    Text(
                      'Size: ${MediaQuery.of(context).size.width.toInt()}x${MediaQuery.of(context).size.height.toInt()}',
                      style: const TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 10),
                    
                    // Updated instruction - no need to rotate hand
                    
                    const SizedBox(height: 20),
                    
                    // Existing buttons
                    ElevatedButton(
                      onPressed: _isRecognizing ? null : _startGestureRecognition,
                      child: const Text('Start Recognition'),
                    ),
                    ElevatedButton(
                      onPressed: _isRecognizing ? _stopGestureRecognition : null,
                      child: const Text('Stop Recognition'),
                    ),
                    
                    // Add status indicator
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 10),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: _isRecognizing ? Colors.green[100] : Colors.grey[200],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _isRecognizing ? Icons.videocam : Icons.videocam_off,
                            color: _isRecognizing ? Colors.green : Colors.grey,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _isRecognizing ? 'Recognition active' : 'Recognition inactive',
                            style: TextStyle(
                              color: _isRecognizing ? Colors.green[800] : Colors.grey[800],
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 20),
                    const Text(
                      'Recognized Gesture:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _recognizedGesture,
                      style: const TextStyle(
                        fontSize: 24,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Updated hand orientation guide - showing natural hand position
            if (_isRecognizing)
              Positioned(
                right: 20,
                bottom: 20,
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.pan_tool, color: Colors.white),
                          SizedBox(width: 5),
                          Text(
                            'Hand Usage',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      SizedBox(height: 5),
                      Row(
                        children: [
                          Icon(Icons.pan_tool, color: Colors.green),
                          SizedBox(width: 5),
                          Text('Natural Position', style: TextStyle(color: Colors.green)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}