import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gunwave/views/splash/splash_view_model.dart';
import 'package:gunwave/widgets/base/base_view.dart';

class SplashView extends BaseView {
  const SplashView({super.key});

  @override
  ConsumerState<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends BaseViewState<SplashView, SplashViewModel> {
  @override
  void onReady() {
    super.onReady();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(seconds: 1), () {
        openApp();
      });
    });
  }
  
  @override
  Widget getView() {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              '',
              width: 160,
              height: 160,
            ),
            const SizedBox(height: 24),
            Text(
              'LuckyPool',
              style: Theme.of(context).textTheme.displaySmall
            ),
          ],
        ),
      ),
    );
  }

  @override
  SplashViewModel getViewModel() {
    return ref.read(splashViewModel);
  }
}