# DATABASE GUIDELINES

**Document ID:** DOC-009\
**Title:** Database Guidelines\
**Project:** e-Raport Sekolah Minggu (Genesis)\
**Version:** 1.0.0\
**Status:** Approved

------------------------------------------------------------------------

# Tujuan

Dokumen ini menjadi pedoman resmi dalam perancangan, perubahan, dan
pemeliharaan database proyek.

# Database

-   Database: PostgreSQL
-   Platform: Supabase

# Prinsip

-   Gunakan UUID sebagai Primary Key.
-   Semua perubahan schema menggunakan migration.
-   Tidak mengubah schema production secara langsung.
-   Hindari penghapusan data permanen jika soft delete memungkinkan.

# Standar Tabel

Setiap tabel minimal memiliki:

-   id (UUID)
-   created_at
-   updated_at
-   created_by (opsional)
-   updated_by (opsional)

# Relasi

-   Gunakan Foreign Key.
-   Hindari data duplikat.
-   Terapkan normalisasi sesuai kebutuhan.

# Penamaan

-   Nama tabel: snake_case
-   Nama kolom: snake_case

# Keamanan

-   Gunakan Row Level Security (RLS).
-   Terapkan policy berdasarkan role pengguna.
-   Jangan menyimpan password di tabel aplikasi.

# Backup

-   Backup database dilakukan secara berkala.
-   Migration harus disimpan dalam repository.

# Perubahan Database

Setiap perubahan wajib:

1.  Memperbarui dokumentasi.
2.  Membuat migration.
3.  Direview sebelum diterapkan.

# Penutup

Dokumen ini menjadi acuan seluruh perubahan database pada proyek
e-Raport Sekolah Minggu.
