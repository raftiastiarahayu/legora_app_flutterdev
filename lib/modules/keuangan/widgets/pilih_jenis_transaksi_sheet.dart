import 'package:flutter/material.dart';
import 'form_transaksi_dialog.dart';

void showPilihJenisTransaksi(
  BuildContext context, {
  required Function(Map<String, dynamic>) onSubmit,
  required int bulan,
  required int tahun,
}) {
  showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (_) => Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ListTile(
          leading: const Icon(Icons.home),
          title: const Text("Transaksi Rumah"),
          onTap: () {
            Navigator.pop(context);
            showFormTransaksi(
              context,
              kategori: "Rumah",
              bulan: bulan,
              tahun: tahun,
              onSubmit: onSubmit,
            );
          },
        ),
        ListTile(
          leading: const Icon(Icons.store),
          title: const Text("Transaksi Usaha"),
          onTap: () {
            Navigator.pop(context);
            showFormTransaksi(
              context,
              kategori: "Usaha",
              bulan: bulan,
              tahun: tahun,
              onSubmit: onSubmit,
            );
          },
        ),
        const SizedBox(height: 12),
      ],
    ),
  );
}
