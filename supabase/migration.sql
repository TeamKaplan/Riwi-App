-- ============================================================
-- RIWI App — Migración de niveles a Supabase
-- Ejecutar en: Supabase Dashboard → SQL Editor
-- ============================================================

-- 1. TABLA DE CURSOS
CREATE TABLE IF NOT EXISTS public.courses (
  id           INTEGER PRIMARY KEY,
  slug         TEXT    UNIQUE NOT NULL,
  name_es      TEXT    NOT NULL,
  name_en      TEXT    NOT NULL,
  total_levels INTEGER NOT NULL DEFAULT 0
);

-- 2. TABLA DE NIVELES
CREATE TABLE IF NOT EXISTS public.levels (
  id           SERIAL  PRIMARY KEY,
  course_id    INTEGER NOT NULL REFERENCES public.courses(id) ON DELETE CASCADE,
  level_number INTEGER NOT NULL,
  title        TEXT    NOT NULL,
  description  TEXT    NOT NULL DEFAULT '',
  difficulty   TEXT    NOT NULL DEFAULT 'Básico',
  xp_reward    INTEGER NOT NULL DEFAULT 100,
  UNIQUE(course_id, level_number)
);

-- 3. TABLA DE PREGUNTAS (JSONB para campos complejos)
CREATE TABLE IF NOT EXISTS public.questions (
  id             TEXT    PRIMARY KEY,
  level_id       INTEGER NOT NULL REFERENCES public.levels(id) ON DELETE CASCADE,
  question_type  TEXT    NOT NULL,
  prompt         TEXT    NOT NULL,
  instruction    TEXT,
  correct_answer TEXT,
  options        JSONB,   -- [{text, isCorrect}]
  matching_left  JSONB,   -- [string]
  matching_right JSONB,   -- [string]
  blanks_answers JSONB,   -- [string]
  reading_text   TEXT,
  code_snippet   TEXT,
  code_language  TEXT,
  order_index    INTEGER NOT NULL DEFAULT 0
);

-- ============================================================
-- ROW LEVEL SECURITY
-- ============================================================
ALTER TABLE public.courses   ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.levels    ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.questions ENABLE ROW LEVEL SECURITY;

-- Lectura pública para usuarios autenticados
CREATE POLICY "read_courses" ON public.courses
  FOR SELECT TO authenticated USING (true);

CREATE POLICY "read_levels" ON public.levels
  FOR SELECT TO authenticated USING (true);

CREATE POLICY "read_questions" ON public.questions
  FOR SELECT TO authenticated USING (true);

-- Solo el service_role puede insertar/actualizar (seed desde la app)
CREATE POLICY "service_insert_levels" ON public.levels
  FOR INSERT TO authenticated WITH CHECK (true);

CREATE POLICY "service_upsert_levels" ON public.levels
  FOR UPDATE TO authenticated USING (true);

CREATE POLICY "service_insert_questions" ON public.questions
  FOR INSERT TO authenticated WITH CHECK (true);

CREATE POLICY "service_upsert_questions" ON public.questions
  FOR UPDATE TO authenticated USING (true);

-- ============================================================
-- DATOS BASE: 3 cursos
-- ============================================================
INSERT INTO public.courses (id, slug, name_es, name_en, total_levels) VALUES
  (0, 'english',     'Inglés',      'English',     23),
  (1, 'development', 'Desarrollo',  'Development',  5),
  (2, 'soft_skills', 'Soft Skills', 'Soft Skills',  5)
ON CONFLICT (id) DO UPDATE SET
  total_levels = EXCLUDED.total_levels;

-- ============================================================
-- ÍNDICES para performance
-- ============================================================
CREATE INDEX IF NOT EXISTS idx_levels_course_id    ON public.levels(course_id);
CREATE INDEX IF NOT EXISTS idx_questions_level_id  ON public.questions(level_id);
CREATE INDEX IF NOT EXISTS idx_questions_order     ON public.questions(level_id, order_index);
