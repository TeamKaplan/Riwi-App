import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../data/models/question_model.dart';

/// Order Words widget: words shown as chips in a pool.
/// User taps to build the answer sequence.
/// correctAnswer contains the full correct sentence.
class OrderWordsWidget extends StatefulWidget {
  final Question question;
  final bool isAnswered;
  final void Function(String answer, bool isCorrect) onAnswerSelected;

  const OrderWordsWidget({
    super.key,
    required this.question,
    required this.isAnswered,
    required this.onAnswerSelected,
  });

  @override
  State<OrderWordsWidget> createState() => _OrderWordsWidgetState();
}

class _OrderWordsWidgetState extends State<OrderWordsWidget> {
  List<String> _pool = [];
  List<String> _answerWords = [];

  @override
  void initState() {
    super.initState();
    _init();
  }

  void _init() {
    final correct = widget.question.correctAnswer ?? '';
    // Build pool from the correct sentence words
    final words = correct
        .replaceAll('.', '')
        .replaceAll(',', '')
        .replaceAll('?', '')
        .replaceAll('!', '')
        .split(RegExp(r'\s+'))
        .where((w) => w.isNotEmpty)
        .toList();

    _pool = List<String>.from(words)..shuffle();
    _answerWords = [];
  }

  @override
  void didUpdateWidget(OrderWordsWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.question.id != widget.question.id) {
      setState(() => _init());
    }
  }

  void _pickWord(int poolIndex) {
    if (widget.isAnswered) return;
    setState(() {
      _answerWords.add(_pool.removeAt(poolIndex));
    });
    _notifyParent();
  }

  void _returnWord(int answerIndex) {
    if (widget.isAnswered) return;
    setState(() {
      _pool.add(_answerWords.removeAt(answerIndex));
    });
    _notifyParent();
  }

  void _notifyParent() {
    final userAnswer = _answerWords.join(' ');
    final correct = widget.question.correctAnswer ?? '';

    String normalize(String s) => s
        .toLowerCase()
        .replaceAll(RegExp(r'[.,!?]'), '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();

    widget.onAnswerSelected(
        userAnswer, normalize(userAnswer) == normalize(correct));
  }

  bool get _isCorrect {
    final userAnswer = _answerWords.join(' ');
    final correct = widget.question.correctAnswer ?? '';
    String normalize(String s) => s
        .toLowerCase()
        .replaceAll(RegExp(r'[.,!?]'), '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
    return normalize(userAnswer) == normalize(correct);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final correct = widget.question.correctAnswer ?? '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Answer tray
        Container(
          constraints: const BoxConstraints(minHeight: 64),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withOpacity(0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: widget.isAnswered
                  ? (_isCorrect
                      ? const Color(0xFF4CAF50)
                      : const Color(0xFFE53935))
                  : theme.colorScheme.primary.withOpacity(0.3),
              width: 2,
            ),
          ),
          child: _answerWords.isEmpty
              ? Center(
                  child: Text(
                    'Tap words below to build the sentenceâ€¦',
                    style: TextStyle(
                      color:
                          theme.colorScheme.onSurfaceVariant.withOpacity(0.6),
                      fontSize: 14,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                )
              : Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: List.generate(_answerWords.length, (i) {
                    final chipColor = widget.isAnswered
                        ? (_isCorrect
                            ? const Color(0xFF4CAF50)
                            : const Color(0xFFE53935))
                        : theme.colorScheme.primary;
                    return GestureDetector(
                      onTap: () => _returnWord(i),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: chipColor,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: chipColor.withOpacity(0.3),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            )
                          ],
                        ),
                        child: Text(
                          _answerWords[i],
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),
                      ).animate().scale(
                            duration: 150.ms,
                            curve: Curves.easeOut,
                          ),
                    );
                  }),
                ),
        ),
        const SizedBox(height: 20),

        // Word pool
        Text(
          'Available words:',
          style: TextStyle(
            fontSize: 13,
            color: theme.colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: List.generate(_pool.length, (i) {
            return GestureDetector(
              onTap: () => _pickWord(i),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: theme.colorScheme.outline.withOpacity(0.4),
                  ),
                ),
                child: Text(
                  _pool[i],
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ),
            );
          }),
        ),

        if (widget.isAnswered)
          Padding(
            padding: const EdgeInsets.only(top: 16),
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
