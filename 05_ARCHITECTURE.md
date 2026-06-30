# ARCHITECTURE

**Document ID:** DOC-006\
**Title:** Architecture\
**Project:** e-Raport Sekolah Minggu (Genesis)\
**Version:** 1.0.0\
**Status:** Approved

------------------------------------------------------------------------

# Tujuan

Dokumen ini mendefinisikan arsitektur resmi aplikasi agar pengembangan
tetap konsisten meskipun dikerjakan oleh AI atau developer yang berbeda.

# Prinsip Arsitektur

-   Clean Architecture
-   Feature First
-   Modular
-   Responsive First
-   Documentation First

# Arsitektur Umum

    Presentation
        ↓
    Application
        ↓
    Domain
        ↓
    Data
        ↓
    Supabase

# Layer

## Presentation

-   Pages
-   Widgets
-   Layout Responsive
-   Routing

## Application

-   Use Cases
-   Services
-   Validation
-   State Management

## Domain

-   Entities
-   Repository Interface
-   Business Rules

## Data

-   Repository Implementation
-   Remote Data Source
-   Model
-   Mapper

## Infrastructure

-   Supabase Auth
-   PostgreSQL
-   Storage
-   Environment Configuration

# Struktur Feature

Setiap fitur memiliki: - presentation/ - application/ - domain/ - data/

# Responsive

Semua halaman wajib mendukung: - Android - Windows Desktop

Tidak diperbolehkan membuat halaman khusus mobile atau desktop tanpa
alasan yang terdokumentasi.

# State Management

Menggunakan Riverpod sebagai standar proyek.

# Routing

Menggunakan GoRouter.

# Dependency Rule

Layer tidak boleh bergantung ke layer yang lebih tinggi.

# Penutup

Dokumen ini menjadi acuan resmi seluruh implementasi arsitektur
aplikasi.
