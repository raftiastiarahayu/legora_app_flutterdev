import 'package:flutter/material.dart';
import '../../data/models/pelanggan_model.dart';

class PelangganActionButtons extends StatelessWidget {
  final Pelanggan pelanggan;
  final void Function(Pelanggan) onDetail;
  final void Function(Pelanggan) onEdit;
  final void Function(Pelanggan) onTambahUkuran;
  final void Function(Pelanggan) onHapus;

  const PelangganActionButtons({
    super.key,
    required this.pelanggan,
    required this.onDetail,
    required this.onEdit,
    required this.onTambahUkuran,
    required this.onHapus,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.visibility),
          tooltip: "Detail",
          onPressed: () => onDetail(pelanggan),
        ),
        IconButton(
          icon: const Icon(Icons.edit),
          tooltip: "Edit",
          onPressed: () => onEdit(pelanggan),
        ),
        IconButton(
          icon: const Icon(Icons.straighten),
          tooltip: "Tambah Ukuran",
          onPressed: () => onTambahUkuran(pelanggan),
        ),
        IconButton(
          icon: const Icon(Icons.delete, color: Colors.red),
          tooltip: "Hapus",
          onPressed: () => onHapus(pelanggan), // ✅ INI SAJA
        ),
      ],
    );
  }
}
