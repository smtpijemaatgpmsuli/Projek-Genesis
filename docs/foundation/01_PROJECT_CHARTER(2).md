# PROJECT CHARTER

**Document ID:** DOC-002\
**Title:** Project Charter\
**Project:** e-Raport Sekolah Minggu (Genesis)\
**Version:** 1.0.0\
**Status:** Approved\
**Owner:** Jondry Suitela\
**Last Updated:** 30 June 2026

------------------------------------------------------------------------

# 1. Latar Belakang

e-Raport Sekolah Minggu dibangun untuk mendigitalisasi proses
administrasi Sekolah Minggu pada **satu gereja**. Proyek ini lahir dari
kebutuhan akan sistem yang mudah digunakan oleh Pengasuh melalui
perangkat mobile dan nyaman dikelola oleh Admin melalui desktop.

Dokumentasi menjadi dasar utama seluruh pengembangan agar proyek tetap
konsisten meskipun dikerjakan oleh AI maupun developer yang berbeda.

# 2. Tujuan

-   Membangun aplikasi administrasi Sekolah Minggu yang modern.
-   Menyediakan rapor digital.
-   Mempermudah pengelolaan data anak, kelas, absensi, dan nilai.
-   Memberikan akses Orang Tua untuk melihat hasil belajar anak.
-   Menyediakan fondasi yang mudah dikembangkan di masa depan.

# 3. Ruang Lingkup

## Termasuk

-   Login & autentikasi
-   Manajemen pengguna
-   Data anak
-   Data kelas
-   Absensi
-   Penilaian
-   Rapor
-   Dashboard
-   Laporan dasar

## Tidak Termasuk

-   Sistem Keuangan Gereja
-   Warta Jemaat
-   Multi Gereja
-   Inventaris Gereja
-   Chat
-   Media Sosial

# 4. Stakeholder

  Stakeholder        Peran
  ------------------ --------------------------------------------
  Project Owner      Menentukan arah proyek
  Super Admin        Mengelola seluruh aplikasi
  Admin              Mengelola pengasuh
  Pengasuh           Mengelola data anak, absensi, nilai, rapor
  Orang Tua / Anak   Melihat hasil rapor

# 5. Target Platform

## Mobile

-   Android
-   Pengasuh
-   Orang Tua / Anak

## Desktop

-   Windows
-   Admin
-   Super Admin

Seluruh fitur wajib mengikuti prinsip **Responsive First**.

# 6. Prinsip Pengembangan

1.  Documentation First
2.  Responsive First
3.  GitHub First
4.  Security First
5.  Maintainability First

# 7. Deliverables

-   Dokumentasi lengkap
-   Aplikasi Flutter
-   Backend Supabase
-   Database PostgreSQL
-   GitHub Repository
-   CI/CD (tahap berikutnya)

# 8. Risiko

-   Perubahan kebutuhan pengguna
-   Pergantian AI agent
-   Perubahan struktur database
-   Inkonsistensi UI

Mitigasi dilakukan melalui dokumentasi, ADR, dan review sebelum
implementasi.

# 9. Kriteria Keberhasilan

-   Pengasuh dapat menggunakan aplikasi melalui HP.
-   Admin nyaman menggunakan desktop.
-   Orang Tua dapat melihat rapor.
-   Seluruh fitur utama stabil pada Mobile dan Desktop.

# 10. Persetujuan

Dokumen ini menjadi dasar resmi pelaksanaan proyek dan menjadi acuan
seluruh keputusan teknis maupun bisnis.
