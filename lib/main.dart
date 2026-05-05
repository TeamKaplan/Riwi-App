import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/router.dart';
import 'core/providers/locale_provider.dart';
import 'core/providers/theme_provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  await dotenv.load(fileName: ".env");
  runApp(const ProviderScope(child: KaplanApp()));
}


class KaplanApp extends ConsumerWidget {
  const KaplanApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Obtenemos nuestro router de Riverpod
    final router = ref.watch(routerProvider);
    // Obtenemos el idioma actual
    final locale = ref.watch(localeProvider);
    // Obtenemos el tema actual
    final themeMode = ref.watch(themeProvider);

    return MaterialApp.router(
      title: 'RIWI App',
      debugShowCheckedModeBanner: false,
      locale: locale,
      themeMode: themeMode,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6B5BFC),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        fontFamily: 'Inter',
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6B5BFC), // Morado RIWI
          surface: const Color(0xFF171B36), // Azul oscuro fondo
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: const Color(0xFF171B36),
        useMaterial3: true,
        fontFamily: 'Inter',
      ),
      routerConfig: router,
    );
  }
}
