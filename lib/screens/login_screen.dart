import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _usernameCtrl = TextEditingController(); // Added for Sign Up

  bool _isLogin = true; // Toggle between Login and Sign Up
  bool _isLoading = false;

  void _submit() async {
    final auth = context.read<AuthService>();
    final email = _emailCtrl.text.trim();
    final pass = _passCtrl.text.trim();
    final username = _usernameCtrl.text.trim();

    if (email.isEmpty || pass.isEmpty) return;
    if (!_isLogin && username.isEmpty) return; // Username required for signup

    setState(() => _isLoading = true);

    String? error;
    if (_isLogin) {
      error = await auth.signIn(email, pass);
    } else {
      error = await auth.signUp(email, pass, username);
    }

    if (mounted) {
      setState(() => _isLoading = false);
      if (error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error, style: const TextStyle(color: Colors.white)),
            backgroundColor: FireflyTheme.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. App Title
              Text(
                "Firefly",
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              const SizedBox(height: 10),

              // 2. Friendly Subtitle (Fixed Bug 5)
              Text(
                _isLogin ? "Welcome Back" : "Create Account",
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: FireflyTheme.red,
                  letterSpacing: 1.2,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 40),

              // 3. Username Field (Only show if Signing Up)
              if (!_isLogin) ...[
                TextField(
                  controller: _usernameCtrl,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: "Username",
                    prefixIcon: Icon(Icons.person_outline, color: Colors.grey),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // 4. Email Field
              TextField(
                controller: _emailCtrl,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: "Email",
                  prefixIcon: Icon(Icons.email_outlined, color: Colors.grey),
                ),
              ),
              const SizedBox(height: 16),

              // 5. Password Field
              TextField(
                controller: _passCtrl,
                obscureText: true,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: "Password",
                  prefixIcon: Icon(Icons.lock_outline, color: Colors.grey),
                ),
              ),
              const SizedBox(height: 32),

              // 6. Action Button
              _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(color: FireflyTheme.red),
                    )
                  : ElevatedButton(
                      onPressed: _submit,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: FireflyTheme.red,
                      ),
                      child: Text(
                        _isLogin ? "Sign In" : "Sign Up",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),

              const SizedBox(height: 16),

              // 7. Toggle Button (Switch between Login/Signup)
              TextButton(
                onPressed: () => setState(() => _isLogin = !_isLogin),
                child: Text(
                  _isLogin
                      ? "Create a new account"
                      : "I already have an account",
                  style: const TextStyle(color: Colors.grey),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
