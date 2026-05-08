import 'package:flutter/material.dart';
import '../../../data/models/question_model.dart';

/// Matching widget: tap a left item, then tap a right item to connect them.
/// Correct order assumed: matchingLeft[i] pairs with matchingRight[i].
/// The right column is shuffled on init.
class MatchingWidget extends StatefulWidget {
  final Question question;
  final bool isAnswered;
  final void Function(String answer, bool isCorrect) onAnswerSelected;

  const MatchingWidget({
    super.key,
    required this.question,
    required this.isAnswered,
    required this.onAnswerSelected,
  });

  @override
  State<MatchingWidget> createState() => _MatchingWidgetState();
}

class _MatchingWidgetState extends State<MatchingWidget> {
  late List<String> _leftItems;
  late List<String> _rightItems; // shuffled
  late List<String> _correctRight; // original order

  int? _selectedLeft;
  int? _selectedRight;

  // pairs[leftIndex] = rightIndex in _rightItems
  final Map<int, int> _pairs = {};

  @override
  void initState() {
    super.initState();
    _init();
  }

  void _init() {
    _leftItems = List<String>.from(widget.question.matchingLeft ?? []);
    _correctRight = List<String>.from(widget.question.matchingRight ?? []);
    _rightItems = List<String>.from(_correctRight)..shuffle();
    _pairs.clear();
    _selectedLeft = null;
    _selectedRight = null;
  }

  @override
  void didUpdateWidget(MatchingWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.question.id != widget.question.id) {
      setState(() => _init());
    }
  }

  void _onTapLeft(int index) {
    if (widget.isAnswered) return;
    setState(() {
      if (_selectedLeft == index) {
        _selectedLeft = null;
      } else {
        _selectedLeft = index;
        if (_selectedRight != null) _tryPair();
      }
    });
  }

  void _onTapRight(int index) {
    if (widget.isAnswered) return;
    setState(() {
      if (_selectedRight == index) {
        _selectedRight = null;
      } else {
        _selectedRight = index;
        if (_selectedLeft != null) _tryPair();
      }
    });
  }

  void _tryPair() {
    final l = _selectedLeft!;
    final r = _selectedRight!;

    // Remove any existing pair that used r
    _pairs.removeWhere((k, v) => v == r);
    // Remove any existing pair for l
    _pairs.remove(l);

    _pairs[l] = r;
    _selectedLeft = null;
    _selectedRight = null;

    // Check if all paired
    if (_pairs.length == _leftItems.length) {
      _evaluateAndNotify();
    }
  }

  void _evaluateAndNotify() {
    bool allCorrect = true;
    for (int i = 0; i < _leftItems.length; i++) {
      if (!_pairs.containsKey(i)) {
        allCorrect = false;
        break;
      }
      final rightIndex = _pairs[i]!;
      final pairedRight = _rightItems[rightIndex];
      if (pairedRight != _correctRight[i]) {
        allCorrect = false;
        break;
      }
    }
    widget.onAnswerSelected(_pairs.toString(), allCorrect);
  }

  bool _isPairCorrect(int leftIndex) {
    if (!_pairs.containsKey(leftIndex)) return false;
    final rightIndex = _pairs[leftIndex]!;
    return _rightItems[rightIndex] == _correctRight[leftIndex];
  }

  int? _rightPairedWith(int rightIndex) {
    for (final entry in _pairs.entries) {
      if (entry.value == rightIndex) return entry.key;
    }
    return null;
  }

  static const List<Color> _pairColors = [
    Color(0xFF6B5BFC),
    Color(0xFF4CAF50),
    Color(0xFFFF7043),
    Color(0xFF00B4D8),
    Color(0xFFFFB300),
  ];

  Color? _leftColor(int index) {
    if (!_pairs.containsKey(index)) return null;
    if (widget.isAnswered) {
      return _isPairCorrect(index) ? const Color(0xFF4CAF50) : const Color(0xFFE53935);
    }
    return _pairColors[index % _pairColors.length];
  }

  Color? _rightColor(int rightIndex) {
    final leftIndex = _rightPairedWith(rightIndex);
    if (leftIndex == null) return null;
    if (widget.isAnswered) {
      return _isPairCorrect(leftIndex) ? const Color(0xFF4CAF50) : const Color(0xFFE53935);
    }
    return _pairColors[leftIndex % _pairColors.length];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final int maxRows =
        _leftItems.length > _rightItems.length ? _leftItems.length : _rightItems.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left column
            Expanded(
              child: Column(
                children: List.generate(_leftItems.length, (i) {
                  final color = _leftColor(i);
                  final isSelected = _selectedLeft == i;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: GestureDetector(
                      onTap: () => _onTapLeft(i),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 12),
                        decoration: BoxDecoration(
                          color: color != null
                              ? color.withOpacity(0.12)
                              : isSelected
                                  ? theme.colorScheme.primary.withOpacity(0.1)
                                  : theme.colorScheme.surfaceContainerHighest
                                      .withOpacity(0.5),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: color ??
                                (isSelected
                                    ? theme.colorScheme.primary
                                    : theme.colorScheme.outline
                                        .withOpacity(0.3)),
                            width: color != null || isSelected ? 2 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            if (color != null)
                              Container(
                                width: 10,
                                height: 10,
                                margin: const EdgeInsets.only(right: 8),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: color,
                                ),
                              ),
                            Expanded(
                              child: Text(
                                _leftItems[i],
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: color != null || isSelected
                                      ? FontWeight.w600
                                      : FontWeight.w500,
                                  color: color ?? theme.colorScheme.onSurface,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(width: 12),
            // Right column
            Expanded(
              child: Column(
                children: List.generate(_rightItems.length, (i) {
                  final color = _rightColor(i);
                  final isSelected = _selectedRight == i;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: GestureDetector(
                      onTap: () => _onTapRight(i),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 12),
                        decoration: BoxDecoration(
                          color: color != null
                              ? color.withOpacity(0.12)
                              : isSelected
                                  ? theme.colorScheme.secondary
                                      .withOpacity(0.1)
                                  : theme.colorScheme.surfaceContainerHighest
                                      .withOpacity(0.5),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: color ??
                                (isSelected
                                    ? theme.colorScheme.secondary
                                    : theme.colorScheme.outline
                                        .withOpacity(0.3)),
                            width: color != null || isSelected ? 2 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            if (color != null)
                              Container(
                                width: 10,
                                height: 10,
                                margin: const EdgeInsets.only(right: 8),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: color,
                                ),
                              ),
                            Expanded(
                              child: Text(
                                _rightItems[i],
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: color != null || isSelected
                                      ? FontWeight.w600
                                      : FontWeight.w500,
                                  color: color ?? theme.colorScheme.onSurface,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
        if (_pairs.length < _leftItems.length)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              'Tap an item on each side to connect them (${_pairs.length}/${_leftItems.length} matched)',
              style: TextStyle(
                fontSize: 13,
                color: theme.colorScheme.onSurfaceVariant,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        if (widget.isAnswered)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Wrap(
              spacing: 8,
              runSpacing: 6,
              children: List.generate(_leftItems.length, (i) {
                return Chip(
                  label: Text(
                    '${_leftItems[i]} â†’ ${_correctRight[i]}',
                    style: const TextStyle(fontSize: 12),
                  ),
                  backgroundColor: const Color(0xFF4CAF50).withOpacity(0.15),
                  side: const BorderSide(color: Color(0xFF4CAF50)),
                );
              }),
            ),
          ),
      ],
    );
  }
}
