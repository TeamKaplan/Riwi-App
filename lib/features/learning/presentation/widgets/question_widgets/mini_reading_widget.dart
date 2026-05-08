import 'package:flutter/material.dart';
import '../../../data/models/question_model.dart';

/// Mini Reading widget: shows a reading passage, then comprehension questions.
/// Answered with a text field since questions are open-ended.
class MiniReadingWidget extends StatefulWidget {
  final Question question;
  final bool isAnswered;
  final void Function(String answer, bool isCorrect) onAnswerSelected;

  const MiniReadingWidget({
    super.key,
    required this.question,
    required this.isAnswered,
    required this.onAnswerSelected,
  });

  @override
  State<MiniReadingWidget> createState() => _MiniReadingWidgetState();
}

class _MiniReadingWidgetState extends State<MiniReadingWidget> {
  final TextEditingController _controller = TextEditingController();

  @override
  void didUpdateWidget(MiniReadingWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.question.id != widget.question.id) {
      _controller.clear();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _normalize(String s) => s
      .toLowerCase()
      .replaceAll(RegExp(r'[.,!?]'), '')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();

  bool _checkAnswer(String userAnswer) {
    final correct = widget.question.correctAnswer ?? '';
    final correctParts = correct.split(',').map((p) => _normalize(p.trim())).toList();
    final userParts = userAnswer.split(',').map((p) => _normalize(p.trim())).toList();

    if (correctParts.isEmpty) return false;

    // Check if most correct answers are present
    int matched = 0;
    for (final cp in correctParts) {
      for (final up in userParts) {
        if (up.contains(cp) || cp.contains(up)) {
          matched++;
          break;
        }
      }
    }
    return matched >= (correctParts.length / 2).ceil();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final readingText = widget.question.readingText ?? '';
    final instruction = widget.question.instruction ?? '';
    final correct = widget.question.correctAnswer ?? '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Reading passage
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer.withOpacity(0.3),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: theme.colorScheme.primary.withOpacity(0.25),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.menu_book_rounded,
                    color: theme.colorScheme.primary,
                    size: 18,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Reading',
                    style: TextStyle(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                readingText,
                style: TextStyle(
                  fontSize: 15,
                  height: 1.6,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Questions
        if (instruction.isNotEmpty)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Answer these questions:',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 8),
              ...instruction.split(' / ').asMap().entries.map((entry) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${entry.key + 1}. ',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                          fontSize: 14,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          entry.value,
                          style: TextStyle(
                            fontSize: 14,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 16),
            ],
          ),

        // Answer field
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: widget.isAnswered
                  ? (_checkAnswer(_controller.text)
                      ? const Color(0xFF4CAF50)
                      : const Color(0xFFE53935))
                  : theme.colorScheme.outline.withOpacity(0.4),
              width: 1.5,
            ),
            color: widget.isAnswered
                ? (_checkAnswer(_controller.text)
                    ? const Color(0xFF4CAF50).withOpacity(0.08)
                    : const Color(0xFFE53935).withOpacity(0.08))
                : theme.colorScheme.surface,
          ),
          child: TextField(
            controller: _controller,
            enabled: !widget.isAnswered,
            onChanged: (value) {
              widget.onAnswerSelected(value, _checkAnswer(value));
            },
            maxLines: 3,
            style: TextStyle(
              fontSize: 15,
              color: theme.colorScheme.onSurface,
            ),
            decoration: InputDecoration(
              hintText: 'Write your answers here (separate with commas)â€¦',
              hintStyle: TextStyle(
                color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
                fontSize: 14,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(16),
            ),
          ),
        ),

        if (widget.isAnswered)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF4CAF50).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF4CAF50)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.lightbulb_outline, color: Color(0xFF4CAF50)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Expected: $correct',
                      style: const TextStyle(
                        color: Color(0xFF2E7D32),
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
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
