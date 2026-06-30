# PROJECT RULES

**Document ID:** DOC-004\
**Title:** Project Rules\
**Project:** e-Raport Sekolah Minggu (Genesis)\
**Version:** 1.0.0\
**Status:** Approved\
**Owner:** Jondry Suitela

------------------------------------------------------------------------

# 1. Tujuan

Dokumen ini menetapkan aturan wajib yang harus dipatuhi oleh seluruh
developer dan AI selama pengembangan proyek.

# 2. Aturan Umum

-   Dokumentasi adalah sumber kebenaran utama.
-   Seluruh perubahan harus mengikuti dokumen resmi.
-   Setiap keputusan besar harus diperbarui pada dokumentasi.

# 3. Branding

Tidak boleh mengubah nama aplikasi, logo, maupun splash screen tanpa
persetujuan Project Owner.

# 4. Scope

Aplikasi hanya untuk satu gereja dan tidak terintegrasi dengan aplikasi
keuangan maupun warta jemaat.

# 5. Responsive First

Semua fitur wajib mendukung Mobile dan Desktop.

# 6. User Role

-   Super Admin
-   Admin
-   Pengasuh
-   Orang Tua / Anak

# 7. Database

-   Gunakan migration.
-   Gunakan UUID.
-   Dokumentasikan setiap perubahan schema.

# 8. Coding

-   Feature First.
-   Responsive.
-   Hindari hardcoded size.
-   Mudah dipelihara.

# 9. AI Rules

AI tidak boleh mengubah arsitektur, database, branding, atau menghapus
file tanpa persetujuan.

# 10. Git

Gunakan branch: - main - develop - feature/* - bugfix/* - hotfix/\*

Conventional Commit: feat, fix, docs, refactor, chore, style, test.

# 11. Quality Gate

Task selesai jika: - Dokumentasi diperbarui. - Build berhasil. - Mobile
dan Desktop telah diverifikasi.

# 12. Penutup

Dokumen ini menjadi aturan resmi pengembangan proyek.
