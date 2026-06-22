import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/date_symbol_data_local.dart'; // tambah
import 'core/theme/app_theme.dart';
import 'pages/splash_page.dart';
import 'core/config/supabase_config.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initializeDateFormatting('id_ID', null); // tambah

  await Supabase.initialize(
    url: SupabaseConfig.url,
    anonKey: SupabaseConfig.anonKey,
  );

  runApp(const LunarFlowApp());
}

class LunarFlowApp extends StatelessWidget {
  const LunarFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LunarFlow',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      home: const SplashPage(),
    );
  }
}