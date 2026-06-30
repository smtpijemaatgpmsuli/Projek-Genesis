# CODING STANDARDS

**Document ID:** DOC-008\
**Title:** Coding Standards\
**Version:** 1.0.0

------------------------------------------------------------------------

# Tujuan

Menjaga konsistensi kualitas kode di seluruh proyek.

# Prinsip

-   Clean Code
-   SOLID (sesuai kebutuhan)
-   DRY
-   KISS
-   Documentation First
-   Responsive First

# Penamaan

## File

snake_case.dart

## Class

PascalCase

## Variable & Function

camelCase

## Constant

camelCase atau lowerCamelCase dengan prefix yang jelas.

# Struktur Widget

-   Widget kecil dan reusable.
-   Hindari widget dengan tanggung jawab terlalu banyak.
-   Pisahkan UI dan business logic.

# Responsive

-   Hindari ukuran hardcoded.
-   Gunakan LayoutBuilder, MediaQuery, Expanded, Flexible bila
    diperlukan.
-   Uji tampilan Mobile dan Desktop.

# State Management

Gunakan Riverpod sesuai standar proyek.

# Error Handling

-   Tangani exception.
-   Tampilkan pesan yang ramah pengguna.
-   Log error untuk debugging.

# Dokumentasi

-   Tambahkan komentar hanya bila diperlukan.
-   Perubahan besar harus diperbarui di dokumentasi proyek.

# Code Review Checklist

-   Tidak ada warning penting.
-   Build berhasil.
-   UI responsif.
-   Naming konsisten.
-   Tidak ada kode duplikat.
