import 'package:flutter/material.dart';
import '../../../core/theme/sutura_text.dart';

class FilterPeriode extends StatelessWidget {
  final int bulan;
  final int tahun;
  final Function(int bulan, int tahun) onChanged;

  const FilterPeriode({
    super.key,
    required this.bulan,
    required this.tahun,
    required this.onChanged,
  });

  static const _namaBulan = [
    "Januari",
    "Februari",
    "Maret",
    "April",
    "Mei",
    "Juni",
    "Juli",
    "Agustus",
    "September",
    "Oktober",
    "November",
    "Desember",
  ];

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text("Periode", style: SuturaText.subtitle),
        Row(
          children: [
            TextButton.icon(
              icon: const Icon(Icons.calendar_month),
              label: Text(_namaBulan[bulan - 1]),
              onPressed: () => _pilihBulan(context),
            ),
            const SizedBox(width: 8),
            TextButton(
              onPressed: () => _pilihTahun(context),
              child: Text(tahun.toString()),
            ),
          ],
        ),
      ],
    );
  }

  void _pilihBulan(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (_) => ListView(
        children: List.generate(12, (i) {
          final b = i + 1;
          return ListTile(
            title: Text(_namaBulan[i]),
            onTap: () {
              onChanged(b, tahun);
              Navigator.pop(context);
            },
          );
        }),
      ),
    );
  }

  void _pilihTahun(BuildContext context) {
    final now = DateTime.now().year;
    showModalBottomSheet(
      context: context,
      builder: (_) => ListView(
        children: List.generate(21, (i) {
          final t = now - 10 + i; // 10 th ke belakang & depan
          return ListTile(
            title: Text(t.toString()),
            onTap: () {
              onChanged(bulan, t);
              Navigator.pop(context);
            },
          );
        }),
      ),
    );
  }
}
