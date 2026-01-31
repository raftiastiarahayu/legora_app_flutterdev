import 'package:flutter/material.dart';

import '../../core/theme/sutura_text.dart';
import '../../core/widgets/sutura_card.dart';

import '../../data/pesanan_repository.dart';
import '../../data/models/pesanan_model.dart';
import '../../data/keuangan_repository.dart';

// ⬇️ PAKAI DIALOG DETAIL YANG SUDAH ADA
import '../order/detail_pesanan_dialog.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  @override
  void initState() {
    super.initState();

    PesananRepository.fetchPesanan();
    KeuanganRepository.fetch();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: PesananRepository.notifier,
      builder: (context, value, child) {
        return ValueListenableBuilder(
          valueListenable: KeuanganRepository.notifier,
          builder: (context, keuValue, child) {
            return SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Dashboard", style: SuturaText.title),
                    const SizedBox(height: 16),

                    Row(
                      children: [
                        Expanded(child: _pesananBulanIniCard()),
                        const SizedBox(width: 12),
                        Expanded(child: _pesananSelesaiCard()),
                        const SizedBox(width: 12),
                        Expanded(child: _pesananProsesCard()),
                      ],
                    ),

                    const SizedBox(height: 12),

                    Row(
                      children: [
                        Expanded(
                          child: _infoCard(
                            "Uang Masuk",
                            "Rp ${_formatRupiah(KeuanganRepository.totalMasukBulanIni())}",
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _infoCard(
                            "Uang Keluar",
                            "Rp ${_formatRupiah(KeuanganRepository.totalKeluarBulanIni())}",
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),
                    Text("Pesanan Deadline Terdekat", style: SuturaText.title),
                    const SizedBox(height: 12),
                    _deadlineTable(context),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ================= CARD =================

  Widget _infoCard(String title, String value) {
    return SuturaCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: SuturaText.subtitle),
          const SizedBox(height: 8),
          Text(value, style: SuturaText.body),
        ],
      ),
    );
  }

  // ================= PESANAN =================

  Widget _pesananBulanIniCard() {
    final now = DateTime.now();

    final jahit = PesananRepository.jahit
        .where(
          (p) => p.deadline.month == now.month && p.deadline.year == now.year,
        )
        .length;

    final permak = PesananRepository.permak
        .where(
          (p) => p.deadline.month == now.month && p.deadline.year == now.year,
        )
        .length;

    return _infoCard("Pesanan Bulan Ini", "Jahit: $jahit\nPermak: $permak");
  }

  Widget _pesananSelesaiCard() {
    final jahit = PesananRepository.jahit
        .where((p) => p.status == StatusPesanan.selesai)
        .length;

    final permak = PesananRepository.permak
        .where((p) => p.status == StatusPesanan.selesai)
        .length;

    return _infoCard("Pesanan Selesai", "Jahit: $jahit\nPermak: $permak");
  }

  Widget _pesananProsesCard() {
    final jahit = PesananRepository.jahit
        .where((p) => p.status == StatusPesanan.proses)
        .length;

    final permak = PesananRepository.permak
        .where((p) => p.status == StatusPesanan.proses)
        .length;

    return _infoCard("Sedang Diproses", "Jahit: $jahit\nPermak: $permak");
  }

  // ================= KEUANGAN BULAN INI =================
  final totalMasuk = KeuanganRepository.bulanIni().fold(
    0,
    (s, k) => s + k.masuk,
  );

  // ================= DEADLINE =================

  Widget _deadlineTable(BuildContext context) {
    final now = DateTime.now();

    final list =
        PesananRepository.jahit
            .where(
              (p) =>
                  p.status != StatusPesanan.selesai &&
                  p.deadline.difference(now).inDays <= 15,
            )
            .toList()
          ..sort((a, b) => a.deadline.compareTo(b.deadline));

    if (list.isEmpty) {
      return const SuturaCard(
        child: Text("Tidak ada deadline jahit ≤ 15 hari"),
      );
    }

    return Column(
      children: list.take(5).map((p) {
        final sisaHari = p.deadline.difference(now).inDays;

        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: DeadlineCard(
            pesanan: p,
            sisaHari: sisaHari,
            onTap: () {
              showDetailPesanan(context, p);
            },
          ),
        );
      }).toList(),
    );
  }
}

/// ================= DEADLINE CARD =================
class DeadlineCard extends StatefulWidget {
  final Pesanan pesanan;
  final int sisaHari;
  final VoidCallback onTap;

  const DeadlineCard({
    super.key,
    required this.pesanan,
    required this.sisaHari,
    required this.onTap,
  });

  @override
  State<DeadlineCard> createState() => _DeadlineCardState();
}

class _DeadlineCardState extends State<DeadlineCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _animation = Tween<double>(begin: 1, end: 0.4).animate(_controller);

    if (widget.sisaHari <= 1) {
      _controller.repeat(reverse: true); // 🔥 BLINK H-1
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: FadeTransition(
        opacity: widget.sisaHari <= 1
            ? _animation
            : const AlwaysStoppedAnimation(1),
        child: SuturaCard(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.pesanan.nama, style: SuturaText.body),
                  Text(
                    "Deadline: ${_formatTanggal(widget.pesanan.deadline)}",
                    style: SuturaText.subtitle,
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: widget.sisaHari <= 1
                      ? Color.fromARGB(51, 255, 0, 0) // kira-kira 0.2 opacity
                      : Color.fromARGB(38, 255, 165, 0), // orange 0.15
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  widget.sisaHari <= 0 ? "Hari ini" : "H-${widget.sisaHari}",
                  style: SuturaText.subtitle,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ================= FORMAT =================
String _formatTanggal(DateTime date) {
  return "${date.day.toString().padLeft(2, '0')}-"
      "${date.month.toString().padLeft(2, '0')}-"
      "${date.year}";
}

// ================= FORMAT RUPIAH =================
String _formatRupiah(int amount) {
  return amount.toString().replaceAllMapped(
    RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
    (Match m) => '${m[1]}.',
  );
}
