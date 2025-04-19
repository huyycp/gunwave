import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class GestureRecognizerApp extends StatefulWidget {
  @override
  _GestureRecognizerAppState createState() => _GestureRecognizerAppState();
}

class _GestureRecognizerAppState extends State<GestureRecognizerApp> {
  static const MethodChannel _channel = MethodChannel('gesture_recognizer');
  String _recognizedGesture = "No gesture recognized";
  bool _isRecognizing = false;

  @override
  void initState() {
    super.initState();
    _setupMethodChannel();
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
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Gesture Recognizer'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: _isRecognizing ? null : _startGestureRecognition,
                child: const Text('Start Recognition'),
              ),
              ElevatedButton(
                onPressed: _isRecognizing ? _stopGestureRecognition : null,
                child: const Text('Stop Recognition'),
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
    );
  }
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(GestureRecognizerApp());
}