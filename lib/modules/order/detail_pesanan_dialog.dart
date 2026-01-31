import 'package:flutter/material.dart';
import 'dart:io';
import '../../data/models/pesanan_model.dart';

/// ================= ITEM TEKS =================
Widget _item(String label, String value) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: RichText(
      text: TextSpan(
        style: const TextStyle(color: Colors.black),
        children: [
          TextSpan(
            text: "$label: ",
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          TextSpan(text: value),
        ],
      ),
    ),
  );
}

/// ================= FOTO (LOCAL + SUPABASE) =================
Widget _buildFoto(String path) {
  // 🔥 JIKA DARI SUPABASE (URL)
  if (path.startsWith('http')) {
    return Image.network(
      path,
      height: 180,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return const SizedBox(
          height: 180,
          child: Center(child: CircularProgressIndicator()),
        );
      },
      errorBuilder: (_, __, ___) {
        return const Text("Gagal memuat gambar");
      },
    );
  }

  // 🔥 JIKA DARI LOKAL
  return Image.file(File(path), height: 180, fit: BoxFit.cover);
}

/// ================= DIALOG =================
void showDetailPesanan(BuildContext context, Pesanan pesanan) {
  showDialog(
    context: context,
    builder: (_) {
      return AlertDialog(
        title: const Text("Detail Pesanan"),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _item("Nama", pesanan.nama),
              _item(
                "Status",
                pesanan.status == StatusPesanan.selesai ? "Selesai" : "Proses",
              ),
              _item("Catatan", pesanan.catatan),

              /// ================= JAHIT =================
              if (pesanan.jenis == JenisPesanan.jahit &&
                  pesanan.ukuran != null) ...[
                const SizedBox(height: 12),
                const Text(
                  "Ukuran",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(pesanan.ukuran!),
              ],

              /// ================= FOTO =================
              if (pesanan.fotoPath != null && pesanan.fotoPath!.isNotEmpty) ...[
                const SizedBox(height: 12),
                const Text(
                  "Foto Model",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                _buildFoto(pesanan.fotoPath!),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Tutup"),
          ),
        ],
      );
    },
  );
}
