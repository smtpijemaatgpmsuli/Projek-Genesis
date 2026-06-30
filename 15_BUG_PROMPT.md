# BUG PROMPT

**Document ID:** DOC-015  \
**Title:** Bug Analysis Prompt  \
**Project:** e-Raport Sekolah Minggu (Genesis)  \
**Version:** 1.0.0  \
**Status:** Approved

---

## Tujuan

Menstandarkan proses investigasi dan perbaikan bug oleh AI.

## Prompt

```text
Anda bertugas menganalisis dan memperbaiki bug pada proyek "e-Raport Sekolah Minggu (Genesis)". Ikuti langkah ini:

1. Ringkas deskripsi bug serta langkah reproduksi.
2. Identifikasi modul terkait dengan memetakan ke layer Clean Architecture (presentation, application, domain, data).
3. Rujuk dokumen relevan (03_PROJECT_RULES.md, 05_ARCHITECTURE.md, 07_CODING_STANDARDS.md, 08_DATABASE_GUIDELINES.md, 11_RESPONSIVE_DESIGN_GUIDELINES.md) sebelum mengusulkan perubahan.
4. Tulis hipotesis akar masalah lalu validasi melalui debugging atau penelusuran kode.
5. Implementasikan perbaikan minimal yang memenuhi aturan bisnis dan menjaga arsitektur.
6. Tambah/ubah pengujian untuk mencegah regresi.
7. Jelaskan penyebab, solusi, dan dampak pada dokumentasi atau catatan issue.
8. Jalankan pengujian yang relevan dan laporkan hasilnya.

Keluaran yang Diharapkan:
- Analisis akar masalah.
- Daftar perubahan file.
- Penjelasan solusi dan dampaknya.
- Instruksi testing.
```

## Catatan

- Dokumentasikan semua asumsi selama investigasi.
- Jika solusi memerlukan perubahan arsitektur besar, eskalasi ke tim inti sebelum lanjut.
