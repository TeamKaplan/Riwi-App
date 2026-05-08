import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/level_model.dart';
import '../data/progress_provider.dart';
import '../data/models/question_model.dart';
import '../data/levels/english_levels.dart';
import '../data/levels/development_levels.dart';
import '../data/levels/soft_skills_levels.dart';
import 'widgets/question_renderer.dart';

// ---------------------------------------------------------------------------
// Level repository helper (pure function, no state)
// ---------------------------------------------------------------------------
Level? _getLevel(String track, int levelId) {
  List<Level> levels;
  switch (track) {
    case 'english':
      levels = EnglishLevels.getAllLevels();
      break;
    case 'development':
      levels = DevelopmentLevels.getAllLevels();
      break;
    case 'soft_skills':
      levels = SoftSkillsLevels.getAllLevels();
      break;
    default:
      levels = EnglishLevels.getAllLevels();
  }
  try {
    return levels.firstWhere((l) => l.id == levelId);
  } catch (_) {
    return levels.isNotEmpty ? levels.first : null;
  }
}

// ---------------------------------------------------------------------------
// LessonScreen
// ---------------------------------------------------------------------------
class LessonScreen extends ConsumerStatefulWidget {
  /// Format: "track_levelId", e.g. "english_1", "development_3"
  /// Kept as String for GoRouter compatibility.
  final String lessonId;

  const LessonScreen({super.key, required this.lessonId});

