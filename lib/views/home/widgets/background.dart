import 'dart:async';
import 'package:flame/components.dart';
import 'package:flame_tiled/flame_tiled.dart';

class Background extends World {
  Background({
    required this.screenSize,
  });

  final Vector2 screenSize;
  
  // Original background image dimensions
  final double originalWidth = 1920;
  final double originalHeight = 1088;

  @override
  FutureOr<void> onLoad() async {
    // Calculate scaling factors
    final scaleX = screenSize.x / originalWidth;
    final scaleY = screenSize.y / originalHeight;
    
    // Use the LARGER scale to ensure the screen is fully covered
    final scale = scaleX > scaleY ? scaleX : scaleY;
    
    // Load the tiled component
    final component = await TiledComponent.load(
      'background.tmx',
      Vector2.all(64),
    );
    
    // Scale the component to cover screen
    component.scale = Vector2.all(scale);
    
    // Center the background to ensure even cropping on both sides
    final scaledWidth = originalWidth * scale;
    final scaledHeight = originalHeight * scale;
    
    // Center horizontally
    component.position.x = (screenSize.x - scaledWidth) / 2;
    
    // Center vertically
    component.position.y = (screenSize.y - scaledHeight) / 2;
    
    add(component);
    return super.onLoad();
  }
}