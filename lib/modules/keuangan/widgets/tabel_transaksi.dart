import 'package:flutter/material.dart';
import '../../../core/theme/sutura_text.dart';

class TabelTransaksi extends StatelessWidget {
  final List<Map<String, dynamic>> data;
  final Function(int index) onHapus;

  const TabelTransaksi({super.key, required this.data, required this.onHapus});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Transaksi", style: SuturaText.title),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columns: const [
              DataColumn(label: Text("Tgl")),
              DataColumn(label: Text("Catatan")),
              DataColumn(label: Text("Jenis")),
              DataColumn(label: Text("Masuk")),
              DataColumn(label: Text("Keluar")),
              DataColumn(label: Text("Aksi")),
            ],
            rows: List.generate(data.length, (i) {
              final t = data[i];
              final d = t["tgl"] is DateTime
                  ? t["tgl"]
                  : DateTime.parse(t["tgl"]);

              return DataRow(
                cells: [
                  DataCell(Text("${d.day}/${d.month}/${d.year}")),
                  DataCell(Text(t["catatan"])),
                  DataCell(Text(t["jenis"])),
                  DataCell(Text("Rp ${t["masuk"]}")),
                  DataCell(Text("Rp ${t["keluar"]}")),
                  DataCell(
                    IconButton(
                      icon: const Icon(Icons.delete, size: 20),
                      onPressed: () => onHapus(i),
                    ),
                  ),
                ],
              );
            }),
          ),
        ),
      ],
    );
  }
}
