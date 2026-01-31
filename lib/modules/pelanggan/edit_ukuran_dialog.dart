import 'package:flutter/material.dart';
import '../../data/models/pelanggan_model.dart';
import '../../data/pelanggan_repository.dart';

Future<void> showEditUkuranDialog(
  BuildContext context, {
  required Pelanggan pelanggan,
  required UkuranPelanggan ukuranPelanggan,
}) async {
  // Buat controller untuk tiap ukuran
  final Map<String, TextEditingController> controllers = {
    for (final e in ukuranPelanggan.ukuran.entries)
      e.key: TextEditingController(text: e.value.toString()),
  };

  await showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: Text("Edit Ukuran ${ukuranPelanggan.jenis}"),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: controllers.entries.map((e) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: TextField(
                controller: e.value,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: e.key, suffixText: "cm"),
              ),
            );
          }).toList(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Batal"),
        ),
        ElevatedButton(
          onPressed: () async {
            // 1️⃣ Update ukuran lokal
            final Map<String, double> newUkuran = {
              for (final e in controllers.entries)
                e.key: double.tryParse(e.value.text) ?? 0,
            };
            ukuranPelanggan.ukuran
              ..clear()
              ..addAll(newUkuran);

            try {
              // 2️⃣ Update ke Supabase
              await PelangganRepository.update(pelanggan);

              // 3️⃣ Fetch ulang semua pelanggan dari Supabase agar cache sinkron
              await PelangganRepository.fetchFromSupabase();

              if (!context.mounted) return;
              Navigator.pop(context);
            } catch (e) {
              debugPrint('❌ Gagal simpan ukuran: $e');
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Gagal simpan ukuran: $e')),
              );
            }
          },
          child: const Text("Simpan"),
        ),
      ],
    ),
  );
}
