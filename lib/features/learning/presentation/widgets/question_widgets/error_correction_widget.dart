import 'package:flutter/material.dart';
import '../../../data/models/question_model.dart';

/// Error Correction widget: user sees a sentence with an error
/// and types the corrected version.
class ErrorCorrectionWidget extends StatefulWidget {
  final Question question;
  final bool isAnswered;
  final void Function(String answer, bool isCorrect) onAnswerSelected;

  const ErrorCorrectionWidget({
    super.key,
    required this.question,
    required this.isAnswered,
    required this.onAnswerSelected,
  });

  @override
  State<ErrorCorrectionWidget> createState() => _ErrorCorrectionWidgetState();
}

class _ErrorCorrectionWidgetState extends State<ErrorCorrectionWidget> {
  final TextEditingController _controller = TextEditingController();

  @override
  void didUpdateWidget(ErrorCorrectionWidget oldWidget) {
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

  String _normalize(String s) =>
      s.toLowerCase().replaceAll(RegExp(r'[.,!?]'), '').trim();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final wrongSentence = widget.question.instruction ?? widget.question.prompt;
    final correct = widget.question.correctAnswer ?? '';
    final isCorrect = _normalize(_controller.text) == _normalize(correct);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Wrong sentence with error highlight
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFE53935).withOpacity(0.06),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: const Color(0xFFE53935).withOpacity(0.3),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.error_outline,
                      color: Color(0xFFE53935), size: 16),
                  const SizedBox(width: 6),
                  Text(
                    'Find and fix the error:',
                    style: TextStyle(
                      color: const Color(0xFFE53935).withOpacity(0.8),
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                wrongSentence,
                style: TextStyle(
                  fontSize: 17,
                  fontStyle: FontStyle.italic,
                  color: theme.colorScheme.onSurface,
                  height: 1.5,
                  decoration: TextDecoration.underline,
                  decorationColor: const Color(0xFFE53935).withOpacity(0.5),
                  decorationStyle: TextDecorationStyle.wavy,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Correction input
        Text(
          'Write the correct sentence:',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 10),
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
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
                    ? const Color(0xFF4CAF50).withOpacity(0.08)
                    : const Color(0xFFE53935).withOpacity(0.08))
                : theme.colorScheme.surface,
          ),
          child: TextField(
            controller: _controller,
            enabled: !widget.isAnswered,
            onChanged: (val) {
              final ok = _normalize(val) == _normalize(correct);
              widget.onAnswerSelected(val, ok);
            },
            style: TextStyle(
              fontSize: 16,
              color: theme.colorScheme.onSurface,
            ),
            maxLines: 2,
            decoration: InputDecoration(
              hintText: 'Write the corrected sentenceâ€¦',
              hintStyle: TextStyle(
                color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(16),
              suffixIcon: widget.isAnswered
                  ? Icon(
                      isCorrect
                          ? Icons.check_circle_rounded
                          : Icons.cancel_rounded,
                      color: isCorrect
                          ? const Color(0xFF4CAF50)
                          : const Color(0xFFE53935),
                    )
                  : null,
            ),
          ),
        ),

        if (widget.isAnswered)
          Padding(
            padding: const EdgeInsets.only(top: 14),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF4CAF50).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF4CAF50)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle, color: Color(0xFF4CAF50)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      correct,
                      style: const TextStyle(
                        color: Color(0xFF2E7D32),
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
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
