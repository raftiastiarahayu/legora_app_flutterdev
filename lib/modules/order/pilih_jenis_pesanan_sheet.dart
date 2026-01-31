import 'package:flutter/material.dart';
import 'form_pesanan_jahit.dart';
import 'form_pesanan_permak.dart';

class PilihJenisPesananSheet extends StatelessWidget {
  const PilihJenisPesananSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Pilih Jenis Pesanan",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          ListTile(
            leading: const Icon(Icons.checkroom),
            title: const Text("Jahit"),
            onTap: () async {
              final result = await _openForm(context, const FormPesananJahit());
              Navigator.pop(context, result); // result = true/false
            },
          ),
          ListTile(
            leading: const Icon(Icons.build),
            title: const Text("Permak"),
            onTap: () async {
              final result = await _openForm(
                context,
                const FormPesananPermak(),
              );
              Navigator.pop(context, result);
            },
          ),
        ],
      ),
    );
  }

  Future<bool?> _openForm(BuildContext context, Widget page) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => page,
    );
  }
}
