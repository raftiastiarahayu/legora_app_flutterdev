import 'package:flutter/material.dart';
import '../../../core/widgets/sutura_button.dart';
import '../../../core/theme/sutura_text.dart';

void showFormTransaksi(
  BuildContext context, {
  required String kategori,
  required int bulan,
  required int tahun,
  required Function(Map<String, dynamic>) onSubmit,
}) {
  final nominalCtrl = TextEditingController();
  final catatanCtrl = TextEditingController();
  final formKey = GlobalKey<FormState>();

  String jenis = "Masuk";
  DateTime tanggal = DateTime.now();

  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: Text("Transaksi $kategori", style: SuturaText.title),
      content: Form(
        key: formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.calendar_today),
              title: Text("${tanggal.day}/${tanggal.month}/${tanggal.year}"),
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: tanggal,
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2035),
                );
                if (picked != null) tanggal = picked;
              },
            ),

            const SizedBox(height: 15),

            DropdownButtonFormField<String>(
              initialValue: jenis,
              items: const [
                DropdownMenuItem(value: "Masuk", child: Text("Masuk")),
                DropdownMenuItem(value: "Keluar", child: Text("Keluar")),
              ],
              onChanged: (v) => jenis = v!,
            ),

            const SizedBox(height: 15),

            TextFormField(
              controller: nominalCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Nominal"),
              validator: (v) => v == null || v.isEmpty ? "Wajib diisi" : null,
            ),

            const SizedBox(height: 15),

            TextFormField(
              controller: catatanCtrl,
              decoration: const InputDecoration(labelText: "Catatan"),
              validator: (v) => v == null || v.isEmpty ? "Wajib diisi" : null,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Batal"),
        ),
        SuturaButton(
          text: "Simpan",
          onPressed: () {
            if (!formKey.currentState!.validate()) return;

            final nominal = int.parse(nominalCtrl.text);

            onSubmit({
              "tgl": tanggal.toIso8601String(),
              "bulan": tanggal.month,
              "tahun": tanggal.year,
              "catatan": catatanCtrl.text,
              "jenis": kategori, // Rumah / Usaha
              "masuk": jenis == "Masuk" ? nominal : 0,
              "keluar": jenis == "Keluar" ? nominal : 0,
            });

            Navigator.pop(context);
          },
        ),
      ],
    ),
  );
}
