import 'package:flutter_test/flutter_test.dart';
import 'package:app_kaplan/core/utils/league_utils.dart';

void main() {
  // ── leagueForXP ───────────────────────────────────────────────────────────
  group('leagueForXP', () {
    test('retorna Bronce para 0 XP', () {
      expect(leagueForXP(0).nameEn, 'Bronze');
    });

    test('retorna Bronce en el límite superior (499 XP)', () {
      expect(leagueForXP(499).nameEn, 'Bronze');
    });

    test('retorna Plata en el límite inferior (500 XP)', () {
      expect(leagueForXP(500).nameEn, 'Silver');
    });

    test('retorna Oro para 1000 XP', () {
      expect(leagueForXP(1000).nameEn, 'Gold');
    });

    test('retorna Platino para 3000 XP', () {
      expect(leagueForXP(3000).nameEn, 'Platinum');
    });

    test('retorna Diamante para 5000 XP', () {
      expect(leagueForXP(5000).nameEn, 'Diamond');
    });

    test('retorna Diamante para XP muy alto', () {
      expect(leagueForXP(999999).nameEn, 'Diamond');
    });

    test('name() retorna español cuando isSpanish = true', () {
      expect(leagueForXP(0).name(true), 'Bronce');
    });

    test('name() retorna inglés cuando isSpanish = false', () {
      expect(leagueForXP(0).name(false), 'Bronze');
    });
  });

  // ── nextLeagueForXP ───────────────────────────────────────────────────────
  group('nextLeagueForXP', () {
    test('Bronce tiene siguiente liga Plata', () {
      expect(nextLeagueForXP(0)?.nameEn, 'Silver');
    });

    test('Plata tiene siguiente liga Oro', () {
      expect(nextLeagueForXP(500)?.nameEn, 'Gold');
    });

    test('Oro tiene siguiente liga Platino', () {
      expect(nextLeagueForXP(1500)?.nameEn, 'Platinum');
    });

    test('Platino tiene siguiente liga Diamante', () {
      expect(nextLeagueForXP(4000)?.nameEn, 'Diamond');
    });

    test('Diamante no tiene siguiente liga', () {
      expect(nextLeagueForXP(5000), isNull);
    });

    test('Diamante con XP muy alto no tiene siguiente liga', () {
      expect(nextLeagueForXP(999999), isNull);
    });
  });

  // ── leagueProgress ────────────────────────────────────────────────────────
  group('leagueProgress', () {
    test('0% al inicio de Bronce (0 XP)', () {
      expect(leagueProgress(0), closeTo(0.0, 0.001));
    });

    test('50% a la mitad del rango de Bronce (250 XP de 0-499)', () {
      // Rango Bronce: 0-499 → 500 puntos. 250 = 50%
      expect(leagueProgress(250), closeTo(0.5, 0.01));
    });

    test('100% para Diamante (máxima liga)', () {
      expect(leagueProgress(5000), closeTo(1.0, 0.001));
    });

    test('no supera 1.0 con XP muy alto', () {
      expect(leagueProgress(999999), closeTo(1.0, 0.001));
    });

    test('retorna valor entre 0 y 1 en rango intermedio', () {
      final p = leagueProgress(1500); // mitad del rango Oro (1000-2999)
      expect(p, greaterThan(0.0));
      expect(p, lessThan(1.0));
    });
  });

  // ── kLeagues integridad ───────────────────────────────────────────────────
  group('kLeagues constante', () {
    test('contiene exactamente 5 ligas', () {
      expect(kLeagues.length, 5);
    });

    test('liga inicial comienza en 0 XP', () {
      expect(kLeagues.first.minXP, 0);
    });

    test('cada liga comienza donde termina la anterior', () {
      for (int i = 1; i < kLeagues.length; i++) {
        expect(kLeagues[i].minXP, kLeagues[i - 1].maxXP + 1);
      }
    });

    test('la última liga tiene maxXP = 999999 (tope)', () {
      expect(kLeagues.last.maxXP, 999999);
    });
  });
}
