import 'package:flutter/material.dart';
import 'dart:math' as math;

class AiTutorScreen extends StatefulWidget {
  const AiTutorScreen({super.key});

  @override
  State<AiTutorScreen> createState() => _AiTutorScreenState();
}

class _AiTutorScreenState extends State<AiTutorScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _rotateController;
  late AnimationController _breatheController;
  late AnimationController _innerRotateController;
  late AnimationController _waveController;
  bool _isListening = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _rotateController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();

    _innerRotateController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();

    _breatheController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat(reverse: true);

    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    )..repeat();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _rotateController.dispose();
    _innerRotateController.dispose();
    _breatheController.dispose();
    _waveController.dispose();
    super.dispose();
  }

  void _onTapDown() {
    setState(() => _isListening = true);
    // Acelerar rotaciones cuando escucha
    _rotateController.duration = const Duration(seconds: 2);
    _innerRotateController.duration = const Duration(milliseconds: 1500);
    _waveController.duration = const Duration(milliseconds: 1000);
  }

  void _onTapUp() {
    setState(() => _isListening = false);
    // Volver a velocidad normal
    _rotateController.duration = const Duration(seconds: 6);
    _innerRotateController.duration = const Duration(seconds: 4);
    _waveController.duration = const Duration(milliseconds: 2500);
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final orbSize = screenWidth * 0.7; // Orbe grande como Gemini

    return Scaffold(
      backgroundColor: const Color(0xFF0A0D1F),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Tutor IA',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // ===== ORB GIGANTE ESTILO GEMINI =====
            GestureDetector(
              onTapDown: (_) => _onTapDown(),
              onTapUp: (_) => _onTapUp(),
              onTapCancel: () => _onTapUp(),
              child: SizedBox(
                width: orbSize + 40,
                height: orbSize + 40,
                child: ListenableBuilder(
                  listenable: Listenable.merge([
                    _pulseController,
                    _rotateController,
                    _breatheController,
                    _innerRotateController,
                    _waveController,
                  ]),
                  builder: (context, child) {
                    final pulse = _pulseController.value;
                    final rotate = _rotateController.value * 2 * math.pi;
                    final innerRotate = _innerRotateController.value * -2 * math.pi;
                    final breathe = _breatheController.value;
                    final wave = _waveController.value;
                    final wave2 = (_waveController.value + 0.5) % 1.0;

                    return Stack(
                      alignment: Alignment.center,
                      children: [
                        // === ONDAS DE SONIDO EXTERIORES (Ripples) ===
                        Container(
                          width: orbSize + (wave * 180),
                          height: orbSize + (wave * 180),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: (_isListening ? const Color(0xFF00E5FF) : const Color(0xFF6B5BFC))
                                  .withOpacity((1 - wave) * (_isListening ? 0.5 : 0.15)),
                              width: 1.5,
                            ),
                          ),
                        ),
                        Container(
                          width: orbSize + (wave2 * 180),
                          height: orbSize + (wave2 * 180),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: (_isListening ? const Color(0xFF00E5FF) : const Color(0xFF6B5BFC))
                                  .withOpacity((1 - wave2) * (_isListening ? 0.5 : 0.15)),
                              width: 1.5,
                            ),
                          ),
                        ),

                        // === CAPA 1: Aura exterior máxima ===
                        Container(
                          width: orbSize + 40 + (breathe * 15),
                          height: orbSize + 40 + (breathe * 15),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: _isListening
                                    ? const Color(0xFF00E5FF).withOpacity(0.2 + pulse * 0.15)
                                    : const Color(0xFF6B5BFC).withOpacity(0.12 + pulse * 0.08),
                                blurRadius: 80,
                                spreadRadius: 30,
                              ),
                              BoxShadow(
                                color: const Color(0xFFAB47BC).withOpacity(0.08 + pulse * 0.05),
                                blurRadius: 100,
                                spreadRadius: 40,
                              ),
                            ],
                          ),
                        ),

                        // === CAPA 2: Aurora exterior sweep ===
                        Transform.rotate(
                          angle: rotate,
                          child: Container(
                            width: orbSize + 20 + (breathe * 10),
                            height: orbSize + 20 + (breathe * 10),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: SweepGradient(
                                colors: [
                                  const Color(0xFF6B5BFC).withOpacity(0.0),
                                  Color.lerp(
                                    const Color(0xFF00E5FF),
                                    const Color(0xFFAB47BC),
                                    pulse,
                                  )!.withOpacity(_isListening ? 0.35 : 0.2),
                                  const Color(0xFF6B5BFC).withOpacity(_isListening ? 0.3 : 0.15),
                                  const Color(0xFF00E5FF).withOpacity(0.0),
                                  const Color(0xFFAB47BC).withOpacity(_isListening ? 0.3 : 0.12),
                                  const Color(0xFF6B5BFC).withOpacity(0.0),
                                ],
                              ),
                            ),
                          ),
                        ),

                        // === CAPA 3: Aurora media (dirección contraria) ===
                        Transform.rotate(
                          angle: innerRotate * 0.6,
                          child: Container(
                            width: orbSize - 10 + (breathe * 8),
                            height: orbSize - 10 + (breathe * 8),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: SweepGradient(
                                colors: [
                                  const Color(0xFF00E5FF).withOpacity(0.0),
                                  const Color(0xFF6B5BFC).withOpacity(_isListening ? 0.4 : 0.2),
                                  const Color(0xFFAB47BC).withOpacity(_isListening ? 0.35 : 0.15),
                                  const Color(0xFF00E5FF).withOpacity(_isListening ? 0.4 : 0.2),
                                  const Color(0xFF6B5BFC).withOpacity(0.0),
                                ],
                              ),
                            ),
                          ),
                        ),

                        // === CAPA 4: Esfera sólida principal ===
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          width: _isListening ? orbSize * 0.72 : orbSize * 0.65,
                          height: _isListening ? orbSize * 0.72 : orbSize * 0.65,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [
                                _isListening
                                    ? const Color(0xFF00E5FF).withOpacity(0.5)
                                    : const Color(0xFF6B5BFC).withOpacity(0.35),
                                _isListening
                                    ? const Color(0xFF6B5BFC).withOpacity(0.4)
                                    : const Color(0xFF6B5BFC).withOpacity(0.2),
                                const Color(0xFF0D1025).withOpacity(0.95),
                              ],
                              stops: const [0.0, 0.45, 1.0],
                            ),
                            border: Border.all(
                              color: _isListening
                                  ? const Color(0xFF00E5FF).withOpacity(0.4 + pulse * 0.2)
                                  : const Color(0xFF6B5BFC).withOpacity(0.2 + pulse * 0.15),
                              width: 1.5,
                            ),
                          ),
                        ),

                        // === CAPA 5: Aurora interna (dentro de la esfera) ===
                        Transform.rotate(
                          angle: innerRotate,
                          child: Container(
                            width: _isListening ? orbSize * 0.55 : orbSize * 0.48,
                            height: _isListening ? orbSize * 0.55 : orbSize * 0.48,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: SweepGradient(
                                colors: [
                                  const Color(0xFF6B5BFC).withOpacity(0.0),
                                  const Color(0xFF00E5FF).withOpacity(_isListening ? 0.4 : 0.15),
                                  const Color(0xFFAB47BC).withOpacity(_isListening ? 0.3 : 0.1),
                                  const Color(0xFF00E5FF).withOpacity(0.0),
                                  const Color(0xFF6B5BFC).withOpacity(_isListening ? 0.3 : 0.1),
                                  const Color(0xFF00E5FF).withOpacity(0.0),
                                ],
                              ),
                            ),
                          ),
                        ),

                        // === CAPA 6: Segunda aurora interna (más rápida) ===
                        Transform.rotate(
                          angle: rotate * 1.3,
                          child: Container(
                            width: orbSize * 0.35,
                            height: orbSize * 0.35,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: SweepGradient(
                                colors: [
                                  const Color(0xFFAB47BC).withOpacity(0.0),
                                  const Color(0xFF00E5FF).withOpacity(_isListening ? 0.35 : 0.1),
                                  const Color(0xFF6B5BFC).withOpacity(0.0),
                                  const Color(0xFFAB47BC).withOpacity(_isListening ? 0.25 : 0.08),
                                  const Color(0xFF00E5FF).withOpacity(0.0),
                                ],
                              ),
                            ),
                          ),
                        ),

                        // === CAPA 7: Núcleo brillante ===
                        Container(
                          width: orbSize * 0.15,
                          height: orbSize * 0.15,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [
                                Colors.white.withOpacity(_isListening ? 0.3 : 0.12 + pulse * 0.08),
                                Colors.white.withOpacity(0.0),
                              ],
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),

            const SizedBox(height: 48),

            // Texto
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: _isListening
                  ? Text(
                      'Escuchando...',
                      key: const ValueKey('listening'),
                      style: TextStyle(
                        color: const Color(0xFF00E5FF).withOpacity(0.7),
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        letterSpacing: 3,
                      ),
                    )
                  : Text(
                      'presiona para hablar',
                      key: const ValueKey('idle'),
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.3),
                        fontSize: 15,
                        fontWeight: FontWeight.w300,
                        letterSpacing: 3,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
