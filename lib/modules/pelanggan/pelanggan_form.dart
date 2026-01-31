// pelanggan_form.dart
import 'package:flutter/material.dart';
import '../../data/models/pelanggan_model.dart';
import '../../data/pelanggan_repository.dart';

Future<void> openPelangganForm({
  required BuildContext context,
  Pelanggan? pelanggan,
}) async {
  final namaController = TextEditingController(text: pelanggan?.nama ?? "");
  final telpController = TextEditingController(text: pelanggan?.noTelp ?? "");

  await showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: Text(pelanggan == null ? "Tambah Pelanggan" : "Edit Pelanggan"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: namaController,
            decoration: const InputDecoration(labelText: "Nama"),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: telpController,
            decoration: const InputDecoration(labelText: "No. Telp"),
            keyboardType: TextInputType.phone,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Batal"),
        ),
        ElevatedButton(
          onPressed: () async {
            final newPelanggan = Pelanggan(
              nama: namaController.text,
              noTelp: telpController.text,
            );

            // Insert ke Supabase + update cache lokal
            await PelangganRepository.insertPelanggan(newPelanggan);

            if (!context.mounted) return;
            Navigator.pop(context);
          },
          child: const Text("Simpan"),
        ),
      ],
    ),
  );
}
