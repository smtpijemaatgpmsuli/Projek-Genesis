import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'bootstrap.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await bootstrap();
  runApp(const ProviderScope(child: GenesisApp()));
}

class GenesisApp extends ConsumerWidget {
  const GenesisApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'e-Raport Sekolah Minggu',
      theme: ref.watch(appThemeProvider),
      routerConfig: router,
    );
  }
}
