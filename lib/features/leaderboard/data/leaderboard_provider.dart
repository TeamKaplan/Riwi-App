import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final leaderboardProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final supabase = Supabase.instance.client;
  
  final response = await supabase
      .from('profiles')
      .select('id, full_name, xp, avatar_url')
      .order('xp', ascending: false)
      .limit(50);
      
  return List<Map<String, dynamic>>.from(response);
});
