# PRODUCT REQUIREMENTS DOCUMENT (PRD)

**Document ID:** DOC-014  \
**Title:** Product Requirements  \
**Project:** e-Raport Sekolah Minggu (Genesis)  \
**Version:** 1.0.0  \
**Status:** Draft

---

## 1. Ringkasan Produk

e-Raport Sekolah Minggu adalah aplikasi untuk digitalisasi proses administrasi, pencatatan kehadiran, dan penyusunan rapor anak Sekolah Minggu dalam satu gereja.

## 2. Latar Belakang & Masalah

- Pencatatan manual menghambat konsistensi data.
- Orang tua kesulitan memantau perkembangan anak karena tidak ada akses digital.
- Admin dan pengasuh membutuhkan alat yang terintegrasi antara jadwal, kehadiran, dan nilai.

## 3. Tujuan Produk

1. Menyediakan rapor digital yang dapat diakses orang tua.
2. Mempermudah pengasuh mencatat kehadiran dan penilaian.
3. Membantu admin memonitor data kelas dan aktivitas.
4. Menyajikan laporan terstruktur untuk pengambilan keputusan gereja.

## 4. Persona & Kebutuhan

### Super Admin
- Mengelola setup awal, master data gereja, dan hak akses.
- Membutuhkan kontrol tinggi dan audit log.

### Admin
- Menjadwalkan kelas, mengelola data pengasuh, dan memonitor laporan.
- Membutuhkan dashboard ringkas, filter data, dan ekspor laporan.

### Pengasuh
- Mencatat kehadiran, kegiatan, dan penilaian anak.
- Membutuhkan antarmuka sederhana yang bisa diakses dari mobile.

### Orang Tua / Anak
- Mengakses rapor dan catatan perkembangan.
- Membutuhkan notifikasi dan tampilan yang mudah dipahami.

## 5. Ruang Lingkup Fitur

1. **Manajemen Pengguna & Akses**
   - CRUD Super Admin, Admin, Pengasuh, Orang Tua/Anak.
   - Assign kelas dan role.

2. **Manajemen Kelas & Jadwal**
   - Buat dan kelola kelas Sekolah Minggu.
   - Jadwal kegiatan mingguan.

3. **Kehadiran & Penilaian**
   - Form pencatatan kehadiran per sesi.
   - Input nilai sikap/spiritual/aktivitas.

4. **Rapor Digital**
   - Generate rapor per semester.
   - Tanda tangan digital admin/pengasuh.
   - Akses orang tua via aplikasi/web.

5. **Dashboard & Laporan**
   - Ringkasan kehadiran dan perkembangan.
   - Grafik performa kelas.

6. **Notifikasi**
   - Pemberitahuan ke orang tua saat rapor tersedia.
   - Pengingat ke pengasuh untuk input data yang belum lengkap.

## 6. Non-Fungsional Requirements

- **Responsif:** Berjalan baik pada Android dan Windows Desktop.
- **Keamanan:** Autentikasi Supabase, role-based access control.
- **Kinerja:** Waktu respon halaman utama < 2 detik pada koneksi stabil.
- **Reliabilitas:** Data tersimpan di PostgreSQL dengan backup rutin.
- **Skalabilitas:** Mendukung pertumbuhan hingga 10 kelas aktif.

## 7. Alur Pengguna (High Level)

1. Super Admin mendaftarkan gereja dan peran pengguna.
2. Admin membuat kelas, jadwal, dan menambahkan pengasuh.
3. Pengasuh mencatat kehadiran dan nilai setelah sesi.
4. Sistem menyusun rapor dan memberi notifikasi ke orang tua.
5. Orang tua login dan melihat perkembangan anak.

## 8. KPI & Metrik

- >80% pengasuh menginput data mingguan tepat waktu.
- 100% orang tua aktif dapat mengakses rapor digital.
- Penurunan waktu penyusunan rapor minimal 50% dibanding manual.

## 9. Risiko & Mitigasi

- **Keterbatasan Internet:** Sediakan mekanisme caching data sementara.
- **Adopsi Pengguna:** Lakukan pelatihan dan panduan onboarding.
- **Keamanan Data Anak:** Terapkan enkripsi dan pembatasan akses ketat.

## 10. Timeline (Estimasi)

| Sprint | Fokus | Hasil |
|--------|-------|-------|
| 1 | Foundation | Dokumentasi inti | 
| 2 | Engineering | Arsitektur & standar teknis |
| 3 | Business | Dokumentasi UI/UX & PRD |
| 4 | AI | Konteks dan prompt AI |
| 5 | GitHub | Template kolaborasi |

## 11. Dependensi

- Supabase untuk autentikasi dan database.
- Flutter (stable channel) untuk aplikasi lintas platform.
- Dokumentasi yang telah disetujui (Vision, Rules, Architecture).

## 12. Validasi & Review

- Status: Draft (perlu review dari stakeholder gereja dan tim inti).
- Rencana: Sesi walkthrough dokumen dan prototipe UI.

---

PRD akan diperbarui setelah mendapatkan masukan dari pengguna akhir dan stakeholder utama.