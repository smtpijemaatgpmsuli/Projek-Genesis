# FOLDER STRUCTURE

**Document ID:** DOC-007\
**Title:** Folder Structure\
**Version:** 1.0.0

------------------------------------------------------------------------

# Root

``` text
e-raport-sekolah-minggu/
│
├── .github/
├── assets/
├── docs/
├── decisions/
├── knowledge/
├── prompts/
├── lib/
├── supabase/
├── test/
├── web/
├── windows/
├── android/
├── README.md
├── LICENSE
└── CHANGELOG.md
```

# Folder lib

``` text
lib/
│
├── core/
├── shared/
├── features/
│    ├── authentication/
│    ├── dashboard/
│    ├── student/
│    ├── attendance/
│    ├── assessment/
│    ├── report/
│    ├── class/
│    ├── parent/
│    └── settings/
└── main.dart
```

# Struktur Feature

Setiap feature memiliki:

-   presentation
-   application
-   domain
-   data

# Aturan

-   Tidak membuat folder di luar standar tanpa persetujuan.
-   Semua feature baru mengikuti struktur yang sama.
