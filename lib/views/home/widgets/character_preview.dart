import 'dart:async';
import 'package:flame/components.dart';
import 'package:flame/game.dart';  // Make sure this is imported
import 'package:flutter/material.dart';
import 'package:gunwave/data/constants/game/game_character.dart';

class CharacterPreview extends FlameGame with HasGameRef<FlameGame> {

  CharacterPreview({
    required this.character,
  });

  final GameCharacter character;
  
  @override
  FutureOr<void> onLoad() async {
    await game.images.loadAllImages();

    final component = SpriteAnimationComponent(
      animation: SpriteAnimation.fromFrameData(
        game.images.fromCache(character.path),
        SpriteAnimationData.sequenced(
          amount: 6,
          stepTime: 0.08,
          textureSize: Vector2.all(192),
          loop: true,
        ),
      ),
      size: Vector2.all(64),
      anchor: Anchor.topLeft,
    );

    component.scale = Vector2(6, 6);
    
    
    add(component);
    return super.onLoad();
  }
  
  @override
  Color backgroundColor() => Colors.transparent;
}