  @override
  ConsumerState<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends ConsumerState<LessonScreen>
    with TickerProviderStateMixin {
  // ── level data ─────────────────────────────────────────────────────────
  late Level _level;
  late List<Question> _questions;

  // ── progress ────────────────────────────────────────────────────────────
  int _currentIndex = 0;
  int _hearts = 3;
  int _xpEarned = 0;
  int _correctCount = 0;

  // ── answer state ────────────────────────────────────────────────────────
  String? _currentAnswer;
  bool _isCurrentCorrect = false;
  bool _isAnswered = false;
  bool _isCheckEnabled = false;

  // ── animations ──────────────────────────────────────────────────────────
  late AnimationController _heartController;
  late AnimationController _progressController;
  late Animation<double> _progressAnimation;

  // ── computed ────────────────────────────────────────────────────────────
  String get _track {
    final parts = widget.lessonId.split('_');
    if (parts.length >= 2) {
      // e.g. "soft_skills_1" → track = "soft_skills"
      return parts.sublist(0, parts.length - 1).join('_');
    }
    return 'english';
  }

  int get _levelId {
    final parts = widget.lessonId.split('_');
    return int.tryParse(parts.last) ?? 1;
  }

  double get _progress => _questions.isEmpty
      ? 0
      : (_currentIndex / _questions.length).clamp(0.0, 1.0);

  Question get _current => _questions[_currentIndex];

  // ── init ────────────────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    _heartController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _progressAnimation = Tween<double>(begin: 0, end: 0).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.easeOut),
    );
    _loadLevel();
  }

  void _loadLevel() {
    final level = _getLevel(_track, _levelId);
    if (level == null || level.exercises.isEmpty) {
      // Fallback: use first english level
      final fallback = EnglishLevels.getAllLevels().first;
      _level = fallback;
      _questions = fallback.exercises;
    } else {
      _level = level;
      _questions = level.exercises;
    }
  }

  @override
  void dispose() {
    _heartController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  // ── event handlers ──────────────────────────────────────────────────────
  void _onAnswerChanged(String answer, bool isCorrect) {
    setState(() {
      _currentAnswer = answer;
      _isCurrentCorrect = isCorrect;
      _isCheckEnabled = answer.trim().isNotEmpty;
    });
  }

  void _onCheck() {
    if (!_isCheckEnabled || _isAnswered) return;
    setState(() {
      _isAnswered = true;
      if (_isCurrentCorrect) {
        _correctCount++;
        _xpEarned += (_level.xpReward / _questions.length).round();
      } else {
        _hearts--;
        _heartController.forward(from: 0);
      }
    });

    // Animate progress bar
    final newProgress = ((_currentIndex + 1) / _questions.length).clamp(0.0, 1.0);
    _progressAnimation = Tween<double>(begin: _progress, end: newProgress).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.easeOut),
    );
    _progressController.forward(from: 0);

    // If hearts = 0, fail after showing feedback
    if (_hearts <= 0) {
      Future.delayed(const Duration(milliseconds: 1800), _showFailDialog);
      return;
    }

    // Show feedback bottom sheet
    _showFeedback();
  }

  void _showFeedback() {
    final isCorrect = _isCurrentCorrect;
    final isLast = _currentIndex >= _questions.length - 1;

    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _FeedbackSheet(
        isCorrect: isCorrect,
        isLast: isLast,
        question: _current,
        onContinue: () {
          Navigator.pop(ctx);
          if (isLast) {
            _showSuccessDialog();
          } else {
            _goNext();
          }
        },
      ),
    );
  }

  void _goNext() {
    setState(() {
      _currentIndex++;
      _currentAnswer = null;
      _isCurrentCorrect = false;
      _isAnswered = false;
      _isCheckEnabled = false;
    });
  }

  void _showSuccessDialog() {
    // Recompensa en XP y actualización de racha en DB
    ref.read(progressProvider.notifier).addXp(_xpEarned);
    ref.read(progressProvider.notifier).updateStreak();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => _SuccessDialog(
        xpEarned: _xpEarned,
        correctCount: _correctCount,
        totalCount: _questions.length,
        levelTitle: _level.title,
        onContinue: () {
          Navigator.pop(ctx);
          context.go('/');
        },
      ),
    );
  }

  void _showFailDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => _FailDialog(
        onRetry: () {
          Navigator.pop(ctx);
          setState(() {
            _currentIndex = 0;
            _hearts = 3;
            _xpEarned = 0;
            _correctCount = 0;
            _currentAnswer = null;
            _isCurrentCorrect = false;
            _isAnswered = false;
            _isCheckEnabled = false;
          });
        },
        onExit: () {
          Navigator.pop(ctx);
          context.go('/');
        },
      ),
    );
  }

  // ── build ────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            // ── Top bar ──────────────────────────────────────────────────
            _buildTopBar(theme, isDark),
            const SizedBox(height: 8),

            // ── Question area ─────────────────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Question type badge
                    _buildTypeBadge(theme),
                    const SizedBox(height: 16),

                    // Question prompt
                    Text(
                      _current.prompt,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                        height: 1.4,
                      ),
                    ).animate().fadeIn(duration: 300.ms).slideY(
                          begin: 0.1,
                          end: 0,
                          duration: 300.ms,
                          curve: Curves.easeOut,
                        ),
                    const SizedBox(height: 24),

                    // Question renderer
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      transitionBuilder: (child, anim) => FadeTransition(
                        opacity: anim,
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0.05, 0),
                            end: Offset.zero,
                          ).animate(anim),
                          child: child,
                        ),
                      ),
                      child: KeyedSubtree(
                        key: ValueKey(_current.id),
                        child: QuestionRenderer(
                          question: _current,
                          isAnswered: _isAnswered,
                          onAnswerSelected: _onAnswerChanged,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Check button ─────────────────────────────────────────────
            _buildCheckButton(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(ThemeData theme, bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Row(
        children: [
          // Close button
          GestureDetector(
            onTap: () => context.go('/'),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: theme.colorScheme.surfaceContainerHighest,
              ),
              child: Icon(
                Icons.close,
                color: theme.colorScheme.onSurfaceVariant,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Progress bar
          Expanded(
            child: AnimatedBuilder(
              animation: _progressAnimation,
              builder: (context, _) {
                final value = _isAnswered && _progressController.isAnimating
                    ? _progressAnimation.value
                    : _progress;
                return ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: value,
                    minHeight: 12,
                    backgroundColor:
                        theme.colorScheme.surfaceContainerHighest,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      _trackColor,
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(width: 12),

          // Hearts
          _buildHearts(theme),
        ],
      ),
    );
  }

  Color get _trackColor {
    switch (_track) {
      case 'english':
        return const Color(0xFF4CAF50);
      case 'development':
        return const Color(0xFF6B5BFC);
      case 'soft_skills':
        return const Color(0xFFFF7043);
      default:
        return const Color(0xFF4CAF50);
    }
  }

  Widget _buildHearts(ThemeData theme) {
    return AnimatedBuilder(
      animation: _heartController,
      builder: (context, _) {
        return Row(
          children: List.generate(3, (i) {
            final active = i < _hearts;
            return Padding(
              padding: const EdgeInsets.only(left: 2),
              child: Icon(
                active ? Icons.favorite : Icons.favorite_border,
                color: active ? Colors.red.shade400 : Colors.grey.shade400,
                size: 22,
              ).animate(
                target: !active && _heartController.value > 0 && i == _hearts ? 1 : 0,
              ).shake(duration: 400.ms),
            );
          }),
        );
      },
    );
  }

  Widget _buildTypeBadge(ThemeData theme) {
    final typeLabel = _questionTypeLabel(_current.type);
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(
          color: _trackColor.withOpacity(0.12),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: _trackColor.withOpacity(0.3)),
        ),
        child: Text(
          typeLabel,
          style: TextStyle(
            color: _trackColor,
            fontWeight: FontWeight.w600,
            fontSize: 12,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  Widget _buildCheckButton(ThemeData theme) {
    final canCheck = _isCheckEnabled && !_isAnswered;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
      child: GestureDetector(
        onTap: canCheck ? _onCheck : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          height: 56,
          decoration: BoxDecoration(
            color: canCheck ? _trackColor : theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(18),
            boxShadow: canCheck
                ? [
                    BoxShadow(
                      color: _trackColor.withOpacity(0.35),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    )
                  ]
                : [],
          ),
          child: Center(
            child: Text(
              _isAnswered ? 'CONTINUE →' : 'CHECK',
              style: TextStyle(
                color: canCheck
                    ? Colors.white
                    : theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
                fontWeight: FontWeight.bold,
                fontSize: 16,
                letterSpacing: 1.5,
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _questionTypeLabel(QuestionType type) {
    switch (type) {
      case QuestionType.multipleChoice:
        return '🎯 Multiple Choice';
      case QuestionType.fillInTheBlanks:
        return '✏️ Fill in the Blanks';
      case QuestionType.trueFalse:
        return '⚖️ True or False';
      case QuestionType.matching:
        return '🔗 Match';
      case QuestionType.orderWords:
        return '🔀 Order Words';
      case QuestionType.miniReading:
        return '📖 Reading';
      case QuestionType.completeCode:
        return '💻 Complete Code';
      case QuestionType.completeWord:
        return '🔤 Complete Word';
      case QuestionType.errorCorrection:
        return '🔧 Error Correction';
      case QuestionType.completeDialogue:
        return '💬 Dialogue';
      case QuestionType.shortWriting:
        return '📝 Short Writing';
      case QuestionType.chooseCorrect:
        return '✅ Choose Correct';
    }
  }
}

// ---------------------------------------------------------------------------
// Feedback bottom sheet
// ---------------------------------------------------------------------------
class _FeedbackSheet extends StatelessWidget {
  final bool isCorrect;
  final bool isLast;
  final Question question;
  final VoidCallback onContinue;

  const _FeedbackSheet({
    required this.isCorrect,
    required this.isLast,
    required this.question,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = isCorrect
        ? const Color(0xFF4CAF50).withOpacity(0.95)
        : const Color(0xFFE53935).withOpacity(0.95);

    final String message = isCorrect
        ? _correctMessages[DateTime.now().millisecond % _correctMessages.length]
        : '¡Casi! Revisa la respuesta correcta.';

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              Icon(
                isCorrect ? Icons.check_circle : Icons.cancel,
                color: Colors.white,
                size: 32,
              ).animate().scale(duration: 300.ms, curve: Curves.elasticOut),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  isCorrect ? '¡Correcto! 🎉' : 'Incorrecto 😢',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          Text(
            message,
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 20),

          // Continue button
          GestureDetector(
            onTap: onContinue,
            child: Container(
              height: 52,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              child: Center(
                child: Text(
                  isLast ? 'FINISH LESSON' : 'CONTINUE',
                  style: TextStyle(
                    color: isCorrect
                        ? const Color(0xFF2E7D32)
                        : const Color(0xFFC62828),
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ),
          ).animate().slideY(
                begin: 0.5,
                end: 0,
                duration: 300.ms,
                curve: Curves.easeOut,
              ),
        ],
      ),
    ).animate().slideY(begin: 1, end: 0, duration: 350.ms, curve: Curves.easeOut);
  }

  static const List<String> _correctMessages = [
    '¡Excelente trabajo! Sigue así.',
    '¡Perfecto! Eres un crack. 🚀',
    '¡Muy bien! Tu racha continúa.',
    '¡Genial! Así se hace. 💪',
    '¡Outstanding! Keep it up!',
  ];
}

// ---------------------------------------------------------------------------
// Success dialog
// ---------------------------------------------------------------------------
class _SuccessDialog extends StatelessWidget {
  final int xpEarned;
  final int correctCount;
  final int totalCount;
  final String levelTitle;
  final VoidCallback onContinue;

  const _SuccessDialog({
    required this.xpEarned,
    required this.correctCount,
    required this.totalCount,
    required this.levelTitle,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accuracy = totalCount > 0
        ? ((correctCount / totalCount) * 100).round()
        : 0;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: const Color(0xFF4CAF50).withOpacity(0.4),
            width: 2,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🏆', style: TextStyle(fontSize: 64))
                .animate()
                .scale(duration: 600.ms, curve: Curves.elasticOut),
            const SizedBox(height: 12),
            Text(
              '¡Nivel Completado!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              levelTitle,
              style: TextStyle(
                fontSize: 14,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            // Stats row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _StatItem(
                  icon: '⭐',
                  value: '+$xpEarned XP',
                  label: 'Earned',
                  color: Colors.amber,
                ),
                _StatItem(
                  icon: '🎯',
                  value: '$accuracy%',
                  label: 'Accuracy',
                  color: const Color(0xFF4CAF50),
                ),
                _StatItem(
                  icon: '✅',
                  value: '$correctCount/$totalCount',
                  label: 'Correct',
                  color: const Color(0xFF6B5BFC),
                ),
              ],
            ),
            const SizedBox(height: 28),

            // Continue button
            GestureDetector(
              onTap: onContinue,
              child: Container(
                width: double.infinity,
                height: 54,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF4CAF50), Color(0xFF66BB6A)],
                  ),
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF4CAF50).withOpacity(0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    )
                  ],
                ),
                child: const Center(
                  child: Text(
                    'CONTINUE →',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String icon;
  final String value;
  final String label;
  final Color color;

  const _StatItem({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(icon, style: const TextStyle(fontSize: 28)),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Fail dialog
// ---------------------------------------------------------------------------
class _FailDialog extends StatelessWidget {
  final VoidCallback onRetry;
  final VoidCallback onExit;

  const _FailDialog({required this.onRetry, required this.onExit});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: const Color(0xFFE53935).withOpacity(0.4),
            width: 2,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('💔', style: TextStyle(fontSize: 64))
                .animate()
                .shake(duration: 600.ms),
            const SizedBox(height: 12),
            Text(
              '¡Sin corazones!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'No te rindas. ¡Inténtalo de nuevo!',
              style: TextStyle(
                fontSize: 14,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 28),

            // Retry button
            GestureDetector(
              onTap: onRetry,
              child: Container(
                width: double.infinity,
                height: 52,
                decoration: BoxDecoration(
                  color: const Color(0xFFE53935),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFE53935).withOpacity(0.35),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    )
                  ],
                ),
                child: const Center(
                  child: Text(
                    '🔄  RETRY',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Exit button
            GestureDetector(
              onTap: onExit,
              child: Container(
                width: double.infinity,
                height: 52,
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Text(
                    'Exit',
                    style: TextStyle(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
