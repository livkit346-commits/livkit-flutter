import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/auth_service.dart';
import '../pages/auth/login_page.dart';
import '../navigation/main_navigation.dart';
import 'package:jwt_decode/jwt_decode.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  bool _initialized = false;
  String _status = "Checking system...";

  @override
  void initState() {
    super.initState();
    _initApp();
  }

  Future<void> _initApp() async {
    // 1. Initialize Supabase if not done
    try {
      if (!Supabase.instance.client.hashCode.isNegative) { // Check if already init
        // already init
      }
    } catch (_) {
      try {
        await Supabase.initialize(
          url: 'https://zyvwjttwpeahzsokrjsx.supabase.co',
          anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inp5dndqdHR3cGVhaHpzb2tyanN4Iiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc3NTE1NzgzNywiZXhwIjoyMDkwNzMzODM3fQ.n0TgnDzBtV7vluN0Pj-xIWFS3GguXzPJZUM4D_SyYec',
        );
      } catch (e) {
        setState(() => _status = "Connection Error: $e");
        return;
      }
    }

    // 2. Check Session
    final auth = AuthService();
    try {
      final token = await auth.getAccessToken();
      if (token == null || Jwt.isExpired(token)) {
        _goTo(const AnimatedLoginPage());
      } else {
        _goTo(const MainNavigation());
      }
    } catch (e) {
      _goTo(const AnimatedLoginPage());
    }
  }

  void _goTo(Widget page) {
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => page),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(color: Colors.red),
            const SizedBox(height: 24),
            Text(_status, style: const TextStyle(color: Colors.white70)),
          ],
        ),
      ),
    );
  }
}
