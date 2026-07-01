-- ============================================================
-- e-Raport Sekolah Minggu (Genesis) — Initial Schema
-- Document Reference: 08_DATABASE_GUIDELINES.md
-- Migration: 20260701000001
-- ============================================================

-- ----------------------------
-- EXTENSIONS
-- ----------------------------
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- ----------------------------
-- ENUMS
-- ----------------------------
CREATE TYPE user_role AS ENUM ('super_admin', 'admin', 'pengasuh', 'orang_tua');
CREATE TYPE attendance_status AS ENUM ('present', 'absent', 'excused');

-- ----------------------------
-- TABLES
-- ----------------------------

-- 1. PROFILES (extends Supabase auth.users)
CREATE TABLE profiles (
  id          UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  email       TEXT,
  full_name   TEXT NOT NULL DEFAULT '',
  role        user_role NOT NULL DEFAULT 'pengasuh',
  created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 2. ACADEMIC YEARS
CREATE TABLE academic_years (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name        TEXT NOT NULL,
  is_active   BOOLEAN NOT NULL DEFAULT false,
  started_at  DATE NOT NULL,
  ended_at    DATE,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  created_by  UUID REFERENCES profiles(id)
);

-- 3. CLASSES
CREATE TABLE classes (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name        TEXT NOT NULL,
  description TEXT DEFAULT '',
  academic_year_id UUID NOT NULL REFERENCES academic_years(id),
  is_active   BOOLEAN NOT NULL DEFAULT true,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  created_by  UUID REFERENCES profiles(id)
);

-- 4. CLASS ASSIGNMENTS (pengasuh → class)
CREATE TABLE class_assignments (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  class_id    UUID NOT NULL REFERENCES classes(id) ON DELETE CASCADE,
  profile_id  UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  role        TEXT NOT NULL DEFAULT 'pengasuh',
  created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE(class_id, profile_id)
);

-- 5. STUDENTS
CREATE TABLE students (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  full_name   TEXT NOT NULL,
  class_id    UUID NOT NULL REFERENCES classes(id),
  parent_id   UUID REFERENCES profiles(id),
  is_active   BOOLEAN NOT NULL DEFAULT true,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  created_by  UUID REFERENCES profiles(id)
);

-- 6. ATTENDANCE SESSIONS
CREATE TABLE attendance_sessions (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  class_id    UUID NOT NULL REFERENCES classes(id) ON DELETE CASCADE,
  date        DATE NOT NULL,
  topic       TEXT DEFAULT '',
  created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  created_by  UUID REFERENCES profiles(id)
);

-- 7. ATTENDANCE RECORDS
CREATE TABLE attendance_records (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  session_id  UUID NOT NULL REFERENCES attendance_sessions(id) ON DELETE CASCADE,
  student_id  UUID NOT NULL REFERENCES students(id) ON DELETE CASCADE,
  status      attendance_status NOT NULL DEFAULT 'present',
  created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE(session_id, student_id)
);

-- 8. ASSESSMENTS
CREATE TABLE assessments (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  student_id  UUID NOT NULL REFERENCES students(id) ON DELETE CASCADE,
  term        TEXT NOT NULL,
  spiritual   INTEGER NOT NULL DEFAULT 0,
  behavior    INTEGER NOT NULL DEFAULT 0,
  activity    INTEGER NOT NULL DEFAULT 0,
  notes       TEXT DEFAULT '',
  created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  created_by  UUID REFERENCES profiles(id)
);

-- 9. REPORT CARDS
CREATE TABLE report_cards (
  id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  student_id          UUID NOT NULL REFERENCES students(id) ON DELETE CASCADE,
  term                TEXT NOT NULL,
  assessment_id       UUID REFERENCES assessments(id),
  admin_signed_at     TIMESTAMPTZ,
  caregiver_signed_at TIMESTAMPTZ,
  issued_at           TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at          TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ----------------------------
-- INDEXES
-- ----------------------------
CREATE INDEX idx_profiles_role ON profiles(role);
CREATE INDEX idx_students_class ON students(class_id);
CREATE INDEX idx_students_parent ON students(parent_id);
CREATE INDEX idx_attendance_sessions_class ON attendance_sessions(class_id);
CREATE INDEX idx_attendance_records_session ON attendance_records(session_id);
CREATE INDEX idx_attendance_records_student ON attendance_records(student_id);
CREATE INDEX idx_assessments_student_term ON assessments(student_id, term);
CREATE INDEX idx_report_cards_student_term ON report_cards(student_id, term);
CREATE INDEX idx_class_assignments_profile ON class_assignments(profile_id);

-- ----------------------------
-- ROW LEVEL SECURITY
-- ----------------------------
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE classes ENABLE ROW LEVEL SECURITY;
ALTER TABLE class_assignments ENABLE ROW LEVEL SECURITY;
ALTER TABLE students ENABLE ROW LEVEL SECURITY;
ALTER TABLE attendance_sessions ENABLE ROW LEVEL SECURITY;
ALTER TABLE attendance_records ENABLE ROW LEVEL SECURITY;
ALTER TABLE assessments ENABLE ROW LEVEL SECURITY;
ALTER TABLE report_cards ENABLE ROW LEVEL SECURITY;
ALTER TABLE academic_years ENABLE ROW LEVEL SECURITY;

-- Profiles: users can read own profile; super_admin can read all
CREATE POLICY profiles_select_own ON profiles
  FOR SELECT USING (id = auth.uid() OR EXISTS (
    SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'super_admin'
  ));

CREATE POLICY profiles_update_own ON profiles
  FOR UPDATE USING (id = auth.uid())
  WITH CHECK (id = auth.uid());

-- Super admin full access to all tables
CREATE POLICY super_admin_all ON classes
  FOR ALL USING (EXISTS (
    SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'super_admin'
  ));

CREATE POLICY super_admin_all_students ON students
  FOR ALL USING (EXISTS (
    SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'super_admin'
  ));

CREATE POLICY super_admin_all_attendance ON attendance_sessions
  FOR ALL USING (EXISTS (
    SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'super_admin'
  ));

CREATE POLICY super_admin_all_assessments ON assessments
  FOR ALL USING (EXISTS (
    SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'super_admin'
  ));

CREATE POLICY super_admin_all_report_cards ON report_cards
  FOR ALL USING (EXISTS (
    SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'super_admin'
  ));

-- ----------------------------
-- RPC FUNCTIONS
-- ----------------------------

-- Generate report card for a student in a given term
CREATE OR REPLACE FUNCTION generate_report_card(
  student_id UUID,
  term TEXT
) RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_student JSONB;
  v_assessment JSONB;
  v_attendance JSONB;
  v_class_name TEXT;
  v_signature JSONB;
  v_report_id UUID;
  v_issued_at TIMESTAMPTZ;
BEGIN
  -- Get student info
  SELECT jsonb_build_object(
    'id', s.id,
    'full_name', s.full_name
  ) INTO v_student
  FROM students s
  WHERE s.id = student_id;

  -- Get class name
  SELECT c.name INTO v_class_name
  FROM students s
  JOIN classes c ON c.id = s.class_id
  WHERE s.id = student_id;

  -- Get assessment
  SELECT jsonb_build_object(
    'id', a.id,
    'spiritual', a.spiritual,
    'behavior', a.behavior,
    'activity', a.activity,
    'notes', COALESCE(a.notes, '')
  ) INTO v_assessment
  FROM assessments a
  WHERE a.student_id = generate_report_card.student_id
    AND a.term = generate_report_card.term
  LIMIT 1;

  -- If no assessment exists, return empty
  IF v_assessment IS NULL THEN
    v_assessment := '{"id": "", "spiritual": 0, "behavior": 0, "activity": 0, "notes": ""}'::JSONB;
  END IF;

  -- Get attendance records
  SELECT jsonb_agg(
    jsonb_build_object(
      'id', ar.id,
      'session_id', ar.session_id,
      'student_id', ar.student_id,
      'status', ar.status::TEXT
    )
  ) INTO v_attendance
  FROM attendance_records ar
  JOIN attendance_sessions a_s ON a_s.id = ar.session_id
  WHERE ar.student_id = generate_report_card.student_id
    AND a_s.date BETWEEN (
      SELECT started_at FROM academic_years WHERE is_active = true
    ) AND COALESCE(
      (SELECT ended_at FROM academic_years WHERE is_active = true),
      CURRENT_DATE
    );

  IF v_attendance IS NULL THEN
    v_attendance := '[]'::JSONB;
  END IF;

  -- Get or create report card for signature tracking
  SELECT rc.id, rc.issued_at INTO v_report_id, v_issued_at
  FROM report_cards rc
  WHERE rc.student_id = generate_report_card.student_id
    AND rc.term = generate_report_card.term
  LIMIT 1;

  IF v_report_id IS NULL THEN
    INSERT INTO report_cards (student_id, term, assessment_id, issued_at)
    VALUES (
      generate_report_card.student_id,
      generate_report_card.term,
      (v_assessment->>'id')::UUID,
      NOW()
    )
    RETURNING id, issued_at INTO v_report_id, v_issued_at;
  END IF;

  -- Get signature info
  SELECT jsonb_build_object(
    'admin_name', COALESCE(admin_profile.full_name, '-'),
    'caregiver_name', COALESCE(caregiver_profile.full_name, '-'),
    'admin_signed_at', rc.admin_signed_at,
    'caregiver_signed_at', rc.caregiver_signed_at
  ) INTO v_signature
  FROM report_cards rc
  LEFT JOIN profiles admin_profile ON admin_profile.id = (
    SELECT created_by FROM classes c
    JOIN students s ON s.class_id = c.id
    WHERE s.id = generate_report_card.student_id
    LIMIT 1
  )
  LEFT JOIN profiles caregiver_profile ON caregiver_profile.id = (
    SELECT ca.profile_id FROM class_assignments ca
    JOIN students s ON s.class_id = ca.class_id
    WHERE s.id = generate_report_card.student_id
    LIMIT 1
  )
  WHERE rc.id = v_report_id;

  -- Return combined result
  RETURN jsonb_build_object(
    'student', v_student,
    'class_name', v_class_name,
    'assessment', v_assessment,
    'attendance', v_attendance,
    'signature', v_signature,
    'issued_at', v_issued_at
  );
END;
$$;

-- Sign report card
CREATE OR REPLACE FUNCTION sign_report_card(
  report_id UUID,
  role TEXT
) RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  IF role = 'admin' THEN
    UPDATE report_cards
    SET admin_signed_at = NOW(), updated_at = NOW()
    WHERE id = report_id;
  ELSIF role = 'caregiver' THEN
    UPDATE report_cards
    SET caregiver_signed_at = NOW(), updated_at = NOW()
    WHERE id = report_id;
  END IF;
END;
$$;

-- ----------------------------
-- TRIGGERS
-- ----------------------------

-- Auto-update updated_at on profile changes
CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$;

CREATE TRIGGER profiles_updated_at
  BEFORE UPDATE ON profiles
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();

CREATE TRIGGER classes_updated_at
  BEFORE UPDATE ON classes
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();

CREATE TRIGGER academic_years_updated_at
  BEFORE UPDATE ON academic_years
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();

CREATE TRIGGER students_updated_at
  BEFORE UPDATE ON students
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();

CREATE TRIGGER assessments_updated_at
  BEFORE UPDATE ON assessments
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();

CREATE TRIGGER report_cards_updated_at
  BEFORE UPDATE ON report_cards
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();

-- Auto-create profile on user signup (triggered by Supabase)
CREATE OR REPLACE FUNCTION handle_new_user()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  INSERT INTO profiles (id, email, full_name, role)
  VALUES (
    NEW.id,
    NEW.email,
    COALESCE(NEW.raw_user_meta_data->>'full_name', ''),
    COALESCE((NEW.raw_user_meta_data->>'role')::user_role, 'pengasuh')
  );
  RETURN NEW;
END;
$$;

CREATE OR REPLACE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION handle_new_user();
