# Panduan Kontribusi

Terima kasih ingin berkontribusi pada **e-Raport Sekolah Minggu (Genesis)**. Ikuti panduan berikut agar kolaborasi berjalan lancar.

## Alur Kerja

1. **Diskusi Awal**  
   Buka issue menggunakan template yang sesuai di folder `.github/ISSUE_TEMPLATE`. Sertakan referensi dari dokumentasi proyek.

2. **Perencanaan**  
   Validasi solusi terhadap dokumen: arsitektur, standar kode, dan aturan bisnis. Dokumentasikan keputusan sebelum implementasi.

3. **Pengembangan**  
   - Buat branch dari `develop` dengan pola `feature/<deskripsi>`, `fix/<deskripsi>`, atau `docs/<deskripsi>`.
   - Ikuti Clean Architecture dan struktur folder feature-first.
   - Gunakan Riverpod untuk state management dan GoRouter untuk routing.
   - Pastikan UI responsive (mobile & desktop).

4. **Pengujian**  
   Jalankan pengujian unit/widget/integrasi sesuai perubahan. Lampirkan hasilnya di merge request.

5. **Pengiriman**  
   - Tulis commit message mengikuti konvensi (`feat:`, `fix:`, dsb.).
   - Buka merge request ke `develop` dan isi template PR.
   - Cantumkan referensi issue menggunakan kata kunci penutup bila relevan (mis. `Closes #13`).

6. **Review**  
   Tanggapi feedback reviewer dan lakukan revisi hingga disetujui.

## Standar Kode

- Ikuti [07_CODING_STANDARDS.md](./07_CODING_STANDARDS.md).
- Hindari duplikasi dan pastikan penamaan konsisten.
- Gunakan linter dan formatter (`dart format`).

## Dokumentasi

- Perubahan besar harus memperbarui atau menambahkan dokumentasi baru.
- Rujuk daftar dokumen di README.

## Perilaku

- Komunikasi profesional dan terbuka.
- Hormati keputusan arsitektur yang sudah disetujui.

Dengan mengikuti panduan ini kita dapat menjaga kualitas dan konsistensi proyek bersama. Selamat berkontribusi!
