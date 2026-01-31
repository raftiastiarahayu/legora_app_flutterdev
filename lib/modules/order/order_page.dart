import 'package:flutter/material.dart';
import '../../core/theme/sutura_text.dart';
import '../../core/widgets/sutura_card.dart';

import 'pilih_jenis_pesanan_sheet.dart';
import 'detail_pesanan_dialog.dart';
import 'hapus_pesanan_dialog.dart';

import '../../data/pesanan_repository.dart';
import '../../data/models/pesanan_model.dart';
import '../../data/keuangan_repository.dart';

import 'form_pesanan_jahit.dart';
import 'form_pesanan_permak.dart';

class OrderPage extends StatefulWidget {
  const OrderPage({super.key});

  @override
  State<OrderPage> createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {
  List<Pesanan> _jahitFiltered = [];
  List<Pesanan> _permakFiltered = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    PesananRepository.fetchPesanan(); // ⬅️ INI YANG KURANG
    _filterPesanan();
    PesananRepository.notifier.addListener(_filterPesanan);
  }

  @override
  void dispose() {
    _searchController.dispose();
    PesananRepository.notifier.removeListener(_filterPesanan);
    super.dispose();
  }

  // ================= INPUT HARGA / SELESAI =================
  void _showInputHargaDialog(Pesanan p) {
    final hargaCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text("Selesaikan Pesanan"),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: hargaCtrl,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: "Harga Akhir",
              prefixText: "Rp ",
            ),
            validator: (v) {
              if (v == null || v.isEmpty) return "Harga wajib diisi";
              if (int.tryParse(v) == null) return "Harga tidak valid";
              return null;
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal"),
          ),
          ElevatedButton(
            child: const Text("Simpan & Selesai"),
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;

              final harga = int.parse(hargaCtrl.text);

              // Update status pesanan lokal
              setState(() {
                p.status = StatusPesanan.selesai;
                p.harga = harga;
                p.tanggalSelesai = DateTime.now();
              });

              // 🔥 UPDATE PESANAN
              PesananRepository.update(p);

              // 🔥 SIAPKAN DATA KEUANGAN
              final catatanTransaksi =
                  "${p.nama} - ${p.jenis == JenisPesanan.jahit ? 'Jahit' : 'Permak'}";

              final dataKeuangan = {
                "tgl": p.tanggalSelesai!.toIso8601String(),
                "bulan": p.tanggalSelesai!.month,
                "tahun": p.tanggalSelesai!.year,
                "catatan": catatanTransaksi,
                "jenis": "Usaha",
                "masuk": harga,
                "keluar": 0,
              };

              // 🔥 MASUKKAN KE SUPABASE & REPOSITORY
              try {
                await KeuanganRepository.add(dataKeuangan);
                debugPrint(
                  "Transaksi keuangan berhasil ditambahkan: $dataKeuangan",
                );
              } catch (e) {
                debugPrint("Gagal menambahkan transaksi keuangan: $e");
              }

              Navigator.pop(context);
              _filterPesanan(); // refresh tabel pesanan
            },
          ),
        ],
      ),
    );
  }

  void _filterPesanan() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _jahitFiltered = PesananRepository.jahit
          .where((p) => p.nama.toLowerCase().contains(query))
          .toList();
      _permakFiltered = PesananRepository.permak
          .where((p) => p.nama.toLowerCase().contains(query))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Pesanan", style: SuturaText.title),
            const SizedBox(height: 16),
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: "Cari berdasarkan nama...",
                prefixIcon: const Icon(Icons.search),
              ),
              onChanged: (_) => _filterPesanan(),
            ),
            const SizedBox(height: 24),
            Text("Pesanan Jahit", style: SuturaText.title),
            const SizedBox(height: 12),
            _jahitTable(),
            const SizedBox(height: 24),
            Text("Pesanan Permak", style: SuturaText.title),
            const SizedBox(height: 12),
            _permakTable(),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              icon: const Icon(Icons.add),
              label: const Text("Tambah Pesanan"),
              onPressed: () async {
                final result = await showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                  ),
                  builder: (_) => const PilihJenisPesananSheet(),
                );
                if (result == true) _filterPesanan();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _jahitTable() => SuturaCard(
    child: SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: const [
          DataColumn(label: Text("Tanggal")),
          DataColumn(label: Text("Nama")),
          DataColumn(label: Text("Status")),
          DataColumn(label: Text("Catatan")),
          DataColumn(label: Text("Aksi")),
          DataColumn(label: Text("Selesai")),
        ],
        rows: _jahitFiltered.map(_rowPesanan).toList(),
      ),
    ),
  );

  Widget _permakTable() => SuturaCard(
    child: SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: const [
          DataColumn(label: Text("Tanggal")),
          DataColumn(label: Text("Nama")),
          DataColumn(label: Text("Status")),
          DataColumn(label: Text("Catatan")),
          DataColumn(label: Text("Aksi")),
          DataColumn(label: Text("Selesai")),
        ],
        rows: _permakFiltered.map(_rowPesanan).toList(),
      ),
    ),
  );

  DataRow _rowPesanan(Pesanan p) => DataRow(
    cells: [
      DataCell(
        Text("${p.deadline.day}/${p.deadline.month}/${p.deadline.year}"),
      ),
      DataCell(Text(p.nama)),
      DataCell(Text(p.status == StatusPesanan.selesai ? "Selesai" : "Proses")),
      DataCell(Text(p.catatan)),
      DataCell(_aksiButton(p)),
      DataCell(
        Checkbox(
          value: p.status == StatusPesanan.selesai,
          onChanged: p.status == StatusPesanan.selesai
              ? null
              : (_) => _showInputHargaDialog(p),
        ),
      ),
    ],
  );

  Widget _aksiButton(Pesanan pesanan) => Row(
    children: [
      IconButton(
        icon: const Icon(Icons.visibility),
        onPressed: () => showDetailPesanan(context, pesanan),
      ),
      IconButton(
        icon: const Icon(Icons.edit),
        onPressed: () async {
          final result = await showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            builder: (_) => pesanan.jenis == JenisPesanan.jahit
                ? FormPesananJahit(pesanan: pesanan)
                : FormPesananPermak(pesanan: pesanan),
          );
          if (result == true) _filterPesanan();
        },
      ),
      IconButton(
        icon: const Icon(Icons.delete),
        onPressed: () => showHapusPesananDialog(context, () {
          setState(() {
            PesananRepository.delete(pesanan);
            _filterPesanan();
          });
        }),
      ),
    ],
  );
}
