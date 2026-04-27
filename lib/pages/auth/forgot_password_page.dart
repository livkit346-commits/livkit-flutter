import 'package:flutter/material.dart';
import '../../services/auth_service.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({super.key});

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  final TextEditingController _emailController = TextEditingController();
  bool _isLoading = false;
  bool _sent = false;
  final _auth = AuthService();

  Future<void> _handleReset() async {
    if (_emailController.text.isEmpty) return;
    setState(() => _isLoading = true);
    try {
      await _auth.forgotPassword(_emailController.text.trim());
      setState(() => _sent = true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(leading: const BackButton(color: Colors.white)),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Reset Password",
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              _sent 
                ? "If that email is in our system, we've sent a recovery link."
                : "Enter your email and we'll send you a link to get back into your account.",
              style: const TextStyle(color: Colors.white60, fontSize: 16),
            ),
            const SizedBox(height: 48),
            
            if (!_sent) ...[
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(hintText: "Email Address"),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _isLoading ? null : _handleReset,
                child: _isLoading 
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Text("SEND RESET LINK"),
              ),
            ] else 
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("BACK TO LOGIN"),
              ),
          ],
        ),
      ),
    );
  }
}
