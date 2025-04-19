import 'package:flutter/material.dart';
import 'package:gunwave/theme/app_colors.dart';
import 'package:gunwave/utils/extensions/list_widget_ex.dart';
import 'package:gunwave/utils/extensions/string_ex.dart';
import 'package:gunwave/widgets/base/base_widget.dart';
import 'package:gunwave/widgets/base/base_widget_model.dart';

abstract class BaseInput extends BaseWidget {
  const BaseInput({
    this.title,
    this.subTitle,
    this.description,
    this.titleStyle,
    this.subTitleStyle,
    this.descriptionStyle,
    super.key,
  });

  final String? title;
  final String? subTitle;
  final String? description;
  final TextStyle? titleStyle;
  final TextStyle? subTitleStyle;
  final TextStyle? descriptionStyle;
}

abstract class BaseInputState<T extends BaseInput, V extends BaseInputModel> extends BaseWidgetState<T, V> {

  @override
  Widget getWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        if (!widget.title.isNullOrEmpty) _buildTitle(),
        getInput(),
        if (!widget.description.isNullOrEmpty) _buildDescription(),
      ].addSpace(8, Axis.vertical),
    );
  }

  Widget _buildTitle() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          widget.title!,
          style: widget.titleStyle ?? textStyles.titleMedium?.copyWith(
            color: model.isValid ? colors.primaryText : kColorError
          )
        ),
        if (!widget.subTitle.isNullOrEmpty)
          Flexible(
            child: Text(
              ' ${widget.subTitle!}',
              style: widget.subTitleStyle ?? textStyles.bodyMedium?.copyWith(
                color: colors.secondaryText
              ),
              overflow: TextOverflow.ellipsis,
            )
          ),
      ],
    );
  }

  Widget _buildDescription() {
    return Text(
      widget.description!,
      style: widget.descriptionStyle ?? textStyles.bodySmall?.copyWith(
        color: model.isValid ? colors.alternate : kColorError.withOpacity(0.75)
      ),
    );
  }

  Widget getInput();

  @override
  V getWidgetModel();
}

abstract class BaseInputModel extends BaseWidgetModel {
  abstract bool isValid;
}