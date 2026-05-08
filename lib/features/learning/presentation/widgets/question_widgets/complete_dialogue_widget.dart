import 'package:flutter/material.dart';
import '../../../data/models/question_model.dart';

/// Complete Dialogue widget: user selects or types the missing dialogue line.
class CompleteDialogueWidget extends StatefulWidget {
  final Question question;
  final bool isAnswered;
  final void Function(String answer, bool isCorrect) onAnswerSelected;

  const CompleteDialogueWidget({
    super.key,
    required this.question,
    required this.isAnswered,
    required this.onAnswerSelected,
  });

  @override
  State<CompleteDialogueWidget> createState() => _CompleteDialogueWidgetState();
}

class _CompleteDialogueWidgetState extends State<CompleteDialogueWidget> {
  int? _selectedIndex;
  final TextEditingController _textController = TextEditingController();

  @override
  void didUpdateWidget(CompleteDialogueWidget oldWidget) {
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

  String _normalize(String s) =>
      s.toLowerCase().replaceAll(RegExp(r'[.,!?]'), '').trim();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final instruction = widget.question.instruction ?? '';
    final options = widget.question.options ?? [];
    final correct = widget.question.correctAnswer ?? '';

    // Parse the dialogue lines from instruction
    final lines = instruction.split(' / ');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Dialogue bubble display
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.4),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
                color: theme.colorScheme.outline.withOpacity(0.2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: lines.asMap().entries.map((entry) {
              final index = entry.key;
              final line = entry.value;
              final isA = line.startsWith('A:');
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment:
                      isA ? MainAxisAlignment.start : MainAxisAlignment.end,
                  children: [
                    if (isA) ...[
                      CircleAvatar(
                        radius: 14,
                        backgroundColor:
                            theme.colorScheme.primary.withOpacity(0.15),
                        child: Text(
                          'A',
                          style: TextStyle(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: isA
                              ? theme.colorScheme.primary.withOpacity(0.1)
                              : theme.colorScheme.secondary.withOpacity(0.1),
                          borderRadius: BorderRadius.only(
                            topLeft: const Radius.circular(16),
                            topRight: const Radius.circular(16),
                            bottomLeft: Radius.circular(isA ? 4 : 16),
                            bottomRight: Radius.circular(isA ? 16 : 4),
                          ),
                          border: Border.all(
                            color: isA
                                ? theme.colorScheme.primary.withOpacity(0.2)
                                : theme.colorScheme.secondary.withOpacity(0.2),
                          ),
                        ),
                        child: Text(
                          line,
                          style: TextStyle(
                            fontSize: 14,
                            color: theme.colorScheme.onSurface,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ),
                    if (!isA) ...[
                      const SizedBox(width: 8),
                      CircleAvatar(
                        radius: 14,
                        backgroundColor:
                            theme.colorScheme.secondary.withOpacity(0.15),
                        child: Text(
                          'B',
                          style: TextStyle(
                            color: theme.colorScheme.secondary,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 20),

        // Options or text input
        if (options.isNotEmpty) ...[
          Text(
            'Complete the dialogue:',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 12),
          ...List.generate(options.length, (index) {
            final option = options[index];
            final isSelected = _selectedIndex == index;
            Color bgColor = theme.colorScheme.surface;
            Color borderColor = theme.colorScheme.outline.withOpacity(0.3);

            if (widget.isAnswered && isSelected) {
              bgColor = option.isCorrect
                  ? const Color(0xFF4CAF50).withOpacity(0.15)
                  : const Color(0xFFE53935).withOpacity(0.12);
              borderColor = option.isCorrect
                  ? const Color(0xFF4CAF50)
                  : const Color(0xFFE53935);
            } else if (widget.isAnswered && option.isCorrect) {
              bgColor = const Color(0xFF4CAF50).withOpacity(0.08);
              borderColor = const Color(0xFF4CAF50);
            } else if (isSelected) {
              bgColor = theme.colorScheme.primary.withOpacity(0.1);
              borderColor = theme.colorScheme.primary;
            }

            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: GestureDetector(
                onTap: widget.isAnswered
                    ? null
                    : () {
                        setState(() => _selectedIndex = index);
                        widget.onAnswerSelected(option.text, option.isCorrect);
                      },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                        color: borderColor,
                        width: isSelected ? 2 : 1.5),
                  ),
                  child: Text(
                    '"${option.text}"',
                    style: TextStyle(
                      fontSize: 15,
                      fontStyle: FontStyle.italic,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w500,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ),
              ),
            );
          }),
        ] else ...[
          Text(
            'Complete the missing part:',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: widget.isAnswered
                    ? const Color(0xFF4CAF50)
                    : theme.colorScheme.outline.withOpacity(0.4),
                width: 1.5,
              ),
            ),
            child: TextField(
              controller: _textController,
              enabled: !widget.isAnswered,
              onChanged: (val) {
                final ok = _normalize(val) == _normalize(correct);
                widget.onAnswerSelected(val, ok);
              },
              style: TextStyle(
                fontSize: 15,
                color: theme.colorScheme.onSurface,
              ),
              decoration: InputDecoration(
                hintText: 'Type your responseâ€¦',
                hintStyle: TextStyle(
                  color:
                      theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.all(16),
              ),
            ),
          ),
          if (widget.isAnswered)
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Text(
                'Expected: $correct',
                style: const TextStyle(
                  color: Color(0xFF4CAF50),
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
        ],
      ],
    );
  }
}
