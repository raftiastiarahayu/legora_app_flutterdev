import 'package:flutter/material.dart';

void showHapusPesananDialog(BuildContext context, VoidCallback onConfirm) {
  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text("Hapus Pesanan"),
      content: const Text("Yakin ingin menghapus pesanan ini?"),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Batal"),
        ),
        ElevatedButton(
          onPressed: () {
            onConfirm(); // 🔥 hapus beneran
            Navigator.pop(context);
          },
          child: const Text("Hapus"),
        ),
      ],
    ),
  );
}
