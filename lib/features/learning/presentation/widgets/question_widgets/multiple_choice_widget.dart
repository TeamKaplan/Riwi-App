import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../data/models/question_model.dart';

class MultipleChoiceWidget extends StatefulWidget {
  final Question question;
  final bool isAnswered;
  final void Function(String answer, bool isCorrect) onAnswerSelected;

  const MultipleChoiceWidget({
    super.key,
    required this.question,
    required this.isAnswered,
    required this.onAnswerSelected,
  });

  @override
  State<MultipleChoiceWidget> createState() => _MultipleChoiceWidgetState();
}

class _MultipleChoiceWidgetState extends State<MultipleChoiceWidget> {
  int? _selectedIndex;

  @override
  void didUpdateWidget(MultipleChoiceWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.question.id != widget.question.id) {
      setState(() => _selectedIndex = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final options = widget.question.options ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: List.generate(options.length, (index) {
        final option = options[index];
        final isSelected = _selectedIndex == index;
        final isCorrect = option.isCorrect;

        Color borderColor = theme.colorScheme.outline.withOpacity(0.3);
        Color bgColor = theme.colorScheme.surface;
        Color textColor = theme.colorScheme.onSurface;
        Widget? trailingIcon;

        if (widget.isAnswered && isSelected) {
          if (isCorrect) {
            borderColor = const Color(0xFF4CAF50);
            bgColor = const Color(0xFF4CAF50).withOpacity(0.15);
            textColor = const Color(0xFF2E7D32);
            trailingIcon = const Icon(Icons.check_circle_rounded, color: Color(0xFF4CAF50));
          } else {
            borderColor = const Color(0xFFE53935);
            bgColor = const Color(0xFFE53935).withOpacity(0.12);
            textColor = const Color(0xFFB71C1C);
            trailingIcon = const Icon(Icons.cancel_rounded, color: Color(0xFFE53935));
          }
        } else if (widget.isAnswered && isCorrect) {
          borderColor = const Color(0xFF4CAF50);
          bgColor = const Color(0xFF4CAF50).withOpacity(0.08);
          textColor = const Color(0xFF2E7D32);
        } else if (isSelected) {
          borderColor = theme.colorScheme.primary;
          bgColor = theme.colorScheme.primary.withOpacity(0.1);
          textColor = theme.colorScheme.primary;
        }

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: GestureDetector(
            onTap: widget.isAnswered
                ? null
                : () {
                    setState(() => _selectedIndex = index);
                    widget.onAnswerSelected(option.text, option.isCorrect);
                  },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOut,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: borderColor, width: isSelected ? 2.5 : 1.5),
                boxShadow: isSelected && !widget.isAnswered
                    ? [
                        BoxShadow(
                          color: theme.colorScheme.primary.withOpacity(0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        )
                      ]
                    : [],
              ),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isSelected
                          ? (widget.isAnswered
                              ? (isCorrect ? const Color(0xFF4CAF50) : const Color(0xFFE53935))
                              : theme.colorScheme.primary)
                          : theme.colorScheme.surfaceContainerHighest,
                    ),
                    child: Center(
                      child: Text(
                        String.fromCharCode(65 + index), // A, B, C, D
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: isSelected
                              ? Colors.white
                              : theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      option.text,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                        color: textColor,
                      ),
                    ),
                  ),
                  if (trailingIcon != null) trailingIcon,
                ],
              ),
            ).animate(target: isSelected ? 1 : 0).scale(
                  begin: const Offset(1, 1),
                  end: const Offset(1.01, 1.01),
                  duration: 200.ms,
                  curve: Curves.easeOut,
                ),
          ),
        );
      }),
    );
  }
}
