import 'dart:convert';
import 'dart:io';

class AppEnv {
  AppEnv({required this.supabaseUrl, required this.supabaseAnonKey});

  final String supabaseUrl;
  final String supabaseAnonKey;

  static Future<AppEnv> load() async {
    final file = File('.env');
    if (!await file.exists()) {
      throw Exception('Missing .env file with Supabase configuration');
    }

    final json = jsonDecode(await file.readAsString()) as Map<String, dynamic>;

    return AppEnv(
      supabaseUrl: json['SUPABASE_URL'] as String,
      supabaseAnonKey: json['SUPABASE_ANON_KEY'] as String,
    );
  }
}
