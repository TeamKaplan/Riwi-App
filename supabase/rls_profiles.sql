-- ============================================================
-- RIWI App — RLS para tabla profiles y user_progress
-- Ejecutar en: Supabase Dashboard → SQL Editor
-- ============================================================

-- ── profiles ──────────────────────────────────────────────
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

-- Lectura de datos públicos (username, xp, streak) para todos los usuarios
-- autenticados. Necesario para leaderboard y ligas.
CREATE POLICY "profiles: lectura publica autenticados" ON public.profiles
  FOR SELECT TO authenticated
  USING (true);

-- Solo puedes insertar/actualizar TU propio perfil
CREATE POLICY "profiles: insertar propio" ON public.profiles
  FOR INSERT TO authenticated
  WITH CHECK (auth.uid() = id);

CREATE POLICY "profiles: actualizar propio" ON public.profiles
  FOR UPDATE TO authenticated
  USING (auth.uid() = id)
  WITH CHECK (auth.uid() = id);

-- ── user_progress ─────────────────────────────────────────
ALTER TABLE public.user_progress ENABLE ROW LEVEL SECURITY;

CREATE POLICY "progress: leer propio" ON public.user_progress
  FOR SELECT TO authenticated
  USING (auth.uid() = user_id);

CREATE POLICY "progress: insertar propio" ON public.user_progress
  FOR INSERT TO authenticated
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "progress: actualizar propio" ON public.user_progress
  FOR UPDATE TO authenticated
  USING (auth.uid() = user_id);

-- ── Nota de seguridad ──────────────────────────────────────
-- La lectura pública de profiles expone username, total_xp y streak
-- a todos los usuarios autenticados (intencionado para el ranking).
-- Campos sensibles como `email` no son visibles en las queries del leaderboard
-- ya que las consultas solo seleccionan los campos necesarios.
-- Para proteger el email, puedes crear una vista que excluya ese campo:
--
-- CREATE VIEW public.profiles_public AS
--   SELECT id, username, total_xp, streak, lessons_completed
--   FROM public.profiles;
-- GRANT SELECT ON public.profiles_public TO authenticated;
--
-- Y luego cambiar las queries del leaderboard a usar profiles_public.
