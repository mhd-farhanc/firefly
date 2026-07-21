import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
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
  final _usernameCtrl = TextEditingController();

  bool _isLogin = true;
  bool _isLoading = false;

  void _submit() async {
    final auth = context.read<AuthService>();
    final email = _emailCtrl.text.trim();
    final pass = _passCtrl.text.trim();
    final username = _usernameCtrl.text.trim();

    if (email.isEmpty || pass.isEmpty) return;
    if (!_isLogin && username.isEmpty) return;

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
            content: Text(
              error,
              style: GoogleFonts.shareTechMono(color: FireflyTheme.textOnDark),
            ),
            backgroundColor: FireflyTheme.darkBlock,
            elevation: 0,
            behavior: SnackBarBehavior.fixed,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.zero,
            ),
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
              Text(
                "FIREFLY",
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              const SizedBox(height: 10),
              Text(
                _isLogin ? "WELCOME BACK" : "CREATE ACCOUNT",
                textAlign: TextAlign.center,
                style: GoogleFonts.anton(
                  color: FireflyTheme.textOnDark,
                  fontSize: 18,
                  letterSpacing: 3,
                ),
              ),
              const SizedBox(height: 40),
              if (!_isLogin) ...[
                TextField(
                  controller: _usernameCtrl,
                  style: GoogleFonts.shareTechMono(
                    color: FireflyTheme.textOnDark,
                    fontSize: 16,
                  ),
                  decoration: const InputDecoration(
                    hintText: "USERNAME",
                  ),
                ),
                const SizedBox(height: 16),
              ],
              TextField(
                controller: _emailCtrl,
                style: GoogleFonts.shareTechMono(
                  color: FireflyTheme.textOnDark,
                  fontSize: 16,
                ),
                decoration: const InputDecoration(
                  hintText: "EMAIL",
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passCtrl,
                obscureText: true,
                style: GoogleFonts.shareTechMono(
                  color: FireflyTheme.textOnDark,
                  fontSize: 16,
                ),
                decoration: const InputDecoration(
                  hintText: "PASSWORD",
                ),
              ),
              const SizedBox(height: 32),
              _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: FireflyTheme.textOnDark,
                      ),
                    )
                  : ElevatedButton(
                      onPressed: _submit,
                      child: Text(
                        _isLogin ? "SIGN IN" : "SIGN UP",
                      ),
                    ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => setState(() => _isLogin = !_isLogin),
                child: Text(
                  _isLogin ? "CREATE A NEW ACCOUNT" : "I ALREADY HAVE AN ACCOUNT",
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
