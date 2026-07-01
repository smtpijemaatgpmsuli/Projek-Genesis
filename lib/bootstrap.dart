import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/config/app_env.dart';

Future<void> bootstrap() async {
  await dotenv.load(fileName: '.env');
  final env = AppEnv.load();
  await Supabase.initialize(
    url: env.supabaseUrl,
    publishableKey: env.supabaseAnonKey,
  );
}
