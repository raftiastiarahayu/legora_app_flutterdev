import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../core/theme/sutura_colors.dart';
import '../modules/dashboard/dashboard_page.dart';
import '../modules/pelanggan/pelanggan_page.dart';
import '../modules/order/order_page.dart';
import '../modules/keuangan/keuangan_page.dart';
import '../modules/lainnya/lainnya_page.dart';

class BottomNavShell extends StatefulWidget {
  const BottomNavShell({super.key});

  @override
  State<BottomNavShell> createState() => _BottomNavShellState();
}

class _BottomNavShellState extends State<BottomNavShell> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    DashboardPage(),
    PelangganPage(),
    OrderPage(),
    KeuanganPage(),
    LainnyaPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: SuturaColors.primary,
        unselectedItemColor: SuturaColors.textSecondary,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(LucideIcons.home),
            label: "Dashboard",
          ),
          BottomNavigationBarItem(
            icon: Icon(LucideIcons.users),
            label: "Pelanggan",
          ),
          BottomNavigationBarItem(
            icon: Icon(LucideIcons.scissors),
            label: "Order",
          ),
          BottomNavigationBarItem(
            icon: Icon(LucideIcons.wallet),
            label: "Keuangan",
          ),
          BottomNavigationBarItem(
            icon: Icon(LucideIcons.menu),
            label: "Lainnya",
          ),
        ],
      ),
    );
  }
}
