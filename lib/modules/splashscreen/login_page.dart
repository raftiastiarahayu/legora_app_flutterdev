import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/theme/sutura_text.dart';
import '../../core/widgets/sutura_button.dart';
import '../../core/widgets/sutura_card.dart';
import '../../data/user_session.dart';
import '../../navigations/bottom_nav.dart';
import 'register_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _loading = false;

  Future<void> _login() async {
    try {
      setState(() => _loading = true);

      final supabase = Supabase.instance.client;

      /// 1️⃣ AUTH LOGIN
      final res = await supabase.auth.signInWithPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      final user = res.user;
      if (user == null) throw "Login gagal";

      /// 2️⃣ AMBIL DATA PROFILE
      final profile = await supabase
          .from('profiles')
          .select()
          .eq('id', user.id)
          .single();

      /// 3️⃣ SIMPAN SESSION
      UserSession.login(
        namaUser: profile['nama_lengkap'],
        emailUser: profile['email'],
      );

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const BottomNavShell()),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Login gagal: $e")));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Text("Selamat Datang", style: SuturaText.title),
                const SizedBox(height: 8),
                Text(
                  "Login ke akun SUTURA",
                  style: SuturaText.subtitle,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                SuturaCard(
                  child: Column(
                    children: [
                      TextField(
                        controller: _emailController,
                        decoration: const InputDecoration(labelText: "Email"),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: "Password",
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                SuturaButton(
                  text: "Login",
                  loading: _loading,
                  onPressed: _login,
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Belum punya akun? ", style: SuturaText.caption),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const RegisterPage(),
                          ),
                        );
                      },
                      child: Text(
                        "Register",
                        style: SuturaText.caption.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
