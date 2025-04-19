import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'base_widget.dart';

abstract class BaseWidgetModel<T extends BaseWidgetState<dynamic, dynamic>> extends ChangeNotifier {

  dynamic empty;

  T? view;

  bool showConnectWalletDialog = false;
  bool showVerifyWalletDialog = false;

  BuildContext get context => view!.context;

  WidgetRef get ref => view!.ref;

  // Add global repo here

  void attachView(T view) {
    this.view = view;
  }

  void detachView() {
    view = null;
  }

  void requestConnectWallet() {
    showConnectWalletDialog = true;
    notifyListeners();
  }
}
