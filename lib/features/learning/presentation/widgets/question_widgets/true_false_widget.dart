import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../data/models/question_model.dart';

class TrueFalseWidget extends StatefulWidget {
  final Question question;
  final bool isAnswered;
  final void Function(String answer, bool isCorrect) onAnswerSelected;

  const TrueFalseWidget({
    super.key,
    required this.question,
    required this.isAnswered,
    required this.onAnswerSelected,
  });

  @override
  State<TrueFalseWidget> createState() => _TrueFalseWidgetState();
}

class _TrueFalseWidgetState extends State<TrueFalseWidget> {
  String? _selected; // 'true' or 'false'

  @override
  void didUpdateWidget(TrueFalseWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.question.id != widget.question.id) {
      setState(() => _selected = null);
    }
  }

  void _select(String value) {
    if (widget.isAnswered) return;
    setState(() => _selected = value);
    final correct = widget.question.correctAnswer?.toLowerCase() ?? 'true';
    widget.onAnswerSelected(value, value == correct);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _buildButton(context, 'true', 'âœ“ True', const Color(0xFF4CAF50))),
        const SizedBox(width: 16),
        Expanded(child: _buildButton(context, 'false', 'âœ— False', const Color(0xFFE53935))),
      ],
    );
  }

  Widget _buildButton(
      BuildContext context, String value, String label, Color color) {
    final isSelected = _selected == value;
    final correct = widget.question.correctAnswer?.toLowerCase() ?? 'true';
    final isCorrectAnswer = value == correct;

    Color bgColor;
    Color borderColor;
    Color textColor = Colors.white;

    if (!widget.isAnswered) {
      if (isSelected) {
        bgColor = color;
        borderColor = color;
      } else {
        bgColor = color.withOpacity(0.08);
        borderColor = color.withOpacity(0.4);
        textColor = color;
      }
    } else {
      if (isSelected && isCorrectAnswer) {
        bgColor = const Color(0xFF4CAF50);
        borderColor = const Color(0xFF4CAF50);
      } else if (isSelected && !isCorrectAnswer) {
        bgColor = const Color(0xFFE53935);
        borderColor = const Color(0xFFE53935);
      } else if (isCorrectAnswer) {
        bgColor = const Color(0xFF4CAF50).withOpacity(0.15);
        borderColor = const Color(0xFF4CAF50);
        textColor = const Color(0xFF2E7D32);
      } else {
        bgColor = color.withOpacity(0.05);
        borderColor = color.withOpacity(0.2);
        textColor = color.withOpacity(0.5);
      }
    }

    return GestureDetector(
      onTap: () => _select(value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        height: 100,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: borderColor, width: 2.5),
          boxShadow: isSelected && !widget.isAnswered
              ? [
                  BoxShadow(
                    color: color.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  )
                ]
              : [],
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                value == 'true' ? Icons.check_circle_outline : Icons.cancel_outlined,
                color: textColor,
                size: 32,
              ),
              const SizedBox(height: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
            ],
          ),
        ),
      ).animate(target: isSelected ? 1 : 0).scale(
            begin: const Offset(1, 1),
            end: const Offset(1.03, 1.03),
            duration: 200.ms,
            curve: Curves.easeOut,
          ),
    );
  }
}
