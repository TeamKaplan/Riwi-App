import 'package:flutter/material.dart';
import '../../../data/models/question_model.dart';

/// Short Writing widget: user writes a free-text response.
/// Evaluation is lenient (checks for keyword presence).
class ShortWritingWidget extends StatefulWidget {
  final Question question;
  final bool isAnswered;
  final void Function(String answer, bool isCorrect) onAnswerSelected;

  const ShortWritingWidget({
    super.key,
    required this.question,
    required this.isAnswered,
    required this.onAnswerSelected,
  });

  @override
  State<ShortWritingWidget> createState() => _ShortWritingWidgetState();
}

class _ShortWritingWidgetState extends State<ShortWritingWidget> {
  final TextEditingController _controller = TextEditingController();
  int _wordCount = 0;

  @override
  void didUpdateWidget(ShortWritingWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.question.id != widget.question.id) {
      _controller.clear();
      setState(() => _wordCount = 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool _checkAnswer(String userAnswer) {
    if (userAnswer.trim().isEmpty) return false;
    final correct = widget.question.correctAnswer ?? '';
    if (correct.isEmpty) {
      // No correct answer defined: accept if >= 5 words
      return userAnswer.trim().split(RegExp(r'\s+')).length >= 3;
    }
    // Check if user answer contains keywords from the correct answer
    final keywords = correct
        .toLowerCase()
        .split(RegExp(r'[\s,.]'))
        .where((w) => w.length > 3)
        .toList();
    final userLower = userAnswer.toLowerCase();
    final matchCount = keywords.where((k) => userLower.contains(k)).length;
    return matchCount >= (keywords.length / 2).ceil() || matchCount >= 2;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final instruction = widget.question.instruction ?? '';
    final correct = widget.question.correctAnswer ?? '';
    final isCorrect = _checkAnswer(_controller.text);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Instruction / prompt
        if (instruction.isNotEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer.withOpacity(0.2),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                  color: theme.colorScheme.primary.withOpacity(0.2)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.edit_note,
                    color: theme.colorScheme.primary, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    instruction,
                    style: TextStyle(
                      fontSize: 15,
                      height: 1.5,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ),
              ],
            ),
          ),

        // Writing area
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: widget.isAnswered
                  ? (isCorrect
                      ? const Color(0xFF4CAF50)
                      : const Color(0xFFE53935))
                  : theme.colorScheme.outline.withOpacity(0.4),
              width: 1.5,
            ),
            color: widget.isAnswered
                ? (isCorrect
                    ? const Color(0xFF4CAF50).withOpacity(0.06)
                    : const Color(0xFFE53935).withOpacity(0.06))
                : theme.colorScheme.surface,
          ),
          child: Column(
            children: [
              TextField(
                controller: _controller,
                enabled: !widget.isAnswered,
                onChanged: (val) {
                  setState(() {
                    _wordCount =
                        val.trim().isEmpty ? 0 : val.trim().split(RegExp(r'\s+')).length;
                  });
                  widget.onAnswerSelected(val, _checkAnswer(val));
                },
                maxLines: 5,
                style: TextStyle(
                  fontSize: 15,
                  height: 1.6,
                  color: theme.colorScheme.onSurface,
                ),
                decoration: InputDecoration(
                  hintText: 'Write your answer hereâ€¦',
                  hintStyle: TextStyle(
                    color:
                        theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.all(16),
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.only(right: 16, bottom: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Icon(
                      Icons.text_fields,
                      size: 14,
                      color:
                          theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '$_wordCount word${_wordCount != 1 ? 's' : ''}',
                      style: TextStyle(
                        fontSize: 12,
                        color: theme.colorScheme.onSurfaceVariant
                            .withOpacity(0.5),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        if (widget.isAnswered && correct.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 14),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF4CAF50).withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF4CAF50)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.lightbulb_outline,
                          color: Color(0xFF4CAF50), size: 16),
                      SizedBox(width: 6),
                      Text(
                        'Model answer:',
                        style: TextStyle(
                          color: Color(0xFF2E7D32),
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    correct,
                    style: const TextStyle(
                      color: Color(0xFF2E7D32),
                      fontSize: 13,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
