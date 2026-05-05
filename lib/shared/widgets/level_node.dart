import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class LevelNode extends StatelessWidget {
  final int levelNumber;
  final bool isUnlocked;
  final bool isCompleted;
  final VoidCallback onTap;
  final double offset;
  final Color courseColor;
  final IconData icon;
  final double progress; // Progreso dentro del nivel (0.0 a 1.0)
  final bool isChest; // Nuevo: Indica si este nodo es un cofre

  const LevelNode({
    super.key,
    required this.levelNumber,
    required this.isUnlocked,
    required this.isCompleted,
    required this.onTap,
    this.offset = 0.0,
    this.courseColor = Colors.amber,
    this.icon = Icons.star_rounded,
    this.progress = 0.0,
    this.isChest = false,
  });

  @override
  Widget build(BuildContext context) {
    final Color nodeColor = isCompleted
        ? courseColor
        : (isUnlocked ? courseColor.withOpacity(0.12) : Colors.grey.shade200);

    final Color contentColor = isCompleted
        ? Colors.white
        : (isUnlocked ? courseColor : Colors.grey.shade400);

    return Align(
      alignment: Alignment(offset, 0),
      child: GestureDetector(
        onTap: isUnlocked ? onTap : null,
        child: SizedBox(
          width: 100,
          height: 100,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Barra de progreso circular (Solo para niveles normales)
              if (isUnlocked && !isChest)
                SizedBox(
                  width: 82,
                  height: 82,
                  child: CircularProgressIndicator(
                    value: isCompleted ? 1.0 : progress,
                    strokeWidth: 5,
                    color: courseColor,
                    backgroundColor: courseColor.withOpacity(0.1),
                    strokeCap: StrokeCap.round,
                  ),
                ),

              // Círculo principal o Cofre Estilizado
              Container(
                width: isChest ? 84 : 66,
                height: isChest ? 74 : 66,
                decoration: BoxDecoration(
                  shape: isChest ? BoxShape.rectangle : BoxShape.circle,
                  borderRadius: isChest ? BorderRadius.circular(18) : null,
                  gradient: isChest
                      ? LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: isCompleted
                              ? [Colors.grey.shade400, Colors.grey.shade600]
                              : (isUnlocked
                                  ? [const Color(0xFFFFD700), const Color(0xFFFFA000)]
                                  : [Colors.grey.shade300, Colors.grey.shade400]),
                        )
                      : null,
                  color: isChest ? null : nodeColor,
                  boxShadow: [
                    if (isUnlocked && !isCompleted)
                      BoxShadow(
                        color: (isChest ? Colors.amber : courseColor).withOpacity(0.3),
                        blurRadius: 15,
                        spreadRadius: 2,
                      ),
                    if (isChest)
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        offset: const Offset(0, 4),
                        blurRadius: 4,
                      ),
                  ],
                ),
                child: Center(
                  child: isUnlocked
                      ? Icon(
                          isChest ? (isCompleted ? Icons.drafts_rounded : Icons.card_giftcard_rounded) : icon,
                          color: isChest ? Colors.white : contentColor,
                          size: isChest ? 42 : 30,
                        )
                      : Icon(isChest ? Icons.card_giftcard_rounded : Icons.lock, 
                          color: Colors.grey.shade500, size: isChest ? 38 : 24),
                ),
              ),
              
              // Número de nivel en pequeño
              if (isUnlocked && !isChest)
                Positioned(
                  bottom: 4,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 1),
                    decoration: BoxDecoration(
                      color: isCompleted ? Colors.white : courseColor,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isCompleted ? courseColor : Colors.white, 
                        width: 1.5
                      ),
                    ),
                    child: Text(
                      '$levelNumber',
                      style: TextStyle(
                        color: isCompleted ? courseColor : Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ).animate(
        target: (isUnlocked && !isCompleted) ? 1 : 0,
        onPlay: (controller) => controller.repeat(reverse: true),
      ).scale(
        begin: const Offset(1, 1),
        end: const Offset(1.05, 1.05),
        duration: 1200.ms,
        curve: Curves.easeInOut,
      ),
    );
  }
}
