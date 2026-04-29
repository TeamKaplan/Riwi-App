import 'package:flutter/material.dart';
import 'dart:math' as math;

/// Botón flotante central con silueta aurora boreal sutil
class AuroraFab extends StatelessWidget {
  final VoidCallback onTap;

  const AuroraFab({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: _AuroraOrb(),
    );
  }
}

class _AuroraOrb extends StatefulWidget {
  @override
  State<_AuroraOrb> createState() => _AuroraOrbState();
}

class _AuroraOrbState extends State<_AuroraOrb>
    with TickerProviderStateMixin {
  AnimationController? _controller;
  AnimationController? _waveController;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    )..repeat();
  }

  @override
  void dispose() {
    _controller?.dispose();
    _waveController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    final waveController = _waveController;
    if (controller == null || waveController == null) {
      return const SizedBox(width: 58, height: 58);
    }

    return AnimatedBuilder(
      animation: Listenable.merge([controller, waveController]),
      builder: (context, child) {
        final angle = controller.value * 2 * math.pi;
        final pulse = (math.sin(controller.value * math.pi * 2) + 1) / 2;
        final wave = waveController.value;

        return SizedBox(
          width: 88,
          height: 88,
          child: Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
            // Onda de sonido / ripple expansivo
            Container(
              width: 58 + (wave * 30), // Expande 30px hacia afuera
              height: 58 + (wave * 30),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFF6B5BFC).withOpacity((1 - wave) * 0.4),
                  width: 1.5,
                ),
              ),
            ),
            // Contenedor principal
            Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Color.lerp(
                      const Color(0xFF6B5BFC),
                      const Color(0xFF00E5FF),
                      pulse,
                    )!.withOpacity(0.3),
                    blurRadius: 12 + pulse * 6,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Anillo aurora (silueta)
                  Transform.rotate(
                    angle: angle,
                    child: Container(
                      width: 58,
                      height: 58,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: SweepGradient(
                          colors: [
                            const Color(0xFF6B5BFC).withOpacity(0.9),
                            const Color(0xFF00E5FF).withOpacity(0.7),
                            const Color(0xFFAB47BC).withOpacity(0.6),
                            const Color(0xFF00E5FF).withOpacity(0.7),
                            const Color(0xFF6B5BFC).withOpacity(0.9),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Centro oscuro
                  Container(
                    width: 50,
                    height: 50,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFF0D1025),
                    ),
                  ),
                  // Punto de luz central
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          Colors.white.withOpacity(0.3 + pulse * 0.15),
                          Colors.white.withOpacity(0.0),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
         ),
        );
      },
    );
  }
}
