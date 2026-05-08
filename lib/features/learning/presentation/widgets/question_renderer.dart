import 'package:flutter/material.dart';
import '../../data/models/question_model.dart';
import 'question_widgets/multiple_choice_widget.dart';
import 'question_widgets/fill_blanks_widget.dart';
import 'question_widgets/true_false_widget.dart';
import 'question_widgets/matching_widget.dart';
import 'question_widgets/order_words_widget.dart';
import 'question_widgets/mini_reading_widget.dart';
import 'question_widgets/complete_code_widget.dart';
import 'question_widgets/complete_word_widget.dart';
import 'question_widgets/error_correction_widget.dart';
import 'question_widgets/complete_dialogue_widget.dart';
import 'question_widgets/short_writing_widget.dart';

/// Central dispatcher: given a [Question], renders the correct interactive widget.
/// All widgets call [onAnswerSelected] when the user submits/changes their answer.
class QuestionRenderer extends StatelessWidget {
  final Question question;
  final bool isAnswered;
  final void Function(String answer, bool isCorrect) onAnswerSelected;

  const QuestionRenderer({
    super.key,
    required this.question,
    required this.isAnswered,
    required this.onAnswerSelected,
  });

  @override
  Widget build(BuildContext context) {
    switch (question.type) {
      case QuestionType.multipleChoice:
      case QuestionType.chooseCorrect:
        return MultipleChoiceWidget(
          question: question,
          isAnswered: isAnswered,
          onAnswerSelected: onAnswerSelected,
        );

      case QuestionType.fillInTheBlanks:
        return FillBlanksWidget(
          question: question,
          isAnswered: isAnswered,
          onAnswerSelected: onAnswerSelected,
        );

      case QuestionType.trueFalse:
        return TrueFalseWidget(
          question: question,
          isAnswered: isAnswered,
          onAnswerSelected: onAnswerSelected,
        );

      case QuestionType.matching:
        return MatchingWidget(
          question: question,
          isAnswered: isAnswered,
          onAnswerSelected: onAnswerSelected,
        );

      case QuestionType.orderWords:
        return OrderWordsWidget(
          question: question,
          isAnswered: isAnswered,
          onAnswerSelected: onAnswerSelected,
        );

      case QuestionType.miniReading:
        return MiniReadingWidget(
          question: question,
          isAnswered: isAnswered,
          onAnswerSelected: onAnswerSelected,
        );

      case QuestionType.completeCode:
        return CompleteCodeWidget(
          question: question,
          isAnswered: isAnswered,
          onAnswerSelected: onAnswerSelected,
        );

      case QuestionType.completeWord:
        return CompleteWordWidget(
          question: question,
          isAnswered: isAnswered,
          onAnswerSelected: onAnswerSelected,
        );

      case QuestionType.errorCorrection:
        return ErrorCorrectionWidget(
          question: question,
          isAnswered: isAnswered,
          onAnswerSelected: onAnswerSelected,
        );

      case QuestionType.completeDialogue:
        return CompleteDialogueWidget(
          question: question,
          isAnswered: isAnswered,
          onAnswerSelected: onAnswerSelected,
        );

      case QuestionType.shortWriting:
        return ShortWritingWidget(
          question: question,
          isAnswered: isAnswered,
          onAnswerSelected: onAnswerSelected,
        );
    }
  }
}
