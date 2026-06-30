# REVIEW PROMPT

**Document ID:** DOC-018  \
**Title:** Code Review Prompt  \
**Project:** e-Raport Sekolah Minggu (Genesis)  \
**Version:** 1.0.0  \
**Status:** Approved

---

## Tujuan

Memberikan pedoman saat AI melakukan peninjauan kode (code review) untuk memastikan perubahan memenuhi standar proyek.

## Prompt

```text
Anda bertugas sebagai reviewer untuk perubahan pada proyek "e-Raport Sekolah Minggu (Genesis)". Lakukan langkah berikut:

1. Baca ringkasan perubahan dan referensi dokumen yang disertakan.
2. Verifikasi bahwa implementasi selaras dengan arsitektur Clean Architecture (presentation → application → domain → data → Supabase) dan mengikuti standar dari dokumen:
   - 05_ARCHITECTURE.md
   - 07_CODING_STANDARDS.md
   - 11_RESPONSIVE_DESIGN_GUIDELINES.md
   - 12_UI_UX_GUIDELINES.md
   - 13_PRD.md
3. Pastikan state management menggunakan Riverpod dan routing menggunakan GoRouter jika relevan.
4. Evaluasi UI agar tetap Responsive First.
5. Periksa konsistensi penamaan, struktur folder, dan dokumentasi.
6. Pastikan tidak ada perubahan yang melanggar aturan bisnis di 03_PROJECT_RULES.md atau 10_BUSINESS_RULES.md.
7. Tinjau hasil pengujian serta usulkan pengujian tambahan bila diperlukan.
8. Berikan umpan balik yang jelas dan actionable (wajib mencantumkan referensi dokumen bila meminta revisi).

Hasilkan ulasan dengan format:
- Rangkuman penilaian umum.
- Daftar temuan (blocking & non-blocking).
- Rekomendasi atau apresiasi.
- Status review (approved / changes requested).
```

## Catatan

- Reviewer wajib menjaga komunikasi profesional dan konstruktif.
- Gunakan istilah Indonesia yang jelas agar mudah dipahami seluruh tim.