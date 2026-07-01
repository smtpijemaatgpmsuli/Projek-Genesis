# e-Raport Sekolah Minggu

> Digital Sunday School Report Management System

## Project Information

| Item | Value |
|------|-------|
| Project Name | e-Raport Sekolah Minggu |
| Codename | Genesis |
| Version | 1.0.0 |
| Status | Development |
| Repository Type | Private |
| Development Model | Documentation First |
| UI Strategy | Responsive First |
| Primary Platform | Flutter |
| Backend | Supabase |

## Overview

e-Raport Sekolah Minggu adalah aplikasi digital yang dirancang untuk membantu pengelolaan administrasi Sekolah Minggu dalam satu gereja.

## Project Goals

- Digitalisasi administrasi Sekolah Minggu
- Mempermudah pekerjaan Pengasuh
- Mempermudah pekerjaan Admin
- Memberikan akses Orang Tua melihat perkembangan anak
- Sistem mudah dikembangkan

## User Roles

1. Super Admin
2. Admin
3. Pengasuh
4. Orang Tua / Anak

## Responsive First

Seluruh fitur wajib mendukung Mobile dan Desktop sejak awal implementasi.

## Technology Stack

- Flutter
- Dart
- Supabase
- PostgreSQL
- Git & GitHub

## Repository Structure

```text
e-raport-sekolah-minggu/
.github/
docs/
knowledge/
decisions/
prompts/
assets/
lib/
supabase/
README.md
LICENSE
CHANGELOG.md
```

## AI Rules

- Dokumentasi adalah sumber kebenaran utama.
- AI tidak boleh mengubah arsitektur tanpa persetujuan.
- AI tidak boleh menghapus branding.
- AI tidak boleh mengubah database tanpa persetujuan.

## Git Workflow

main -> develop -> feature/* -> review -> merge

## Commit Convention

- feat:
- fix:
- docs:
- refactor:
- style:
- test:
- chore:

## Getting Started

### Prasyarat

- Flutter (versi stable)
- Dart SDK
- Supabase project (URL & anon key)
- Git

### Konfigurasi Lingkungan

1. Salin file `.env.example` menjadi `.env`.
2. Isi variabel berikut berdasarkan project Supabase kamu:
   ```env
   SUPABASE_URL=https://your-project.supabase.co
   SUPABASE_ANON_KEY=your-anon-key
   ```
3. Pastikan fungsi Supabase berikut tersedia:
   - `dashboard_summary`
   - `generate_report_card`
   - `sign_report_card`
   - `class_with_schedule_assignments`
   - `update_class_schedule`
   - `update_class_assignments`
   - `upsert_attendance_records`
   - `upsert_assessments`

### Menjalankan Aplikasi

```bash
flutter pub get
flutter run
```

### Pipeline CI

Proyek menggunakan GitLab CI dengan tahap `flutter analyze` dan `flutter test`. File konfigurasinya berada di `.gitlab-ci.yml`.

## Modul Utama

1. **Manajemen Kelas** – Tambah/edit kelas, jadwal, dan penugasan pengasuh.
2. **Kehadiran** – Catat kehadiran per sesi, pengingat absensi.
3. **Penilaian** – Input nilai spiritual, perilaku, aktivitas.
4. **Rapor Digital** – Ringkasan penilaian & kehadiran, tanda tangan admin/pengasuh.
5. **Notifikasi** – Pengingat dan pemberitahuan rapor siap diakses.

## Pengujian

- `flutter analyze`
- `flutter test`

## Kontribusi

Lihat [CONTRIBUTING.md](./CONTRIBUTING.md) untuk panduan lengkap.
