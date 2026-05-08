import 'package:flutter/material.dart';
import '../../../data/models/question_model.dart';

/// Complete Code widget: shows a code snippet with a blank,
/// user selects the correct completion from options (if provided)
/// or types the answer.
class CompleteCodeWidget extends StatefulWidget {
  final Question question;
  final bool isAnswered;
  final void Function(String answer, bool isCorrect) onAnswerSelected;

  const CompleteCodeWidget({
    super.key,
    required this.question,
    required this.isAnswered,
    required this.onAnswerSelected,
  });

  @override
  State<CompleteCodeWidget> createState() => _CompleteCodeWidgetState();
}

class _CompleteCodeWidgetState extends State<CompleteCodeWidget> {
  int? _selectedIndex;
  final TextEditingController _textController = TextEditingController();

  @override
  void didUpdateWidget(CompleteCodeWidget oldWidget) {
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
    final code = widget.question.codeSnippet ?? widget.question.instruction ?? '';
    final language = widget.question.codeLanguage ?? 'code';
    final options = widget.question.options ?? [];
    final blanksAnswers = widget.question.blanksAnswers ?? [];
    final correct = widget.question.correctAnswer ??
        (blanksAnswers.isNotEmpty ? blanksAnswers.join(', ') : '');

    // If blanksAnswers is provided (dev-style), use inline text fields
    final useBlanksMode = blanksAnswers.isNotEmpty && options.isEmpty;


    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Language badge
        Row(
          children: [
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF6B5BFC).withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFF6B5BFC).withOpacity(0.4)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.code, size: 14, color: Color(0xFF6B5BFC)),
                  const SizedBox(width: 4),
                  Text(
                    language.toUpperCase(),
                    style: const TextStyle(
                      color: Color(0xFF6B5BFC),
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        // Code snippet
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A2E),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFF6B5BFC).withOpacity(0.3)),
          ),
          child: SelectableText(
            code,
            style: const TextStyle(
              fontFamily: 'monospace',
              fontSize: 14,
              color: Color(0xFFE0E0E0),
              height: 1.7,
              letterSpacing: 0.5,
            ),
          ),
        ),
        const SizedBox(height: 20),

        // Blanks mode (dev levels: blanksAnswers without options)
        if (useBlanksMode) ...[
          Text(
            'Fill in the blanks (${blanksAnswers.length} blank${blanksAnswers.length > 1 ? 's' : ''}):',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 10),
          _BlanksFillWidget(
            blanksAnswers: blanksAnswers,
            isAnswered: widget.isAnswered,
            onChanged: (answers, allCorrect) {
              widget.onAnswerSelected(answers.join(', '), allCorrect);
            },
          ),
        ] else if (options.isNotEmpty) ...[
          Text(
            'Complete the code:',
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
            Color borderColor = theme.colorScheme.outline.withOpacity(0.3);
            Color bgColor = theme.colorScheme.surface;

            if (widget.isAnswered && isSelected) {
              borderColor = option.isCorrect
                  ? const Color(0xFF4CAF50)
                  : const Color(0xFFE53935);
              bgColor = option.isCorrect
                  ? const Color(0xFF4CAF50).withOpacity(0.1)
                  : const Color(0xFFE53935).withOpacity(0.1);
            } else if (widget.isAnswered && option.isCorrect) {
              borderColor = const Color(0xFF4CAF50);
              bgColor = const Color(0xFF4CAF50).withOpacity(0.08);
            } else if (isSelected) {
              borderColor = const Color(0xFF6B5BFC);
              bgColor = const Color(0xFF6B5BFC).withOpacity(0.1);
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
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(12),
                    border:
                        Border.all(color: borderColor, width: isSelected ? 2 : 1.5),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1A1A2E),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          option.text,
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 13,
                            color: Color(0xFF6B5BFC),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ] else ...[
          // Text input fallback
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: widget.isAnswered
                    ? const Color(0xFF4CAF50)
                    : const Color(0xFF6B5BFC).withOpacity(0.4),
                width: 1.5,
              ),
              color: const Color(0xFF1A1A2E),
            ),
            child: TextField(
              controller: _textController,
              enabled: !widget.isAnswered,
              onChanged: (val) {
                final isCorrect =
                    val.trim().toLowerCase() == correct.trim().toLowerCase();
                widget.onAnswerSelected(val, isCorrect);
              },
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 14,
                color: Colors.white,
              ),
              decoration: const InputDecoration(
                hintText: 'Type the missing codeâ€¦',
                hintStyle: TextStyle(color: Colors.white38),
                border: InputBorder.none,
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ),
        ],


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
                  const Icon(Icons.check_circle, color: Color(0xFF4CAF50)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Answer: $correct',
                      style: const TextStyle(
                        fontFamily: 'monospace',
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

// ---------------------------------------------------------------------------
// Helper: fill-in-blanks for code (used when blanksAnswers is set without options)
// ---------------------------------------------------------------------------
class _BlanksFillWidget extends StatefulWidget {
  final List<String> blanksAnswers;
  final bool isAnswered;
  final void Function(List<String> answers, bool allCorrect) onChanged;

  const _BlanksFillWidget({
    required this.blanksAnswers,
    required this.isAnswered,
    required this.onChanged,
  });

  @override
  State<_BlanksFillWidget> createState() => _BlanksFillWidgetState();
}

class _BlanksFillWidgetState extends State<_BlanksFillWidget> {
  late List<TextEditingController> _controllers;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      widget.blanksAnswers.length,
      (_) => TextEditingController(),
    );
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _notify() {
    final answers = _controllers.map((c) => c.text.trim()).toList();
    final corrects = widget.blanksAnswers;
    bool allCorrect = answers.length == corrects.length;
    if (allCorrect) {
      for (int i = 0; i < answers.length; i++) {
        if (answers[i].toLowerCase() != corrects[i].toLowerCase()) {
          allCorrect = false;
          break;
        }
      }
    }
    widget.onChanged(answers, allCorrect);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(widget.blanksAnswers.length, (i) {
        final correct = widget.blanksAnswers[i];
        final userVal = _controllers[i].text.trim();
        final isOk = userVal.toLowerCase() == correct.toLowerCase();
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Row(
            children: [
              Text(
                'Blank ${i + 1}:',
                style: const TextStyle(
                  color: Color(0xFF9E9E9E),
                  fontSize: 13,
                  fontFamily: 'monospace',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: widget.isAnswered
                        ? (isOk
                            ? const Color(0xFF4CAF50).withOpacity(0.15)
                            : const Color(0xFFE53935).withOpacity(0.12))
                        : const Color(0xFF2A2A3E),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: widget.isAnswered
                          ? (isOk
                              ? const Color(0xFF4CAF50)
                              : const Color(0xFFE53935))
                          : const Color(0xFF6B5BFC).withOpacity(0.5),
                    ),
                  ),
                  child: TextField(
                    controller: _controllers[i],
                    enabled: !widget.isAnswered,
                    onChanged: (_) => _notify(),
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 14,
                      color: Colors.white,
                    ),
                    decoration: InputDecoration(
                      hintText: '___',
                      hintStyle: const TextStyle(color: Colors.white38),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 10),
                      suffixIcon: widget.isAnswered
                          ? Icon(
                              isOk
                                  ? Icons.check_circle_rounded
                                  : Icons.cancel_rounded,
                              color: isOk
                                  ? const Color(0xFF4CAF50)
                                  : const Color(0xFFE53935),
                              size: 18,
                            )
                          : null,
                    ),
                  ),
                ),
              ),
              if (widget.isAnswered && !isOk)
                Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4CAF50).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      correct,
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        color: Color(0xFF4CAF50),
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      }),
    );
  }
}
