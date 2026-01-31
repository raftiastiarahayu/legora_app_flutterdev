import 'package:flutter/material.dart';
import '../../../core/widgets/sutura_card.dart';
import '../../../core/theme/sutura_text.dart';

class RingkasanKeuangan extends StatelessWidget {
  final List<Map<String, dynamic>> data;
  const RingkasanKeuangan({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    int totalMasuk = 0, totalKeluar = 0;
    int rumahMasuk = 0, rumahKeluar = 0;
    int usahaMasuk = 0, usahaKeluar = 0;

    for (var t in data) {
      totalMasuk += t["masuk"] as int;
      totalKeluar += t["keluar"] as int;
      if (t["jenis"] == "Rumah") {
        rumahMasuk += t["masuk"] as int;
        rumahKeluar += t["keluar"] as int;
      } else {
        usahaMasuk += t["masuk"] as int;
        usahaKeluar += t["keluar"] as int;
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Ringkasan", style: SuturaText.title),
        const SizedBox(height: 12),
        SuturaCard(
          child: ListTile(
            leading: const Icon(Icons.account_balance_wallet),
            title: Text("Total Saldo", style: SuturaText.subtitle),
            subtitle: Text("Rp ${totalMasuk - totalKeluar}"),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _KategoriCard(
                title: "Rumah",
                masuk: rumahMasuk,
                keluar: rumahKeluar,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _KategoriCard(
                title: "Usaha",
                masuk: usahaMasuk,
                keluar: usahaKeluar,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _KategoriCard extends StatelessWidget {
  final String title;
  final int masuk;
  final int keluar;

  const _KategoriCard({
    required this.title,
    required this.masuk,
    required this.keluar,
  });

  @override
  Widget build(BuildContext context) {
    return SuturaCard(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: SuturaText.subtitle),
            const SizedBox(height: 8),
            Text("Masuk : Rp $masuk"),
            Text("Keluar : Rp $keluar"),
          ],
        ),
      ),
    );
  }
}
