import 'package:flutter/material.dart';

extension WidgetStatesControllerEx on WidgetStatesController {
  bool get isValid => !value.contains(WidgetState.error);
}