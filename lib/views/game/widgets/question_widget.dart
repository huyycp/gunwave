import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gunwave/data/constants/game/game_color.dart';
import 'package:gunwave/data/constants/game/game_ui.dart';
import 'package:gunwave/data/models/question_model.dart';
import 'package:gunwave/utils/extensions/list_widget_ex.dart';
import 'package:gunwave/views/game/components/sub_components/app_banner.dart';
import 'package:gunwave/widgets/base/base_widget.dart';
import 'package:gunwave/widgets/base/base_widget_model.dart';

class QuestionWidget extends BaseWidget {
  const QuestionWidget(
    this.question, {
    required this.onQuestionAnswered,
    super.key,
  });

  final QuestionModel question;
  final void Function(bool) onQuestionAnswered;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return QuestionWidgetState();
  }
}

class QuestionWidgetState extends BaseWidgetState<QuestionWidget, QuestionWidgetModel> {
  final provider = ChangeNotifierProvider((ref) => QuestionWidgetModel());

  @override
  Widget getWidget() {
    return Container(
      padding: const EdgeInsets.all(16),
      constraints: const BoxConstraints(maxWidth: 800), // Prevent extreme widths
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center, // Center everything
        children: [
          _buildQuestion(),
          const SizedBox(height: 24), // More space between question and answers
          _buildResult(),
        ],
      ),
    );
  }

  Widget _buildQuestion() {
    return Container(
      height: 128, // Set explicit height for banner
      constraints: const BoxConstraints(maxWidth: 700), // Limit width
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Properly position the banner with SizedBox
          SizedBox(
            width: double.infinity, // Take full width
            height: 128, // Fixed height
            child: GameWidget(game: FlameGame(
              children: [AppBanner(
                banner: GameBanners.bannerHorizontal,
                xCount: 11,
                yCount: 2,
              )]
            )),
          ),
          
          // Add padding for text
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 48.0),
            child: Text(
              widget.question.question,
              textAlign: TextAlign.center, // Center the text
              style: GoogleFonts.pressStart2p(
                fontSize: 16,
                color: GameColors.primary,
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildResult() {
    return Container(
      constraints: const BoxConstraints(maxWidth: 700), // Match question width
      child: Row( // Use Row with Expanded for even distribution
        children: <Widget>[
          Expanded(child: _buildResultItem('result_a', widget.question.resultA)),
          const SizedBox(width: 8),
          Expanded(child: _buildResultItem('result_b', widget.question.resultB)),
          const SizedBox(width: 8),
          Expanded(child: _buildResultItem('result_c', widget.question.resultC)),
          const SizedBox(width: 8),
          Expanded(child: _buildResultItem('result_d', widget.question.resultD)),
        ],
      ),
    );
  }

  Widget _buildResultItem(String result, String text) {
    return GestureDetector(
      onTap: () {
        widget.onQuestionAnswered(result == widget.question.answer);
      },
      child: Container(
        // Width controlled by Expanded now
        height: 80, // Fixed height
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(GameBanners.carvedSlide.path),
            fit: BoxFit.fill,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            text,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis, // Handle overflow
            maxLines: 2, // Limit to 2 lines
            style: GoogleFonts.pressStart2p(
              fontSize: 12, // Smaller font to fit
              color: GameColors.primary,
            ),
          ),
        ),
      ),
    );
  }

  @override
  QuestionWidgetModel getWidgetModel() {
    return ref.read(provider);
  }
}

class QuestionWidgetModel extends BaseWidgetModel {

}