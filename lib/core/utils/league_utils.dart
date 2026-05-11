import 'package:flutter/material.dart';

class LeagueInfo {
  final String nameEs;
  final String nameEn;
  final IconData icon;
  final Color color;
  final int minXP;
  final int maxXP;

  const LeagueInfo({
    required this.nameEs,
    required this.nameEn,
    required this.icon,
    required this.color,
    required this.minXP,
    required this.maxXP,
  });

  String name(bool isSpanish) => isSpanish ? nameEs : nameEn;
}

const List<LeagueInfo> kLeagues = [
  LeagueInfo(
    nameEs: 'Bronce', nameEn: 'Bronze',
    icon: Icons.shield, color: Color(0xFFCD7F32),
    minXP: 0, maxXP: 499,
  ),
  LeagueInfo(
    nameEs: 'Plata', nameEn: 'Silver',
    icon: Icons.military_tech, color: Color(0xFFC0C0C0),
    minXP: 500, maxXP: 999,
  ),
  LeagueInfo(
    nameEs: 'Oro', nameEn: 'Gold',
    icon: Icons.emoji_events, color: Color(0xFFFFD700),
    minXP: 1000, maxXP: 2999,
  ),
  LeagueInfo(
    nameEs: 'Platino', nameEn: 'Platinum',
    icon: Icons.workspace_premium, color: Color(0xFF90A4AE),
    minXP: 3000, maxXP: 4999,
  ),
  LeagueInfo(
    nameEs: 'Diamante', nameEn: 'Diamond',
    icon: Icons.diamond, color: Color(0xFF00BCD4),
    minXP: 5000, maxXP: 999999,
  ),
];

LeagueInfo leagueForXP(int xp) {
  for (final league in kLeagues.reversed) {
    if (xp >= league.minXP) return league;
  }
  return kLeagues.first;
}

LeagueInfo? nextLeagueForXP(int xp) {
  final current = leagueForXP(xp);
  final idx = kLeagues.indexOf(current);
  if (idx < kLeagues.length - 1) return kLeagues[idx + 1];
  return null;
}

double leagueProgress(int xp) {
  final current = leagueForXP(xp);
  final next = nextLeagueForXP(xp);
  if (next == null) return 1.0;
  final range = next.minXP - current.minXP;
  if (range <= 0) return 1.0;
  return ((xp - current.minXP) / range).clamp(0.0, 1.0);
}
