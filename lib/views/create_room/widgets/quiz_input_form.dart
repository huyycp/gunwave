import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/src/consumer.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gunwave/data/constants/game/game_color.dart';
import 'package:gunwave/data/dtos/req/create_room_req.dart';
import 'package:gunwave/data/models/quiz_model.dart';
import 'package:gunwave/routes.dart';
import 'package:gunwave/utils/common_functions.dart';
import 'package:gunwave/widgets/app_text_form_field.dart';
import 'package:gunwave/widgets/base/base_widget.dart';
import 'package:gunwave/widgets/base/base_widget_model.dart';
import 'package:gunwave/widgets/game/game_button.dart';

class QuizInputForm extends BaseWidget {
  const QuizInputForm(this.onSubmit, {super.key});

  final void Function(CreateQuizReq) onSubmit;

  static void show(void Function(CreateQuizReq) onSubmit) {
    showAppModalBottomSheet(
      navigatorKey.currentContext!,
      QuizInputForm(onSubmit),
    );
  }

  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return QuizInputFormState();
  }
}

class QuizInputFormState extends BaseWidgetState<QuizInputForm, QuizInputFormModel> {
  late final provider = ChangeNotifierProvider((ref) => QuizInputFormModel(widget.onSubmit));
  
  @override
  Widget getWidget() {
    ref.watch(provider);
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Color.fromARGB(255, 211, 196, 151),
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            spacing: 16,
            children: [
              AppTextFormField(
                title: 'Question',
                titleStyle: GoogleFonts.pressStart2p(
                  color:  GameColors.primary,
                  fontSize: 16,
                ),
                controller: model.questionController,
                statesController: model.questionStateController,
              ),
              AppTextFormField(
                title: 'Option A',
                titleStyle: GoogleFonts.pressStart2p(
                  color:  GameColors.primary,
                  fontSize: 16,
                ),
                controller: model.optionAController,
                statesController: model.optionAStateController,
              ),
              AppTextFormField(
                title: 'Option B',
                titleStyle: GoogleFonts.pressStart2p(
                  color:  GameColors.primary,
                  fontSize: 16,
                ),
                controller: model.optionBController,
                statesController: model.optionBStateController,
              ),
              AppTextFormField(
                title: 'Option C',
                titleStyle: GoogleFonts.pressStart2p(
                  color:  GameColors.primary,
                  fontSize: 16,
                ),
                controller: model.optionCController,
                statesController: model.optionCStateController,
              ),
              AppTextFormField(
                title: 'Option D',
                titleStyle: GoogleFonts.pressStart2p(
                  color:  GameColors.primary,
                  fontSize: 16,
                ),
                controller: model.optionDController,
                statesController: model.optionDStateController,
              ),
              _buildAnswerSelector(),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  GameButton(
                    onPressed: () {
                      model.submit();
                      context.pop();
                    },
                    child: const Text('Submit'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnswerSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Answer',
          style: GoogleFonts.pressStart2p(
            color: GameColors.primary,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 8),
        Row(  // Changed from Wrap to Row
          children: [
            Expanded(child: _buildRadioOption('A', 0)),
            Expanded(child: _buildRadioOption('B', 1)),
            Expanded(child: _buildRadioOption('C', 2)),
            Expanded(child: _buildRadioOption('D', 3)),
          ],
        ),
      ],
    );
  }

  Widget _buildRadioOption(String label, int value) {
    final isSelected = model.answer == value;
    return InkWell(
      onTap: () => model.selectAnswer(value),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Radio<int>(
            value: value,
            groupValue: model.answer,
            onChanged: (val) => model.selectAnswer(val!),
            fillColor: MaterialStateProperty.resolveWith(
              (states) => states.contains(MaterialState.selected) 
                ? GameColors.primary 
                : GameColors.primary.withOpacity(0.6),
            ),
          ),
          Text(
            label,
            style: GoogleFonts.pressStart2p(
              color: isSelected ? GameColors.primary : GameColors.primary.withOpacity(0.8),
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
 
  @override
  QuizInputFormModel getWidgetModel() {
    return ref.read(provider);
  }
}

class QuizInputFormModel extends BaseWidgetModel {
  QuizInputFormModel(this.onSubmit);

  final void Function(CreateQuizReq) onSubmit;

  final questionController = TextEditingController();
  final optionAController = TextEditingController();
  final optionBController = TextEditingController();
  final optionCController = TextEditingController();
  final optionDController = TextEditingController();

  final questionStateController = WidgetStatesController();
  final optionAStateController = WidgetStatesController();
  final optionBStateController = WidgetStatesController();
  final optionCStateController = WidgetStatesController();
  final optionDStateController = WidgetStatesController();

  /// 0 for A, 1 for B, 2 for C, 3 for D
  int answer = 0;

  void selectAnswer(int value) {
    answer = value;
    notifyListeners();
  }

  void submit() {
    final question = questionController.text.trim();
    final optionA = optionAController.text.trim();
    final optionB = optionBController.text.trim();
    final optionC = optionCController.text.trim();
    final optionD = optionDController.text.trim();

    if (question.isEmpty || optionA.isEmpty || optionB.isEmpty || optionC.isEmpty || optionD.isEmpty) {
      // Handle error: all fields must be filled
      return;
    }

    final quizModel = CreateQuizReq(
      question: question,
      resultA: optionA,
      resultB: optionB,
      resultC: optionC,
      resultD: optionD,
      answer: answer == 0 ? "result_a" : 
          answer == 1 ? "result_b" : 
          answer == 2 ? "result_c" : "result_d",
    );

    onSubmit(quizModel);
  }
}