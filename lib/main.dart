import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'theme/app_theme.dart';
import 'navigation/auth_gate.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const LivkitApp());
}

class LivkitApp extends StatelessWidget {
  const LivkitApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LivKit',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const AuthGate(),
    );
  }
}
