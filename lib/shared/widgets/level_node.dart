import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class LevelNode extends StatelessWidget {
  final int levelNumber;
  final bool isUnlocked;
  final bool isCompleted;
  final VoidCallback onTap;
  final double offset;
  final Color courseColor;

  const LevelNode({
    super.key,
    required this.levelNumber,
    required this.isUnlocked,
    required this.isCompleted,
    required this.onTap,
    this.offset = 0.0,
    this.courseColor = Colors.amber,
  });

  @override
  Widget build(BuildContext context) {
    final Color nodeColor = isCompleted
        ? courseColor
        : (isUnlocked ? courseColor.withOpacity(0.85) : Colors.grey.shade700);

    final Color shadowColor = isCompleted
        ? HSLColor.fromColor(courseColor).withLightness(0.25).toColor()
        : (isUnlocked
            ? HSLColor.fromColor(courseColor).withLightness(0.3).toColor()
            : Colors.grey.shade800);

    return Align(
      alignment: Alignment(offset, 0),
      child: GestureDetector(
        onTap: isUnlocked ? onTap : null,
        child: Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: nodeColor,
            boxShadow: [
              BoxShadow(
                color: shadowColor,
                offset: const Offset(0, 6),
              ),
              if (isUnlocked && !isCompleted)
                BoxShadow(
                  color: courseColor.withOpacity(0.3),
                  blurRadius: 15,
                  spreadRadius: 2,
                )
            ],
            border: Border.all(
              color: isUnlocked ? Colors.white : Colors.grey.shade600,
              width: 4,
            ),
          ),
          child: Center(
            child: isCompleted
                ? const Icon(Icons.star_rounded, color: Colors.white, size: 40)
                : isUnlocked
                    ? Text(
                        '$levelNumber',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : Icon(Icons.lock, color: Colors.grey.shade500, size: 28),
          ),
        ),
      ).animate(
        target: (isUnlocked && !isCompleted) ? 1 : 0,
        onPlay: (controller) => controller.repeat(reverse: true),
      ).scale(
        begin: const Offset(1, 1),
        end: const Offset(1.1, 1.1),
        duration: 800.ms,
        curve: Curves.easeInOut,
      ),
    );
  }
}
