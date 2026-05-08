import 'package:flutter/material.dart';
import '../../../data/models/question_model.dart';

/// Complete Word widget: user types or selects a single keyword.
class CompleteWordWidget extends StatefulWidget {
  final Question question;
  final bool isAnswered;
  final void Function(String answer, bool isCorrect) onAnswerSelected;

  const CompleteWordWidget({
    super.key,
    required this.question,
    required this.isAnswered,
    required this.onAnswerSelected,
  });

  @override
  State<CompleteWordWidget> createState() => _CompleteWordWidgetState();
}

class _CompleteWordWidgetState extends State<CompleteWordWidget> {
  int? _selectedIndex;
  final TextEditingController _textController = TextEditingController();

  @override
  void didUpdateWidget(CompleteWordWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.question.id != widget.question.id) {
      setState(() => _selectedIndex = null);
      _textController.clear();
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final options = widget.question.options ?? [];
    final correct = widget.question.correctAnswer ?? '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Instruction
        if (widget.question.instruction != null)
          Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color: theme.colorScheme.outline.withOpacity(0.2)),
            ),
            child: Text(
              widget.question.instruction!,
              style: TextStyle(
                fontSize: 16,
                height: 1.5,
                color: theme.colorScheme.onSurface,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),

        if (options.isNotEmpty) ...[
          Text(
            'Choose the correct word:',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: List.generate(options.length, (index) {
              final option = options[index];
              final isSelected = _selectedIndex == index;
              Color bgColor;
              Color borderColor;
              Color textColor;

              if (widget.isAnswered && isSelected) {
                bgColor = option.isCorrect
                    ? const Color(0xFF4CAF50)
                    : const Color(0xFFE53935);
                borderColor = bgColor;
                textColor = Colors.white;
              } else if (widget.isAnswered && option.isCorrect) {
                bgColor = const Color(0xFF4CAF50).withOpacity(0.15);
                borderColor = const Color(0xFF4CAF50);
                textColor = const Color(0xFF2E7D32);
              } else if (isSelected) {
                bgColor = theme.colorScheme.primary.withOpacity(0.1);
                borderColor = theme.colorScheme.primary;
                textColor = theme.colorScheme.primary;
              } else {
                bgColor = theme.colorScheme.surfaceContainerHighest;
                borderColor = theme.colorScheme.outline.withOpacity(0.4);
                textColor = theme.colorScheme.onSurface;
              }

              return GestureDetector(
                onTap: widget.isAnswered
                    ? null
                    : () {
                        setState(() => _selectedIndex = index);
                        widget.onAnswerSelected(option.text, option.isCorrect);
                      },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                        color: borderColor,
                        width: isSelected ? 2 : 1.5),
                  ),
                  child: Text(
                    option.text,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.w500,
                      color: textColor,
                    ),
                  ),
                ),
              );
            }),
          ),
        ] else ...[
          // Text input
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: widget.isAnswered
                    ? const Color(0xFF4CAF50)
                    : theme.colorScheme.outline.withOpacity(0.4),
                width: 1.5,
              ),
              color: widget.isAnswered
                  ? const Color(0xFF4CAF50).withOpacity(0.08)
                  : theme.colorScheme.surface,
            ),
            child: TextField(
              controller: _textController,
              enabled: !widget.isAnswered,
              onChanged: (val) {
                final isCorrect = val.trim().toLowerCase() ==
                    correct.trim().toLowerCase();
                widget.onAnswerSelected(val, isCorrect);
              },
              style: TextStyle(
                fontSize: 16,
                color: theme.colorScheme.onSurface,
              ),
              decoration: InputDecoration(
                hintText: 'Type the wordâ€¦',
                hintStyle: TextStyle(
                  color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 14),
              ),
            ),
          ),
        ],

        if (widget.isAnswered && correct.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 14),
            child: Row(
              children: [
                const Icon(Icons.check_circle,
                    color: Color(0xFF4CAF50), size: 18),
                const SizedBox(width: 6),
                Text(
                  'Correct answer: $correct',
                  style: const TextStyle(
                    color: Color(0xFF2E7D32),
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
