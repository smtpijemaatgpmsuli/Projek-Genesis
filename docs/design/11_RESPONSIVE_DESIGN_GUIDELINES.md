# RESPONSIVE DESIGN GUIDELINES

**Document ID:** DOC-012 **Title:** Responsive Design Guidelines
**Project:** e-Raport Sekolah Minggu (Genesis) **Version:** 1.0.0
**Status:** Approved

------------------------------------------------------------------------

# Tujuan

Dokumen ini menjadi pedoman resmi agar seluruh antarmuka aplikasi
bekerja dengan baik pada perangkat mobile dan desktop.

# Prinsip

-   Responsive First.
-   Satu codebase untuk semua platform.
-   Hindari membuat halaman terpisah untuk mobile dan desktop kecuali
    benar-benar diperlukan.

# Target Perangkat

## Mobile

-   Android
-   Pengasuh
-   Orang Tua / Anak

## Desktop

-   Windows
-   Admin
-   Super Admin

# Layout

## Mobile

-   Navigasi sederhana.
-   Bottom Navigation bila diperlukan.
-   Form mudah digunakan dengan satu tangan.

## Desktop

-   Sidebar Navigation.
-   Area konten lebih luas.
-   Tabel dan dashboard dioptimalkan.

# Komponen

-   Gunakan LayoutBuilder dan MediaQuery bila diperlukan.
-   Hindari ukuran hardcoded.
-   Gunakan Expanded/Flexible untuk distribusi ruang.

# Breakpoint (Rekomendasi)

-   Mobile: \< 600 px
-   Tablet: 600--1023 px
-   Desktop: \>= 1024 px

# Pengujian

Setiap fitur wajib diuji pada: - Android - Windows Desktop

Task belum selesai apabila salah satu platform belum diverifikasi.

# Penutup

Responsive merupakan persyaratan wajib pada seluruh fitur proyek
Genesis.
