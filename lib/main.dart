import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/supabase_config.dart';
import 'core/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SupabaseConfig.initialize();

  runApp(const ProviderScope(child: MedicsApp()));
}

class MedicsApp extends ConsumerWidget {
  const MedicsApp({super.key}); // ← add this

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'Medics',
      theme: ThemeData(primarySwatch: Colors.blue, fontFamily: 'Roboto'),
      routerConfig: router,
    );
  }
}
