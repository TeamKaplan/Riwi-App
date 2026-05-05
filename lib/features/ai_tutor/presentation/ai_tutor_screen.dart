import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math' as math;
import '../../../core/providers/locale_provider.dart';
import '../../../core/providers/theme_provider.dart';
import '../../../core/services/groq_service.dart';
import '../../../core/services/tts_service.dart';

class AiTutorScreen extends ConsumerStatefulWidget {
  const AiTutorScreen({super.key});

  @override
  ConsumerState<AiTutorScreen> createState() => _AiTutorScreenState();
}

class _AiTutorScreenState extends ConsumerState<AiTutorScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _rotateController;
  late AnimationController _breatheController;
  late AnimationController _innerRotateController;
  late AnimationController _waveController;
  bool _isListening = false;
  bool _isTranscribing = false;
  bool _isThinking = false;
  String _transcribedText = '';
  String _tutorResponse = '';
  final GroqService _groqService = GroqService();
  final TtsService _ttsService = TtsService();

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

  void _onTapDown() async {
    await _ttsService.stop(); // Detener cualquier audio previo
    setState(() {
      _isListening = true;
      _transcribedText = '';
      _tutorResponse = '';
    });
    // Acelerar rotaciones cuando escucha
    _rotateController.duration = const Duration(seconds: 2);
    _innerRotateController.duration = const Duration(milliseconds: 1500);
    _waveController.duration = const Duration(milliseconds: 1000);
    
    await _groqService.startRecording();
  }

  void _onTapUp() async {
    setState(() {
      _isListening = false;
      _isTranscribing = true;
    });
    // Volver a velocidad normal
    _rotateController.duration = const Duration(seconds: 6);
    _innerRotateController.duration = const Duration(seconds: 4);
    _waveController.duration = const Duration(milliseconds: 2500);
    
    final result = await _groqService.stopRecordingAndTranscribe();
    if (result != null && result['text'] != null) {
      final userText = result['text'] as String;
      if (mounted) {
        setState(() {
          _transcribedText = userText;
          _isTranscribing = false;
          _isThinking = true;
        });
      }
      
      // Llamar al LLM para la respuesta
      final response = await _groqService.generateTutorResponse(userText);
      
      if (mounted && response != null) {
        setState(() {
          _tutorResponse = response;
          _isThinking = false;
        });
        
        // Hablar la respuesta usando TTS
        await _ttsService.speak(response);
      } else if (mounted) {
        setState(() {
          _isThinking = false;
        });
      }
    } else {
      if (mounted) {
        setState(() {
          _isTranscribing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isSpanish = ref.watch(localeProvider).languageCode == 'es';
    final isDarkMode = ref.watch(themeProvider) == ThemeMode.dark;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final screenWidth = MediaQuery.of(context).size.width;
    final orbSize = screenWidth * 0.7; // Orbe grande como Gemini

    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF0A0D1F) : colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          isSpanish ? 'Tutor IA' : 'AI Tutor',
          style: TextStyle(
            color: colorScheme.onSurface,
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
                              color: (_isListening ? const Color(0xFF00E5FF) : colorScheme.primary)
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
                              color: (_isListening ? const Color(0xFF00E5FF) : colorScheme.primary)
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
                                    : colorScheme.primary.withOpacity(0.12 + pulse * 0.08),
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
                                  colorScheme.primary.withOpacity(0.0),
                                  Color.lerp(
                                    const Color(0xFF00E5FF),
                                    const Color(0xFFAB47BC),
                                    pulse,
                                  )!.withOpacity(_isListening ? 0.35 : 0.2),
                                  colorScheme.primary.withOpacity(_isListening ? 0.3 : 0.15),
                                  const Color(0xFF00E5FF).withOpacity(0.0),
                                  const Color(0xFFAB47BC).withOpacity(_isListening ? 0.3 : 0.12),
                                  colorScheme.primary.withOpacity(0.0),
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
                                  colorScheme.primary.withOpacity(_isListening ? 0.4 : 0.2),
                                  const Color(0xFFAB47BC).withOpacity(_isListening ? 0.35 : 0.15),
                                  const Color(0xFF00E5FF).withOpacity(_isListening ? 0.4 : 0.2),
                                  colorScheme.primary.withOpacity(0.0),
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
                                    : colorScheme.primary.withOpacity(0.35),
                                _isListening
                                    ? colorScheme.primary.withOpacity(0.4)
                                    : colorScheme.primary.withOpacity(0.2),
                                (isDarkMode ? const Color(0xFF0D1025) : colorScheme.surface)
                                    .withOpacity(0.95),
                              ],
                              stops: const [0.0, 0.45, 1.0],
                            ),
                            border: Border.all(
                              color: _isListening
                                  ? const Color(0xFF00E5FF).withOpacity(0.4 + pulse * 0.2)
                                  : colorScheme.primary.withOpacity(0.2 + pulse * 0.15),
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
                                  colorScheme.primary.withOpacity(0.0),
                                  const Color(0xFF00E5FF).withOpacity(_isListening ? 0.4 : 0.15),
                                  const Color(0xFFAB47BC).withOpacity(_isListening ? 0.3 : 0.1),
                                  const Color(0xFF00E5FF).withOpacity(0.0),
                                  colorScheme.primary.withOpacity(_isListening ? 0.3 : 0.1),
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
                                  colorScheme.primary.withOpacity(0.0),
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
                                (isDarkMode ? Colors.white : colorScheme.primary)
                                    .withOpacity(_isListening ? 0.3 : 0.12 + pulse * 0.08),
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

            // Texto de estado central
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: _isListening
                  ? Text(
                      isSpanish ? 'Escuchando...' : 'Listening...',
                      key: const ValueKey('listening'),
                      style: TextStyle(
                        color: const Color(0xFF00E5FF).withOpacity(0.7),
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        letterSpacing: 3,
                      ),
                    )
                  : _isTranscribing
                      ? Text(
                          isSpanish ? 'Transcribiendo...' : 'Transcribing...',
                          key: const ValueKey('transcribing'),
                          style: TextStyle(
                            color: const Color(0xFFAB47BC).withOpacity(0.7),
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                            letterSpacing: 3,
                          ),
                        )
                      : _isThinking
                          ? Text(
                              isSpanish ? 'Pensando...' : 'Thinking...',
                              key: const ValueKey('thinking'),
                              style: TextStyle(
                                color: colorScheme.primary.withOpacity(0.7),
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                                letterSpacing: 3,
                              ),
                            )
                          : Text(
                              isSpanish ? 'presiona para hablar' : 'press to speak',
                              key: const ValueKey('idle'),
                              style: TextStyle(
                                color: colorScheme.onSurface.withOpacity(0.3),
                                fontSize: 15,
                                fontWeight: FontWeight.w300,
                                letterSpacing: 3,
                              ),
                            ),
            ),
            
            const SizedBox(height: 24),
            
            // Área de conversación
            if (_transcribedText.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  children: [
                    // Texto del usuario
                    Align(
                      alignment: Alignment.centerRight,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: colorScheme.primary.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20).copyWith(bottomRight: const Radius.circular(5)),
                        ),
                        child: Text(
                          _transcribedText,
                          style: TextStyle(
                            color: colorScheme.onSurface,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Respuesta del tutor
                    if (_tutorResponse.isNotEmpty)
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: isDarkMode ? const Color(0xFF1E223D) : Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(20).copyWith(bottomLeft: const Radius.circular(5)),
                            border: Border.all(
                              color: const Color(0xFF00E5FF).withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            _tutorResponse,
                            style: TextStyle(
                              color: colorScheme.onSurface,
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
