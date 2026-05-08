import 'package:flutter/material.dart';
import '../../../data/models/question_model.dart';

/// Handles fillInTheBlanks questions.
/// Parses blanks from the instruction field using "___" as placeholder.
class FillBlanksWidget extends StatefulWidget {
  final Question question;
  final bool isAnswered;
  final void Function(String answer, bool isCorrect) onAnswerSelected;

  const FillBlanksWidget({
    super.key,
    required this.question,
    required this.isAnswered,
    required this.onAnswerSelected,
  });

  @override
  State<FillBlanksWidget> createState() => _FillBlanksWidgetState();
}

class _FillBlanksWidgetState extends State<FillBlanksWidget> {
  late List<TextEditingController> _controllers;
  late List<FocusNode> _focusNodes;

  @override
  void initState() {
    super.initState();
    _initControllers();
  }

  void _initControllers() {
    final count = widget.question.blanksAnswers?.length ?? 1;
    _controllers = List.generate(count, (_) => TextEditingController());
    _focusNodes = List.generate(count, (_) => FocusNode());
  }

  @override
  void didUpdateWidget(FillBlanksWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.question.id != widget.question.id) {
      for (final c in _controllers) {
        c.dispose();
      }
      for (final f in _focusNodes) {
        f.dispose();
      }
      _initControllers();
    }
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  void _notifyParent() {
    final answers = widget.question.blanksAnswers ?? [];
    final userAnswers = _controllers.map((c) => c.text.trim().toLowerCase()).toList();
    final correctAnswers = answers.map((a) => a.toLowerCase()).toList();

    bool allCorrect = userAnswers.length == correctAnswers.length;
    if (allCorrect) {
      for (int i = 0; i < userAnswers.length; i++) {
        if (userAnswers[i] != correctAnswers[i]) {
          allCorrect = false;
          break;
        }
      }
    }

    final joined = userAnswers.join(', ');
    widget.onAnswerSelected(joined, allCorrect);
  }

  Color _fieldColor(int index) {
    if (!widget.isAnswered) return Colors.transparent;
    final answers = widget.question.blanksAnswers ?? [];
    if (index >= answers.length) return Colors.transparent;
    final userAnswer = _controllers[index].text.trim().toLowerCase();
    final correctAnswer = answers[index].toLowerCase();
    return userAnswer == correctAnswer
        ? const Color(0xFF4CAF50).withOpacity(0.15)
        : const Color(0xFFE53935).withOpacity(0.12);
  }

  Color _borderColor(int index) {
    if (!widget.isAnswered) return Colors.grey.shade400;
    final answers = widget.question.blanksAnswers ?? [];
    if (index >= answers.length) return Colors.grey.shade400;
    final userAnswer = _controllers[index].text.trim().toLowerCase();
    final correctAnswer = answers[index].toLowerCase();
    return userAnswer == correctAnswer
        ? const Color(0xFF4CAF50)
        : const Color(0xFFE53935);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final answers = widget.question.blanksAnswers ?? [];

    // Show instruction text with blanks highlighted
    final instruction = widget.question.instruction ?? '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Instruction text block
        if (instruction.isNotEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: theme.colorScheme.outline.withOpacity(0.2),
              ),
            ),
            child: Text(
              instruction,
              style: TextStyle(
                fontSize: 16,
                color: theme.colorScheme.onSurface,
                fontStyle: FontStyle.italic,
                height: 1.6,
              ),
            ),
          ),
        const SizedBox(height: 24),

        // Input fields
        Text(
          'Fill in the blanks:',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurfaceVariant,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 12),
        ...List.generate(answers.length, (index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: theme.colorScheme.primary.withOpacity(0.15),
                  ),
                  child: Center(
                    child: Text(
                      '${index + 1}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    decoration: BoxDecoration(
                      color: _fieldColor(index),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: _borderColor(index), width: 1.5),
                    ),
                    child: TextField(
                      controller: _controllers[index],
                      focusNode: _focusNodes[index],
                      enabled: !widget.isAnswered,
                      onChanged: (_) => _notifyParent(),
                      textInputAction: index < answers.length - 1
                          ? TextInputAction.next
                          : TextInputAction.done,
                      onSubmitted: (_) {
                        if (index < _focusNodes.length - 1) {
                          FocusScope.of(context)
                              .requestFocus(_focusNodes[index + 1]);
                        }
                      },
                      style: TextStyle(
                        fontSize: 16,
                        color: theme.colorScheme.onSurface,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Blank ${index + 1}â€¦',
                        hintStyle: TextStyle(
                          color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        suffixIcon: widget.isAnswered
                            ? Icon(
                                _controllers[index].text.trim().toLowerCase() ==
                                        answers[index].toLowerCase()
                                    ? Icons.check_circle_rounded
                                    : Icons.cancel_rounded,
                                color: _controllers[index].text.trim().toLowerCase() ==
                                        answers[index].toLowerCase()
                                    ? const Color(0xFF4CAF50)
                                    : const Color(0xFFE53935),
                              )
                            : null,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        }),

        // Show correct answers when wrong
        if (widget.isAnswered)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              'Correct: ${answers.join(' / ')}',
              style: const TextStyle(
                color: Color(0xFF4CAF50),
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
      ],
    );
  }
}
