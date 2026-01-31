import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../data/models/pelanggan_model.dart';
import '../../data/pelanggan_repository.dart';
import '../../data/models/pesanan_model.dart';
import '../../data/pesanan_repository.dart';

class FormPesananJahit extends StatefulWidget {
  final Pesanan? pesanan; // null = tambah | ada = edit
  const FormPesananJahit({super.key, this.pesanan});

  @override
  State<FormPesananJahit> createState() => _FormPesananJahitState();
}

class _FormPesananJahitState extends State<FormPesananJahit> {
  Pelanggan? _selectedPelanggan;
  UkuranPelanggan? selectedJenis;
  DateTime? deadline;

  final TextEditingController _pelangganController = TextEditingController();
  final TextEditingController _ukuranController = TextEditingController();
  final TextEditingController _catatanController = TextEditingController();
  final FocusNode _pelangganFocusNode = FocusNode();

  File? _fotoModel; // ✅ foto model

  @override
  void initState() {
    super.initState();

    // MODE EDIT
    if (widget.pesanan != null) {
      deadline = widget.pesanan!.deadline;
      _catatanController.text = widget.pesanan!.catatan;
      _ukuranController.text = widget.pesanan!.ukuran ?? '';

      _selectedPelanggan = PelangganRepository.pelangganList.firstWhere(
        (p) => p.nama == widget.pesanan!.nama,
        orElse: () => PelangganRepository.pelangganList.first,
      );

      _pelangganController.text = _selectedPelanggan!.nama;

      if (widget.pesanan!.fotoPath != null) {
        _fotoModel = File(widget.pesanan!.fotoPath!);
      }
    }
  }

  @override
  void dispose() {
    _pelangganController.dispose();
    _ukuranController.dispose();
    _catatanController.dispose();
    _pelangganFocusNode.dispose();
    super.dispose();
  }

  void _updateUkuranField() {
    if (selectedJenis == null) {
      _ukuranController.text = '';
    } else {
      _ukuranController.text = selectedJenis!.ukuran.entries
          .map((e) => "${e.key}: ${e.value} cm")
          .join("\n");
    }
  }

  Future<void> _pickFoto() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _fotoModel = File(picked.path);
      });
    }
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
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Pesanan Jahit",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            /// DEADLINE
            ListTile(
              title: Text(
                deadline == null
                    ? "Pilih Deadline"
                    : "${deadline!.day}/${deadline!.month}/${deadline!.year}",
              ),
              trailing: const Icon(Icons.date_range),
              onTap: () async {
                final d = await showDatePicker(
                  context: context,
                  firstDate: DateTime.now(),
                  lastDate: DateTime(2030),
                  initialDate: deadline ?? DateTime.now(),
                );
                if (d != null) setState(() => deadline = d);
              },
            ),

            /// 🔍 NAMA PELANGGAN (SEARCH + COMBOBOX)
            RawAutocomplete<Pelanggan>(
              textEditingController: _pelangganController,
              focusNode: _pelangganFocusNode,
              displayStringForOption: (p) => p.nama,
              optionsBuilder: (value) {
                if (value.text.isEmpty) {
                  return PelangganRepository.pelangganList;
                }
                return PelangganRepository.pelangganList.where(
                  (p) =>
                      p.nama.toLowerCase().contains(value.text.toLowerCase()),
                );
              },
              onSelected: (p) {
                setState(() {
                  _selectedPelanggan = p;
                  selectedJenis = null;
                  _updateUkuranField();
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

            /// JENIS
            DropdownButtonFormField<UkuranPelanggan>(
              decoration: const InputDecoration(labelText: "Jenis"),
              initialValue: selectedJenis,
              items: _selectedPelanggan == null
                  ? []
                  : _selectedPelanggan!.ukuranList
                        .map(
                          (u) =>
                              DropdownMenuItem(value: u, child: Text(u.jenis)),
                        )
                        .toList(),
              onChanged: (value) {
                setState(() {
                  selectedJenis = value;
                  _updateUkuranField();
                });
              },
            ),

            const SizedBox(height: 12),

            /// UKURAN
            TextFormField(
              readOnly: true,
              controller: _ukuranController,
              maxLines: null,
              decoration: const InputDecoration(
                labelText: "Ukuran",
                alignLabelWithHint: true,
              ),
            ),

            const SizedBox(height: 12),

            /// FOTO MODEL (OPSIONAL)
            OutlinedButton.icon(
              onPressed: _pickFoto,
              icon: const Icon(Icons.camera_alt),
              label: const Text("Upload Foto Model (Opsional)"),
            ),

            if (_fotoModel != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Image.file(_fotoModel!, height: 150, fit: BoxFit.cover),
              ),

            const SizedBox(height: 12),

            /// CATATAN
            TextFormField(
              controller: _catatanController,
              maxLines: 3,
              decoration: const InputDecoration(labelText: "Catatan"),
            ),

            const SizedBox(height: 20),

            /// SIMPAN
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _selectedPelanggan == null || deadline == null
                    ? null
                    : () {
                        final newPesanan = Pesanan(
                          id: widget.pesanan?.id,
                          deadline: deadline!,
                          nama: _selectedPelanggan!.nama,
                          catatan: _catatanController.text,
                          jenis: JenisPesanan.jahit,
                          ukuran: _ukuranController.text,
                          fotoPath: _fotoModel?.path,
                          status:
                              widget.pesanan?.status ?? StatusPesanan.proses,
                        );

                        if (widget.pesanan == null) {
                          PesananRepository.add(newPesanan);
                        } else {
                          PesananRepository.update(newPesanan);
                        }

                        Navigator.pop(context, true);
                      },
                child: const Text("Simpan Pesanan"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
