import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gradient_borders/input_borders/gradient_outline_input_border.dart';
import 'package:gunwave/data/constants/game/game_color.dart';
import 'package:gunwave/theme/app_colors.dart';
import 'package:gunwave/utils/extensions/string_ex.dart';
import 'package:gunwave/widgets/base_input.dart';

class AppTextFormField extends BaseInput {
  AppTextFormField({
    super.title,
    super.subTitle,
    super.description,
    super.titleStyle,
    super.subTitleStyle,
    super.descriptionStyle,
    this.padding = const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
    this.borderRadius = const BorderRadius.all(Radius.circular(14)),
    this.validator,
    this.maxLines,
    this.hintText,
    required this.controller,
    required this.statesController,
    this.prefix,
    this.suffix,
    this.readOnly = false,
    this.onTap,
    this.keyboardType,
    this.inputFormatters,
    this.showErrorMessage = false,
    super.key,
  });

  final String? Function(String?)? validator;

  final String? hintText;

  final TextEditingController controller;
  
  final WidgetStatesController statesController;

  final int? maxLines;

  final EdgeInsets padding;
  
  BorderRadius borderRadius;
  
  final Widget? prefix;
  
  final Widget? suffix;
  
  final bool readOnly;
  
  final void Function()? onTap;
  
  final TextInputType? keyboardType;
  
  final List<TextInputFormatter>? inputFormatters;
  
  final bool showErrorMessage;

  @override
  ConsumerState<AppTextFormField> createState() => _AppInputState();
}

class _AppInputState extends BaseInputState<AppTextFormField, AppInputWidgetModel> {
  late final provider = ChangeNotifierProvider((ref) => AppInputWidgetModel(widget.statesController));

  @override
  void onReady() {
    widget.statesController.addListener(() {
      Future.delayed(Duration.zero, () {
        setState(() {});
      });
    });
  }

  @override
  Widget getInput() {
    ref.watch(provider);
    return Container(
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 211, 196, 151),
        // boxShadow: 
        //   (widget.statesController.value.contains(WidgetState.focused) ||
        //   widget.statesController.value.contains(WidgetState.hovered)) &&
        //   !(widget.statesController.value.contains(WidgetState.error) ||
        //   widget.statesController.value.contains(WidgetState.disabled))
        //   ? [
        //     BoxShadow(
        //       color: kColorPrimary.withOpacity(0.5),
        //       blurRadius: 15,
        //     ),
        //   ]
        //   : null,
          borderRadius: BorderRadius.horizontal(
            left: widget.borderRadius.topLeft,
            right: widget.borderRadius.topLeft,
          )
      ),
      child: _textFormField(),
    );
  }

  Widget _textFormField() {
    final enabled = !widget.statesController.value.contains(WidgetState.disabled);
    final decoration = InputDecoration(
      floatingLabelBehavior: FloatingLabelBehavior.always,
      hintText: widget.hintText,
      hintStyle: textStyles.bodyMedium?.copyWith(color: colors.alternate),
      contentPadding: widget.padding,
      prefixIcon: widget.prefix,
      suffixIcon: widget.suffix != null ? Container(padding: EdgeInsets.only(right: widget.padding.right), child: widget.suffix) : null,
      errorStyle: widget.showErrorMessage
        ? textStyles.bodySmall?.copyWith(color: kColorError.withOpacity(0.75))
        : const TextStyle(
          fontSize: 0
        ),
      fillColor: colors.secondaryBackground,
      filled: !enabled,
      border: InputBorder.none,
      enabledBorder: enableBorder,
      focusedBorder: enableBorder,
      // disabledBorder: disabledBorder,
      // errorBorder: errorBorder,
      focusedErrorBorder: errorBorder,
    );
    final formatter = widget.inputFormatters ?? [
      if (widget.keyboardType == const TextInputType.numberWithOptions(decimal: true))
        ...[
          FilteringTextInputFormatter.allow(RegExp(r'^\d*[\.\,]?\d*')),
          CommaToDotFormatter(),
        ],
      if (widget.keyboardType == TextInputType.number)
        FilteringTextInputFormatter.digitsOnly
    ];
    return TextFormField(
      showCursor: true,
      enabled: enabled,
      validator: widget.validator,
      controller: widget.controller,
      keyboardType: widget.keyboardType,
      statesController: widget.statesController,
      readOnly: widget.readOnly,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      maxLines: widget.maxLines,
      onTap: widget.onTap,
      inputFormatters: formatter,
      decoration: decoration,
      style: GoogleFonts.pressStart2p(
        color:GameColors.primary,
        fontSize: 12,
      ),
    );
  }

  InputBorder get enableBorder => OutlineInputBorder(
    borderRadius: widget.borderRadius,
    borderSide: BorderSide(
      color: colors.border
    ),
  );

  InputBorder get focusedBorder => GradientOutlineInputBorder(
    borderRadius: widget.borderRadius,
    gradient: const LinearGradient(colors: [kColorPrimary, kColorSecondary]),
  );

  InputBorder get disabledBorder => OutlineInputBorder(
    borderRadius: widget.borderRadius,
    borderSide: BorderSide(
      color: colors.border,
    ),
  );

  InputBorder get errorBorder => OutlineInputBorder(
    borderRadius: widget.borderRadius,
    borderSide: const BorderSide(
      color: kColorError
    ),
  );

  InputBorder get exactBorder => OutlineInputBorder(
    borderRadius: widget.borderRadius,
    borderSide: const BorderSide(
      color: kColorSuccess
    )
  );

  @override
  AppInputWidgetModel getWidgetModel() {
    return ref.read(provider);
  }
}

class AppInputWidgetModel extends BaseInputModel {
  AppInputWidgetModel(this.statesController);

  final WidgetStatesController statesController;
  
  @override
  bool get isValid => !statesController.value.contains(WidgetState.error);
  
  @override
  set isValid(_) {}

  int increase(int value) => ++value;
  int decrease(int value) => --value;
}