# AI CONTEXT

**Document ID:** DOC-012  \
**Title:** AI Context  \
**Project:** e-Raport Sekolah Minggu (Genesis)  \
**Version:** 1.0.0  \
**Status:** Approved

---

## Tujuan

Menjadi sumber konteks utama bagi AI atau kontributor baru saat mengerjakan tugas pengembangan e-Raport Sekolah Minggu.

## Ringkasan Proyek

- **Nama:** e-Raport Sekolah Minggu (Genesis)
- **Tujuan Utama:** Digitalisasi administrasi Sekolah Minggu dalam satu gereja.
- **Platform:** Flutter dengan Supabase sebagai backend.
- **Strategi UI:** Responsive First (mobile dan desktop wajib didukung).
- **Model Pengembangan:** Documentation First; seluruh keputusan harus terdokumentasi sebelum dieksekusi.

## Entitas Pengguna

1. **Super Admin** – mengelola konfigurasi global dan akses.
2. **Admin** – menangani operasional harian dan pengelolaan data kelas.
3. **Pengasuh** – mencatat aktivitas dan perkembangan anak.
4. **Orang Tua / Anak** – memantau perkembangan dan laporan nilai.

## Referensi Dokumen Utama

- [00_PROJECT_CONSTITUTION.md](./00_PROJECT_CONSTITUTION.md)
- [01_PROJECT_CHARTER(2).md](./01_PROJECT_CHARTER(2).md)
- [02_VISION.md](./02_VISION.md)
- [03_PROJECT_RULES.md](./03_PROJECT_RULES.md)
- [05_ARCHITECTURE.md](./05_ARCHITECTURE.md)
- [07_CODING_STANDARDS.md](./07_CODING_STANDARDS.md)
- [08_DATABASE_GUIDELINES.md](./08_DATABASE_GUIDELINES.md)
- [11_RESPONSIVE_DESIGN_GUIDELINES.md](./11_RESPONSIVE_DESIGN_GUIDELINES.md)

Seluruh keputusan baru harus konsisten dengan dokumen tersebut.

## Prinsip Kolaborasi AI

- **Documentation First:** setiap perubahan signifikan wajib dirujuk di dokumentasi.
- **No Unauthorized Changes:** AI dilarang mengubah arsitektur, branding, dan skema database tanpa persetujuan eksplisit.
- **Quality Gate:** implementasi harus mematuhi standar Clean Architecture, Riverpod, dan GoRouter sesuai dokumen arsitektur.
- **Transparansi:** laporkan alasan dan referensi dokumen untuk setiap keputusan.

## Batasan Teknis

- **Frontend:** Flutter (stable channel), bahasa Dart.
- **Backend:** Supabase (Auth, Database PostgreSQL, Storage).
- **State Management:** Riverpod.
- **Routing:** GoRouter.
- **Target Platform:** Android dan Windows Desktop.

## Definisi Selesai untuk Tugas AI

1. Dokumentasi diperbarui atau dirujuk sesuai kebutuhan.
2. Kode mengikuti standar penamaan dan struktur yang telah ditetapkan.
3. UI diuji pada ukuran layar mobile dan desktop.
4. Build dan analisis statis bebas dari error kritis.
5. Komit menggunakan konvensi pesan yang telah ditentukan.

## Jalur Eskalasi

- Pertanyaan tentang aturan dan arsitektur: rujuk [03_PROJECT_RULES.md](./03_PROJECT_RULES.md) dan [05_ARCHITECTURE.md](./05_ARCHITECTURE.md).
- Pertanyaan tentang database: rujuk [08_DATABASE_GUIDELINES.md](./08_DATABASE_GUIDELINES.md).
- Ketidaksesuaian bisnis: konfirmasi dengan tim inti proyek melalui Issue sebelum implementasi.

## Penutup

Dokumen ini harus dibaca sebelum AI menjalankan tugas apa pun agar menjaga konsistensi dan kualitas proyek.