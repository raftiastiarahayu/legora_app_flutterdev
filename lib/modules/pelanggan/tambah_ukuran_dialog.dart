import 'package:flutter/material.dart';
import '../../data/models/pelanggan_model.dart';

Future<UkuranPelanggan?> showTambahUkuranDialog(
  BuildContext context, {
  required Map<String, List<String>> masterUkuran,
}) {
  String? selectedJenis;
  final Map<String, TextEditingController> ukuranControllers = {};

  return showDialog<UkuranPelanggan>(
    context: context,
    builder: (_) => StatefulBuilder(
      builder: (context, setDialogState) {
        return AlertDialog(
          title: const Text("Tambah Ukuran"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  hint: const Text("Pilih Jenis"),
                  value: selectedJenis,
                  items: masterUkuran.keys
                      .map(
                        (jenis) =>
                            DropdownMenuItem(value: jenis, child: Text(jenis)),
                      )
                      .toList(),
                  onChanged: (value) {
                    setDialogState(() {
                      selectedJenis = value;
                      ukuranControllers.clear();
                      for (final u in masterUkuran[value]!) {
                        ukuranControllers[u] = TextEditingController();
                      }
                    });
                  },
                ),
                const SizedBox(height: 16),
                if (selectedJenis != null)
                  ...ukuranControllers.entries.map(
                    (e) => TextField(
                      controller: e.value,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: e.key,
                        suffixText: 'cm',
                      ),
                    ),
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Batal"),
            ),
            ElevatedButton(
              onPressed: selectedJenis == null
                  ? null
                  : () {
                      Navigator.pop(
                        context,
                        UkuranPelanggan(
                          jenis: selectedJenis!,
                          ukuran: {
                            for (final e in ukuranControllers.entries)
                              e.key: double.tryParse(e.value.text) ?? 0,
                          },
                        ),
                      );
                    },
              child: const Text("Simpan"),
            ),
          ],
        );
      },
    ),
  );
}
