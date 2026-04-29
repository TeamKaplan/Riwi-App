import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/router.dart';

void main() {
  runApp(
    // ProviderScope es necesario para Riverpod
    const ProviderScope(
      child: KaplanApp(),
    ),
  );
}

class KaplanApp extends ConsumerWidget {
  const KaplanApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Obtenemos nuestro router de Riverpod
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'RIWI App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6B5BFC), // Morado RIWI
          surface: const Color(0xFF171B36), // Azul oscuro fondo
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: const Color(0xFF171B36),
        useMaterial3: true,
        fontFamily: 'Inter', // Idealmente añadiríamos una fuente moderna
      ),
      routerConfig: router,
    );
  }
}
