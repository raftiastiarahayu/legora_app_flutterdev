import 'package:flutter/material.dart';
import '../../core/widgets/sutura_card.dart';
import '../../data/models/pelanggan_model.dart';
import 'pelanggan_actions.dart';

class PelangganTable extends StatelessWidget {
  final List<Pelanggan> pelangganList;
  final String keyword;
  final void Function(Pelanggan) onDetail;
  final void Function(Pelanggan) onEdit;
  final void Function(Pelanggan) onTambahUkuran;
  final void Function(Pelanggan) onHapus;
  const PelangganTable({
    super.key,
    required this.pelangganList,
    required this.keyword,
    required this.onDetail,
    required this.onEdit,
    required this.onTambahUkuran,
    required this.onHapus,
  });
  @override
  Widget build(BuildContext context) {
    final filtered = pelangganList
        .where((p) => p.nama.toLowerCase().contains(keyword.toLowerCase()))
        .toList();
    return SuturaCard(
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SizedBox(
            height: _hitungTinggiTabel(filtered.length),
            child: Scrollbar(
              thumbVisibility: true,
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minWidth: constraints.maxWidth),
                    child: DataTable(
                      columnSpacing: 24,
                      columns: const [
                        DataColumn(label: Text("No")),
                        DataColumn(label: Text("Nama")),
                        DataColumn(label: Text("No. Telp")),
                        DataColumn(label: Text("Aksi")),
                      ],
                      rows: List.generate(filtered.length, (index) {
                        final item = filtered[index];
                        return DataRow(
                          cells: [
                            DataCell(Text("${index + 1}")),
                            DataCell(Text(item.nama)),
                            DataCell(Text(item.noTelp)),
                            DataCell(
                              PelangganActionButtons(
                                pelanggan: item,
                                onDetail: onDetail,
                                onEdit: onEdit,
                                onTambahUkuran: onTambahUkuran,
                                onHapus: onHapus,
                              ),
                            ),
                          ],
                        );
                      }),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  double _hitungTinggiTabel(int jumlahData) {
    const double tinggiHeader = 56;
    const double tinggiRow = 48;
    const int maxRow = 7;
    final rowDitampilkan = jumlahData > maxRow ? maxRow : jumlahData;
    return tinggiHeader + (rowDitampilkan * tinggiRow);
  }
}
