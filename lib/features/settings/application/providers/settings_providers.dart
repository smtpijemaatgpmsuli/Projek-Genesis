import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider untuk informasi versi aplikasi.
final appVersionProvider = Provider<String>((ref) => '1.0.0+1');

/// Provider untuk nama aplikasi.
final appNameProvider = Provider<String>((ref) => 'e-Raport Sekolah Minggu');
