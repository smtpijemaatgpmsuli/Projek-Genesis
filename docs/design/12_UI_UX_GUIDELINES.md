# UI/UX GUIDELINES

**Document ID:** DOC-013  \
**Title:** UI/UX Guidelines  \
**Project:** e-Raport Sekolah Minggu (Genesis)  \
**Version:** 1.0.0  \
**Status:** Draft

---

## Tujuan

Menetapkan standar antarmuka dan pengalaman pengguna agar seluruh fitur e-Raport Sekolah Minggu konsisten, mudah digunakan, dan mendukung Responsive First.

## Prinsip Desain

- **Kesederhanaan:** Fokus pada tugas utama pengguna (pengasuh, admin, orang tua).
- **Konsistensi:** Gunakan pola navigasi, warna, dan tipografi yang sama di seluruh aplikasi.
- **Keterbacaan:** Prioritaskan hierarki informasi yang jelas dan kontras tinggi.
- **Aksesibilitas:** Gunakan ukuran font minimal 14pt, kontras sesuai WCAG AA, dan hindari warna sebagai indikator tunggal.
- **Feedback Cepat:** Berikan respon visual saat interaksi, termasuk loading, sukses, dan error.

## Identitas Visual

- **Palette Utama:**
  - Primary: `#1F74D1`
  - Secondary: `#FFD166`
  - Accent: `#EF476F`
  - Neutral 1: `#F5F5F5`
  - Neutral 2: `#2B2D42`
- **Tipografi:**
  - Headline: Poppins / 600
  - Body: Inter / 400
  - Caption: Inter / 400 dengan ukuran lebih kecil
- **Ikonografi:** Gunakan paket ikon Flutter (Material Icons) atau set konsisten lainnya.

## Komponen Inti

- **App Bar:**
  - Mobile: tinggi 56 px, menampilkan judul halaman.
  - Desktop: 64 px, sertakan breadcrumb bila diperlukan.
- **Navigation:**
  - Mobile: Bottom navigation maksimum 5 tab.
  - Desktop: Sidebar dengan grouping fitur.
- **Form Input:**
  - Gunakan TextFormField dengan label mengambang.
  - Berikan pesan error di bawah input.
  - Sediakan helper text bila diperlukan.
- **Button:**
  - Primary Button: warna utama, radius 8 px.
  - Secondary Button: outline dengan warna utama.
  - Disabled state memiliki opacity 40%.
- **Cards:**
  - Gunakan untuk menampilkan ringkasan data anak atau kelas.
  - Ruang dalam minimal 16 px.

## Pola Interaksi

- **Dashboard Pengasuh:**
  - Ringkasan kelas hari ini.
  - Akses cepat ke pencatatan kehadiran.
- **Dashboard Orang Tua:**
  - Highlight perkembangan anak terbaru.
  - CTA ke laporan semester.
- **Manajemen Data:**
  - Gunakan tabel pada desktop, list pada mobile.
  - Sediakan filter dan pencarian.

## Best Practice Responsive

- Gunakan `LayoutBuilder` dan `MediaQuery` untuk adaptasi layout.
- Pecah layout menjadi komponen adaptif (mis. `AdaptiveScaffold`).
- Terapkan grid 12 kolom pada desktop dan 4 kolom pada mobile.
- Pastikan padding minimal 16 px pada mobile, 24 px pada desktop.

## Uji Kelayakan

- Lakukan usability review minimal internal.
- Gunakan checklist:
  - Navigasi mudah dipahami.
  - Konten penting terlihat tanpa scroll berlebihan.
  - Komponen interaktif dapat diakses keyboard (desktop).

## Dokumentasi Desain

- Simpan mockup di folder `assets/design/`.
- Tautkan referensi Figma atau gambar di dokumen ini bila tersedia.
- Setiap perubahan besar harus direview dan diperbarui di dokumen ini.

## Revisi & Persetujuan

- Status dokumen: Draft (perlu review tim desain dan produk).
- Ajukan perubahan melalui merge request dengan referensi issue terkait.

---

Dokumen ini akan diperbarui seiring validasi desain dengan pemangku kepentingan.