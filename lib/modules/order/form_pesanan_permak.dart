import 'package:flutter/material.dart';
import '../../data/pelanggan_repository.dart';
import '../../data/pesanan_repository.dart';
import '../../data/models/pesanan_model.dart';
import '../../data/models/pelanggan_model.dart';

class FormPesananPermak extends StatefulWidget {
  final Pesanan? pesanan; // null = tambah | ada = edit

  const FormPesananPermak({super.key, this.pesanan});

  @override
  State<FormPesananPermak> createState() => _FormPesananPermakState();
}

class _FormPesananPermakState extends State<FormPesananPermak> {
  late TextEditingController _catatanController;
  final TextEditingController _pelangganController = TextEditingController();

  // ✅ jangan inline
  final FocusNode _pelangganFocusNode = FocusNode();

  Pelanggan? _selectedPelanggan;

  @override
  void initState() {
    super.initState();

    _catatanController = TextEditingController(
      text: widget.pesanan?.catatan ?? '',
    );

    // MODE EDIT: prefill pelanggan
    if (widget.pesanan != null) {
      _selectedPelanggan = PelangganRepository.pelangganList.firstWhere(
        (p) => p.nama == widget.pesanan!.nama,
      );
      _pelangganController.text = _selectedPelanggan!.nama;
    }
  }

  @override
  void dispose() {
    _catatanController.dispose();
    _pelangganController.dispose();
    _pelangganFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.pesanan == null ? "Pesanan Permak" : "Edit Pesanan Permak",
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          /// 🔍 NAMA PELANGGAN (SEARCH + COMBOBOX)
          RawAutocomplete<Pelanggan>(
            textEditingController: _pelangganController,
            focusNode: _pelangganFocusNode,
            displayStringForOption: (p) => p.nama,
            optionsBuilder: (value) {
              // COMBOBOX MODE
              if (value.text.isEmpty) {
                return PelangganRepository.pelangganList;
              }
              // SEARCH MODE
              return PelangganRepository.pelangganList.where(
                (p) => p.nama.toLowerCase().contains(value.text.toLowerCase()),
              );
            },
            onSelected: (p) {
              setState(() {
                _selectedPelanggan = p;
                _pelangganController.text = p.nama;
              });
            },
            fieldViewBuilder: (context, controller, focusNode, _) {
              return TextField(
                controller: controller,
                focusNode: focusNode,
                decoration: const InputDecoration(
                  labelText: "Nama Pelanggan",
                  hintText: "Ketik atau pilih dari daftar",
                  prefixIcon: Icon(Icons.search),
                  suffixIcon: Icon(Icons.arrow_drop_down),
                ),
              );
            },
            optionsViewBuilder: (context, onSelected, options) {
              return Material(
                elevation: 4,
                borderRadius: BorderRadius.circular(8),
                child: ListView.builder(
                  padding: EdgeInsets.zero,
                  shrinkWrap: true,
                  itemCount: options.length,
                  itemBuilder: (context, index) {
                    final p = options.elementAt(index);
                    return ListTile(
                      title: Text(p.nama),
                      subtitle: Text(p.noTelp),
                      onTap: () => onSelected(p),
                    );
                  },
                ),
              );
            },
          ),

          if (_selectedPelanggan != null)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                "No. Telp: ${_selectedPelanggan!.noTelp}",
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),

          const SizedBox(height: 12),

          /// CATATAN
          TextFormField(
            controller: _catatanController,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: "Catatan",
              hintText: "Contoh: potong panjang, ganti resleting",
            ),
          ),

          const SizedBox(height: 20),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _selectedPelanggan == null
                  ? null
                  : () {
                      final newPesanan = Pesanan(
                        id: widget.pesanan?.id,
                        deadline: widget.pesanan?.deadline ?? DateTime.now(),
                        nama: _selectedPelanggan!.nama,
                        catatan: _catatanController.text,
                        jenis: JenisPesanan.permak,
                        status: widget.pesanan?.status ?? StatusPesanan.proses,
                      );

                      if (widget.pesanan == null) {
                        PesananRepository.add(newPesanan);
                      } else {
                        PesananRepository.update(newPesanan);
                      }

                      Navigator.pop(context, true);
                    },
              child: Text(
                widget.pesanan == null ? "Simpan Pesanan" : "Update Pesanan",
              ),
            ),
          ),
        ],
      ),
    );
  }
}
