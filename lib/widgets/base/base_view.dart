import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:gunwave/routes.dart';
import 'base_view_model.dart';
import 'base_widget.dart';

abstract class BaseView extends BaseWidget {
  const BaseView({super.key});
}

abstract class BaseViewState<T extends BaseView, V extends BaseViewModel>
    extends BaseWidgetState<T, V> {

  @override
  Widget getWidget() {
    return getView();
  }

  @override
  V getWidgetModel() => getViewModel();

  Widget getView();

  V getViewModel();

  void onForeground() {}

  void openApp() {
    context.go(Routes.home);
  }
}