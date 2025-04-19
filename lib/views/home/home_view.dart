import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Home',
              style: Theme.of(context).textTheme.displaySmall
            ),
          ],
        ),
      ),
    );
  }

  @override
  HomeViewModel getViewModel() {
    return ref.read(homeViewModel);
  }
}