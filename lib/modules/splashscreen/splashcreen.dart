import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../data/user_session.dart';
import '../../navigations/bottom_nav.dart';
import 'login_page.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..forward();

    _checkSession();
  }

  Future<void> _checkSession() async {
    // tunggu animasi biar kelihatan
    await Future.delayed(const Duration(seconds: 4));

    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;

    if (!mounted) return;

    if (user == null) {
      // ❌ belum login
      _goTo(const LoginPage());
    } else {
      // ✅ sudah login → ambil profile
      try {
        final profile = await supabase
            .from('profiles')
            .select()
            .eq('id', user.id)
            .single();

        UserSession.login(
          namaUser: profile['nama'] ?? 'User',
          emailUser: user.email ?? '-',
        );

        if (!mounted) return;
        _goTo(const BottomNavShell());
      } catch (e) {
        // kalau profile error → paksa login ulang
        _goTo(const LoginPage());
      }
    }
  }

  void _goTo(Widget page) {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 800),
        pageBuilder: (_, _, _) => page,
        transitionsBuilder: (_, animation, _, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0B3A30), Color(0xFF0E5F4C)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (_, _) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  /// ===============================
                  /// LOGO SUTURA
                  /// ===============================
                  SizedBox(
                    width: 300,
                    height: 100,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        /// SHADOW
                        Transform.translate(
                          offset: const Offset(0, 4),
                          child: Text(
                            "SUTURA",
                            style: TextStyle(
                              fontSize: 52,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 4,
                              color: Colors.black.withValues(alpha: 0.35),
                            ),
                          ),
                        ),

                        /// MAIN TEXT
                        Text(
                          "SUTURA",
                          style: TextStyle(
                            fontSize: 52,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 4,
                            foreground: Paint()
                              ..shader =
                                  const LinearGradient(
                                    colors: [
                                      Color(0xFF9FFFD9),
                                      Color(0xFF32D2A4),
                                    ],
                                  ).createShader(
                                    const Rect.fromLTWH(0, 0, 300, 100),
                                  ),
                            shadows: [
                              Shadow(
                                blurRadius: 30 * _controller.value,
                                color: const Color(0xFF7FFFD4),
                              ),
                            ],
                          ),
                        ),

                        /// STITCH ANIMATION
                        ShaderMask(
                          blendMode: BlendMode.dstIn,
                          shaderCallback: (rect) {
                            return const LinearGradient(
                              colors: [Colors.white, Colors.white],
                            ).createShader(rect);
                          },
                          child: CustomPaint(
                            size: const Size(300, 100),
                            painter: AnimatedStitchPainter(
                              progress: _controller.value,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 10),

                  const Text(
                    "Smart Tailoring Solution",
                    style: TextStyle(
                      fontSize: 14,
                      letterSpacing: 1.2,
                      color: Color(0xFFD9FFF3),
                    ),
                  ),

                  const SizedBox(height: 26),

                  /// LOADING BAR
                  SizedBox(
                    width: 140,
                    height: 6,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(3),
                      child: LinearProgressIndicator(
                        value: _controller.value,
                        color: Colors.white,
                        backgroundColor: Colors.white.withValues(alpha: 0.25),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

/// =======================================
/// STITCH PAINTER
/// =======================================
class AnimatedStitchPainter extends CustomPainter {
  final double progress;
  AnimatedStitchPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path();
    path.moveTo(10, size.height * 0.65);

    path.quadraticBezierTo(
      size.width * 0.5,
      size.height * 0.2,
      size.width - 10,
      size.height * 0.65,
    );

    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.8
      ..strokeCap = StrokeCap.round;

    final metric = path.computeMetrics().first;
    final length = metric.length * progress;

    const dash = 6.0;
    const gap = 5.0;

    double distance = 0;
    while (distance < length) {
      final extract = metric.extractPath(distance, distance + dash);
      canvas.drawPath(extract, paint);
      distance += dash + gap;
    }
  }

  @override
  bool shouldRepaint(covariant AnimatedStitchPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
