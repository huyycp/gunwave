import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gunwave/views/game/pixel_adventure.dart';
import 'package:gunwave/views/test_recognizer/test_recognizer.dart';
import 'package:gunwave/views/home/home_view_model.dart';
import 'package:gunwave/widgets/app_button.dart';
import 'package:gunwave/widgets/base/base_view.dart';

class HomeView extends BaseView {
  const HomeView({super.key});

  @override
  ConsumerState<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends BaseViewState<HomeView, HomeViewModel> {
  @override
  Widget getView() {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AppButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => GameWidget(game: PixelAdventure()),
                  ),
                );
              },
              child: const Text('Game'),
            ),
            const SizedBox(height: 24),
            AppButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const GestureRecognizerApp(),
                  ),
                );
              },
              child: const Text('Test Recognizer'),
            )
          ],
        )
      ),
    );
  }

  @override
  HomeViewModel getViewModel() {
    return ref.read(homeViewModel);
  }
}