import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/config/app_env.dart';

Future<void> bootstrap() async {
  final env = await AppEnv.load();
  await Supabase.initialize(
    url: env.supabaseUrl,
    anonKey: env.supabaseAnonKey,
  );
}
