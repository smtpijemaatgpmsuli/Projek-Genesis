# BUSINESS RULES

**Document ID:** DOC-011 **Title:** Business Rules **Project:** e-Raport
Sekolah Minggu (Genesis) **Version:** 1.0.0 **Status:** Approved

------------------------------------------------------------------------

# Tujuan

Dokumen ini mendefinisikan aturan bisnis yang menjadi dasar implementasi
seluruh fitur aplikasi.

# Ruang Lingkup

-   Aplikasi hanya digunakan oleh satu gereja.
-   Satu database melayani satu gereja.
-   Tidak mendukung multi-gereja.

# Tahun Ajaran

-   Tahun ajaran dibuat oleh Super Admin.
-   Hanya satu tahun ajaran aktif.
-   Semester mengikuti tahun ajaran aktif.

# Pengguna

-   Setiap pengguna memiliki satu role resmi.
-   Satu akun tidak boleh memiliki lebih dari satu role.

# Pengasuh

-   Pengasuh hanya dapat mengelola kelas yang ditugaskan.
-   Pengasuh tidak dapat mengubah data master.

# Data Anak

-   Setiap anak terdaftar pada satu kelas aktif.
-   Data anak wajib memiliki identitas dasar.

# Absensi

-   Absensi dicatat per pertemuan.
-   Tidak boleh ada absensi ganda untuk anak pada pertemuan yang sama.

# Penilaian

-   Nilai diinput oleh Pengasuh.
-   Format penilaian dapat disesuaikan sesuai kebutuhan gereja tanpa
    mengubah arsitektur dasar.

# Rapor

-   Rapor dibuat berdasarkan data yang telah disimpan.
-   Orang Tua hanya dapat melihat rapor anak yang terkait dengan
    akunnya.

# Keamanan

-   Semua akses mengikuti hak akses berdasarkan role.
-   Data hanya dapat diakses oleh pengguna yang berwenang.

# Audit

-   Perubahan penting harus dapat dilacak melalui metadata atau log
    sesuai kebutuhan proyek.
