import 'package:flutter/material.dart';
import '../../core/theme/sutura_text.dart';
import '../../core/widgets/sutura_card.dart';
import '../../data/models/jenis_jasa_model.dart';
import '../../data/master_data_repository.dart';

class MasterDataPage extends StatefulWidget {
  const MasterDataPage({super.key});

  @override
  State<MasterDataPage> createState() => _MasterDataPageState();
}

class _MasterDataPageState extends State<MasterDataPage> {
  late List<JenisJasa> _jenisJasaList;
  bool _loading = true;

  @override
  void initState() {
    super.initState();

    // Ambil data dari Supabase
    _fetchData();
  }

  Future<void> _fetchData() async {
    await MasterDataRepository.fetchJenisJasa();

    // Fallback data lokal jika kosong
    if (MasterDataRepository.jenisJasaList.isEmpty) {
      MasterDataRepository.jenisJasaList.addAll([
        JenisJasa(
          nama: "Gamis",
          ukuran: ["Lingkar Dada", "Panjang Badan", "Panjang Lengan"],
        ),
        JenisJasa(
          nama: "Atasan Wanita",
          ukuran: ["Lingkar Dada", "Panjang Badan"],
        ),
      ]);
    }

    setState(() {
      _jenisJasaList = MasterDataRepository.jenisJasaList;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Master Data"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Expanded(child: _listJenis()),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.add),
                    label: const Text("Tambah Jenis Jasa"),
                    onPressed: () => _openForm(),
                  ),
                ],
              ),
            ),
    );
  }

  /// ================= LIST =================
  Widget _listJenis() {
    return ListView.builder(
      itemCount: _jenisJasaList.length,
      itemBuilder: (context, index) {
        final item = _jenisJasaList[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: SuturaCard(
            child: ListTile(
              title: Text(item.nama, style: SuturaText.body),
              subtitle: Text(
                "Ukuran: ${item.ukuran.join(', ')}",
                style: SuturaText.subtitle,
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  /// EDIT
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () => _openForm(jenis: item, index: index),
                  ),

                  /// HAPUS
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () async {
                      await MasterDataRepository.deleteJenisJasa(item.nama);
                      setState(() {
                        _jenisJasaList = MasterDataRepository.jenisJasaList;
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// ================= FORM TAMBAH / EDIT =================
  void _openForm({JenisJasa? jenis, int? index}) {
    final namaController = TextEditingController(text: jenis?.nama ?? "");
    final List<TextEditingController> ukuranControllers =
        (jenis?.ukuran ?? [""])
            .map((u) => TextEditingController(text: u))
            .toList();

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: Text(
              jenis == null ? "Tambah Jenis Jasa" : "Edit Jenis Jasa",
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Nama Jenis
                  TextField(
                    controller: namaController,
                    decoration: const InputDecoration(
                      labelText: "Nama Jenis Jasa",
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Ukuran
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text("Ukuran", style: SuturaText.subtitle),
                  ),
                  const SizedBox(height: 8),

                  ...List.generate(ukuranControllers.length, (i) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: ukuranControllers[i],
                              decoration: InputDecoration(
                                labelText: "Ukuran ${i + 1}",
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: const Icon(
                              Icons.remove_circle,
                              color: Colors.red,
                            ),
                            onPressed: () {
                              setDialogState(() {
                                ukuranControllers.removeAt(i);
                              });
                            },
                          ),
                        ],
                      ),
                    );
                  }),

                  // Tambah Ukuran
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton.icon(
                      icon: const Icon(Icons.add),
                      label: const Text("Tambah Ukuran"),
                      onPressed: () {
                        setDialogState(() {
                          ukuranControllers.add(TextEditingController());
                        });
                      },
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
                  final ukuran = ukuranControllers
                      .map((c) => c.text)
                      .where((e) => e.isNotEmpty)
                      .toList();

                  final newJenis = JenisJasa(
                    nama: namaController.text,
                    ukuran: ukuran,
                  );

                  if (jenis == null) {
                    // Insert ke Supabase
                    await MasterDataRepository.insertJenisJasa(newJenis);
                  } else {
                    // Update di Supabase
                    await MasterDataRepository.updateJenisJasa(
                      jenis.nama,
                      newJenis,
                    );
                  }

                  setState(() {
                    _jenisJasaList = MasterDataRepository.jenisJasaList;
                  });

                  Navigator.pop(context);
                },
                child: const Text("Simpan"),
              ),
            ],
          );
        },
      ),
    );
  }
}
