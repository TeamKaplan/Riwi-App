import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/learning/data/models/level_model.dart';
import '../services/levels_service.dart';

/// Provider asíncrono: carga niveles desde Supabase con fallback local.
/// Riverpod cachea el resultado por courseIndex mientras el widget esté vivo.
final levelsProvider = FutureProvider.family<List<Level>, int>((ref, courseIndex) {
  return LevelsService.getLevels(courseIndex);
});
