// pelanggan_page.dart
import 'package:flutter/material.dart';
import '../../core/theme/sutura_text.dart';
import '../../data/models/pelanggan_model.dart';
import 'pelanggan_form.dart';
import 'pelanggan_table.dart';
import '../../data/master_data_repository.dart';
import '../../data/pelanggan_repository.dart';
import 'tambah_ukuran_dialog.dart';

class PelangganPage extends StatefulWidget {
  const PelangganPage({super.key});
  @override
  State<PelangganPage> createState() => _PelangganPageState();
}

class _PelangganPageState extends State<PelangganPage> {
  final TextEditingController _searchController = TextEditingController();
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // DUMMY MASTER UKURAN
  Map<String, List<String>> get masterUkuran {
    return {
      for (final j in MasterDataRepository.jenisJasaList) j.nama: j.ukuran,
    };
  }

  @override
  void initState() {
    super.initState();
    PelangganRepository.fetchFromSupabase();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Pelanggan", style: SuturaText.title),
            const SizedBox(height: 16),
            TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: "Cari nama pelanggan...",
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 16),

            /// 👇 Expanded dengan ValueListenableBuilder
            Expanded(
              child: ValueListenableBuilder<List<Pelanggan>>(
                valueListenable: PelangganRepository.notifier,
                builder: (context, list, _) {
                  final filtered = list
                      .where(
                        (p) => p.nama.toLowerCase().contains(
                          _searchController.text.toLowerCase(),
                        ),
                      )
                      .toList();

                  return PelangganTable(
                    pelangganList: filtered,
                    keyword: _searchController.text,
                    onDetail: _lihatDetail,
                    onEdit: _editPelanggan,
                    onTambahUkuran: (pelanggan) async {
                      final ukuranBaru = await showTambahUkuranDialog(
                        context,
                        masterUkuran: masterUkuran,
                      );
                      if (ukuranBaru == null) return;
                      await PelangganRepository.addUkuranToPelanggan(
                        pelanggan: pelanggan,
                        ukuranBaru: ukuranBaru,
                      );
                    },
                    onHapus: (pelanggan) async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('Hapus Pelanggan'),
                          content: const Text(
                            'Yakin ingin menghapus pelanggan ini?',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx, false),
                              child: const Text('Batal'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(ctx, true),
                              child: const Text('Hapus'),
                            ),
                          ],
                        ),
                      );
                      if (confirm == true) {
                        await PelangganRepository.deletePelanggan(pelanggan);
                      }
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.add),
                label: const Text("Tambah Pelanggan Baru"),
                onPressed: () => _openForm(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// ================= FORM TAMBAH =================
  void _openForm({Pelanggan? pelanggan}) {
    openPelangganForm(context: context, pelanggan: pelanggan).then((_) {
      // Refresh otomatis sudah handled oleh ValueNotifier
      // tapi bisa tambahan logika jika perlu
    });
  }

  /// ================= DETAIL =================
  void _lihatDetail(Pelanggan item) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(item.nama, style: SuturaText.title),
            const SizedBox(height: 4),
            Text("No. Telp: ${item.noTelp}", style: SuturaText.subtitle),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: item.ukuranList.isEmpty
                ? [const Text("Belum ada data ukuran")]
                : item.ukuranList.map((u) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                u.jenis,
                                style: SuturaText.subtitle.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const Divider(),
                          ...u.ukuran.entries.map(
                            (e) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 2),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [Text(e.key), Text("${e.value} cm")],
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Tutup"),
          ),
        ],
      ),
    );
  }

  /// ================= EDIT =================
  void _editPelanggan(Pelanggan pelanggan) {
    final namaController = TextEditingController(text: pelanggan.nama);
    final telpController = TextEditingController(text: pelanggan.noTelp);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Edit Pelanggan"),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
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
              const SizedBox(height: 16),
              const Divider(),
              const Text(
                "Edit Ukuran",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              if (pelanggan.ukuranList.isEmpty)
                const Text("Belum ada data ukuran")
              else
                ...pelanggan.ukuranList.map(
                  (u) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(u.jenis),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => _editUkuranDialog(u),
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
            onPressed: () async {
              // Update Supabase & cache lokal
              final newData = Pelanggan(
                nama: namaController.text,
                noTelp: telpController.text,
                ukuranList: pelanggan.ukuranList,
              );
              await PelangganRepository.updatePelangganSupabase(
                oldData: pelanggan,
                newData: newData,
              );
              if (!context.mounted) return;
              Navigator.pop(context);
            },
            child: const Text("Simpan"),
          ),
        ],
      ),
    );
  }

  void _editUkuranDialog(UkuranPelanggan ukuranPelanggan) {
    final controllers = {
      for (var e in ukuranPelanggan.ukuran.entries)
        e.key: TextEditingController(text: e.value.toString()),
    };

    showDialog(
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
                  decoration: InputDecoration(
                    labelText: e.key,
                    suffixText: "cm",
                  ),
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
              // 🔥 update object
              ukuranPelanggan.ukuran = {
                for (var e in controllers.entries)
                  e.key: double.tryParse(e.value.text) ?? 0.0,
              };

              // 🔥 SIMPAN KE SUPABASE
              await PelangganRepository.updateUkuranSupabase(
                pelanggan: _findPelangganByUkuran(ukuranPelanggan),
                ukuran: ukuranPelanggan,
              );

              if (!context.mounted) return;
              Navigator.pop(context);
            },
            child: const Text("Simpan"),
          ),
        ],
      ),
    );
  }

  Pelanggan _findPelangganByUkuran(UkuranPelanggan ukuran) {
    return PelangganRepository.pelangganList.firstWhere(
      (p) => p.ukuranList.contains(ukuran),
    );
  }
}
