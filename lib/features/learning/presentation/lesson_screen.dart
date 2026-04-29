import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';

class LessonScreen extends StatefulWidget {
  final String lessonId;

  const LessonScreen({super.key, required this.lessonId});

  @override
  State<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends State<LessonScreen> {
  String _answer = '';
  bool _isChecking = false;
  bool? _isCorrect;

  void _checkAnswer() async {
    setState(() {
      _isChecking = true;
    });

    // Simulamos una llamada al Backend/IA
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _isChecking = false;
      // Lógica simulada: Si la respuesta contiene "hello", asumiremos que está correcta para el demo.
      _isCorrect = _answer.trim().toLowerCase().contains('hello');
    });
    
    _showFeedbackModal();
  }

  void _showFeedbackModal() {
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: _isCorrect! ? Colors.green.shade100 : Colors.red.shade100,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          height: 220,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Icon(
                    _isCorrect! ? Icons.check_circle : Icons.cancel,
                    color: _isCorrect! ? Colors.green : Colors.red,
                    size: 40,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    _isCorrect! ? '¡Excelente!' : 'Casi, inténtalo de nuevo',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: _isCorrect! ? Colors.green.shade800 : Colors.red.shade800,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Simulación de "Feedback de IA"
              Text(
                _isCorrect! 
                  ? 'La IA dice: ¡Perfecto! La traducción es natural y correcta.' 
                  : 'La IA dice: Recuerda que "Hola" se traduce comúnmente como "Hello".',
                style: TextStyle(
                  color: _isCorrect! ? Colors.green.shade900 : Colors.red.shade900,
                  fontSize: 16,
                ),
              ),
              const Spacer(),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isCorrect! ? Colors.green : Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  )
                ),
                onPressed: () {
                  Navigator.pop(context); // Cierra el modal
                  if (_isCorrect!) {
                    context.go('/'); // Vuelve al mapa si es correcto
                  } else {
                    setState(() {
                      _isCorrect = null;
                    });
                  }
                },
                child: Text(_isCorrect! ? 'CONTINUAR' : 'REINTENTAR', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              )
            ],
          ),
        );
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.grey),
          onPressed: () => context.go('/'),
        ),
        title: LinearProgressIndicator(
          value: 0.5,
          backgroundColor: Colors.grey.shade200,
          color: Colors.green,
          minHeight: 16,
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Desafío del Nivel ${widget.lessonId}',
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
              const SizedBox(height: 8),
              const Text(
                'Traduce esta frase al inglés',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  // Personaje (Simulado)
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.blue.shade100,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.smart_toy, size: 50, color: Colors.blue),
                  ).animate().shake(duration: 1.seconds, hz: 2), // Animación de bienvenida
                  const SizedBox(width: 16),
                  // Burbuja de diálogo
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300, width: 2),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Text(
                        '¡Hola mundo!',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),
              TextField(
                onChanged: (value) {
                  setState(() {
                    _answer = value;
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Escribe en inglés...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: Colors.grey.shade300, width: 2),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: Colors.blue, width: 2),
                  ),
                ),
                maxLines: 3,
                style: const TextStyle(fontSize: 18),
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: _answer.isEmpty || _isChecking ? null : _checkAnswer,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _answer.isEmpty ? Colors.grey.shade300 : Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: _answer.isEmpty ? 0 : 4,
                ),
                child: _isChecking 
                    ? const SizedBox(
                        height: 24, width: 24, 
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3)
                      )
                    : const Text('COMPROBAR', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
