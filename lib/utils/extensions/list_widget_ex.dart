import 'package:flutter/material.dart';

extension ListWidgetEx on List<Widget> {
  List<Widget> addSpace(double space, Axis axis, {bool extendStart = false, bool extendEnd = false}) {
    void insertSpace(int index) {
      insert(
        index,
        axis == Axis.horizontal
          ? SizedBox(width: space)
          : SizedBox(height: space)
      );
    }
    
    if (length > 1) {
      for (int i = 1; i < length; i += 2) {
        insertSpace(i);
      }
    }
    if (extendStart) insertSpace(0);
    if (extendEnd) insertSpace(length);
    return this;
  }
}