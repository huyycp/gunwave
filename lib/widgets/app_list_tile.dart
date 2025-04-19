import 'package:flutter/material.dart';
import 'package:gunwave/theme/app_colors.dart';
import 'package:gunwave/theme/text_theme.dart';
import 'package:gunwave/utils/extensions/build_context_ex.dart';
import 'package:gunwave/utils/extensions/list_widget_ex.dart';

class AppListTile extends StatelessWidget {
  AppListTile({
    super.key,
    this.title = '',
    this.subTitle = '',
    this.leading,
    this.trailing,
    this.leadingTitleSpacing = 12,
    this.titleSubtitleSpacing = 4,
    this.trailingTitleSpacing = 12,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    this.backgroundColors = const [],
    this.borderRadius = const BorderRadius.all(Radius.circular(8)),
    this.border = const Border(),
    this.titleStyle,
    this.subTitleStyle,
    this.tags = const [],
    this.titleAlign = TextAlign.start,
    this.subTitleAlign = TextAlign.start,
    this.titleTrailing,
    this.subTitleTrailing,
  }) : assert (
    title.isNotEmpty || 
    subTitle.isNotEmpty ||
    leading != null ||
    trailing != null
  );

  final String title;

  final String subTitle;

  final Widget? leading;

  final Widget? trailing;

  /// Space between [leading] and [title]
  final double leadingTitleSpacing;

  /// Space between [title] and [subTitle]
  final double titleSubtitleSpacing;

  /// Space between [title] and [trailing]
  final double trailingTitleSpacing;

  final EdgeInsets padding;

  /// If [backgroundColors] only contains more than 1 color,
  /// the background is gradient 
  final List<Color> backgroundColors;

  final BorderRadius borderRadius;

  final BoxBorder border;

  final TextStyle? titleStyle;

  final TextStyle? subTitleStyle;

  final List<String> tags;

  final TextAlign titleAlign;

  final TextAlign subTitleAlign;

  final Widget? titleTrailing;

  final Widget? subTitleTrailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        gradient: backgroundColors.length >= 2 ? LinearGradient(colors: backgroundColors) : null,
        color: backgroundColors.isNotEmpty ? backgroundColors.first : null,
        borderRadius: borderRadius,
        border: border,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          if (leading != null) ...[
            leading!,
            SizedBox(width: leadingTitleSpacing),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                if (title.isNotEmpty) _buildTitle(context),
                if (subTitle.isNotEmpty) _buildSubtitle(context),
              ].addSpace(titleSubtitleSpacing, Axis.vertical),
            ),
          ),
          if (trailing != null) ...[
            SizedBox(width: trailingTitleSpacing),
            trailing!,
          ],
        ],
      ),
    );
  }

  Widget _buildTitle(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Flexible(
          child: Text(
            title,
            textAlign: titleAlign,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: titleStyle ?? BaseTextTheme.textTheme.titleMedium?.copyWith(color: context.appColors.primaryText),
          ),
        ),
        if (tags.isNotEmpty) _buildTags(context),
        if (titleTrailing != null) titleTrailing!,
      ].addSpace(8, Axis.horizontal),
    );
  }

  Widget _buildSubtitle(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Flexible(
          child: Text(
            subTitle,
            textAlign: subTitleAlign,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: subTitleStyle ?? BaseTextTheme.textTheme.bodySmall?.copyWith(color: context.appColors.secondaryText),
          ),
        ),
        if (subTitleTrailing != null) subTitleTrailing!,
      ].addSpace(8, Axis.horizontal), 
    );
  }

  Widget _buildTags(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: tags.map(
        (tag) => Container(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: kColorWarning.withOpacity(0.25),
            borderRadius: BorderRadius.circular(100),
          ),
          child: Text(
            tag,
            style: context.textStyles.labelSmall?.copyWith(color: kColorWarning)
          ),
        )
      ).toList(),
    );
  }
}