import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gunwave/recognizer_test.dart';
import 'package:gunwave/views/home/home_view_model.dart';
import 'package:gunwave/widgets/base/base_view.dart';

class HomeView extends BaseView {
  const HomeView({super.key});

  @override
  ConsumerState<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends BaseViewState<HomeView, HomeViewModel> {
  @override
  Widget getView() {
    return GestureRecognizerApp();
  }

  @override
  HomeViewModel getViewModel() {
    return ref.read(homeViewModel);
  }
}