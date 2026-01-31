import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/theme/sutura_text.dart';
import '../../core/widgets/sutura_card.dart';
import '../../data/master_data_repository.dart';
import '../../data/keuangan_repository.dart';
import '../../data/pesanan_repository.dart';
import '../../data/user_session.dart';

import '../splashscreen/login_page.dart';
import 'profil_page.dart';
import 'masterdata_page.dart';
import 'about_page.dart';
import 'laporan_keuangan_page.dart';

class LainnyaPage extends StatefulWidget {
  const LainnyaPage({super.key});

  @override
  State<LainnyaPage> createState() => _LainnyaPageState();
}

class _LainnyaPageState extends State<LainnyaPage> {
  bool get _isLoggedIn => UserSession.isLoggedIn;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Pengaturan", style: SuturaText.title),
            const SizedBox(height: 16),

            /// ================= AKUN =================
            _sectionTitle("Akun"),
            SuturaCard(
              child: Column(
                children: [
                  _menuItem(
                    context,
                    icon: Icons.person,
                    title: "Profil",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ProfilPage()),
                      );
                    },
                  ),
                  _divider(),
                  if (_isLoggedIn)
                    _menuItem(
                      context,
                      icon: Icons.logout,
                      title: "Logout",
                      onTap: _showLogoutDialog,
                    ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            /// ================= DATA =================
            _sectionTitle("Data"),
            SuturaCard(
              child: Column(
                children: [
                  _menuItem(
                    context,
                    icon: Icons.storage,
                    title: "Master Data",
                    onTap: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const MasterDataPage(),
                        ),
                      );
                      if (result != null) {
                        setState(() {
                          MasterDataRepository.jenisJasaList
                            ..clear()
                            ..addAll(result);
                        });
                      }
                    },
                  ),
                  _divider(),
                  _menuItem(
                    context,
                    icon: Icons.bar_chart,
                    title: "Laporan Keuangan",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const LaporanKeuanganPage(),
                        ),
                      );
                    },
                  ),
                  _divider(),
                  _menuItem(
                    context,
                    icon: Icons.restart_alt,
                    title: "Reset Data",
                    iconColor: Colors.red,
                    onTap: _showResetDialog,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            /// ================= ABOUT =================
            _sectionTitle("Tentang"),
            SuturaCard(
              child: _menuItem(
                context,
                icon: Icons.info_outline,
                title: "About Aplikasi",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AboutPage()),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================= UI HELPERS =================

  Widget _sectionTitle(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(text, style: SuturaText.subtitle),
  );

  Widget _menuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    Color? iconColor,
    required VoidCallback onTap,
  }) => ListTile(
    leading: Icon(icon, color: iconColor ?? Colors.black),
    title: Text(title, style: SuturaText.body),
    trailing: const Icon(Icons.chevron_right),
    onTap: onTap,
  );

  Widget _divider() => const Divider(height: 1);

  // ================= LOGOUT =================

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Logout"),
        content: const Text("Yakin ingin keluar dari akun?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal"),
          ),
          ElevatedButton(onPressed: _logout, child: const Text("Logout")),
        ],
      ),
    );
  }

  Future<void> _logout() async {
    Navigator.pop(context); // tutup dialog

    try {
      /// 🔥 LOGOUT SUPABASE
      await Supabase.instance.client.auth.signOut();

      /// 🔥 CLEAR SESSION LOKAL
      UserSession.logout();

      if (!mounted) return;

      /// 🔥 BALIK KE LOGIN
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
        (_) => false,
      );

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Logout berhasil")));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Gagal logout: $e")));
    }
  }

  // ================= RESET DATA =================

  void _showResetDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Reset Data"),
        content: const Text(
          "Semua data pesanan, keuangan, dan master data akan dihapus. "
          "Tindakan ini tidak bisa dibatalkan.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              MasterDataRepository.clear();
              PesananRepository.clear();
              KeuanganRepository.clear();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Data berhasil di-reset")),
              );
            },
            child: const Text("Reset"),
          ),
        ],
      ),
    );
  }
}
