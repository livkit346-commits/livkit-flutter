import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../theme/app_colors.dart';
import 'login_page.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _username = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _isLoading = false;

  Future<void> _handleSignup() async {
    if (_email.text.isEmpty || _password.text.isEmpty) return;
    setState(() => _isLoading = true);
    final auth = AuthService();
    try {
      await auth.signUp(_email.text.trim(), _password.text, _username.text.trim());
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Account created! Please check your email."), backgroundColor: AppColors.success));
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: AppColors.error));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: AppColors.bgGradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Create Account", style: TextStyle(fontSize: 34, fontWeight: FontWeight.bold, color: Colors.white)),
                  const Text("Join our community today", style: TextStyle(color: Colors.white70, fontSize: 16)),
                  const SizedBox(height: 48),
                  
                  TextField(controller: _username, decoration: const InputDecoration(hintText: "Username")),
                  const SizedBox(height: 20),
                  TextField(controller: _email, decoration: const InputDecoration(hintText: "Email")),
                  const SizedBox(height: 20),
                  TextField(controller: _password, obscureText: true, decoration: const InputDecoration(hintText: "Password")),
                  
                  const SizedBox(height: 40),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _handleSignup,
                    child: _isLoading 
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Text("SIGN UP"),
                  ),
                  
                  const SizedBox(height: 24),
                  Center(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Already have an account? Login", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
