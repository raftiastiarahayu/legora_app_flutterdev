import 'package:flutter/material.dart';
import '../../../data/models/pelanggan_model.dart';
import '../../../data/pelanggan_repository.dart';

class PelangganDropdownSearch extends StatefulWidget {
  final Pelanggan? value;
  final List<Pelanggan> items;
  final ValueChanged<Pelanggan> onChanged;

  const PelangganDropdownSearch({
    super.key,
    required this.items,
    required this.onChanged,
    this.value,
  });

  @override
  State<PelangganDropdownSearch> createState() =>
      _PelangganDropdownSearchState();
}

class _PelangganDropdownSearchState extends State<PelangganDropdownSearch> {
  final TextEditingController _searchController = TextEditingController();
  late List<Pelanggan> _filtered;

  @override
  void initState() {
    super.initState();
    // Ambil semua pelanggan dari Supabase saat page dibuka
    PelangganRepository.fetchFromSupabase();
  }

  @override
  void dispose() {
    _searchController.dispose();
    PelangganRepository.notifier.removeListener(() {});
    super.dispose();
  }

  void _openDropdown() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: StatefulBuilder(
            builder: (context, setModalState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  /// SEARCH FIELD
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: TextField(
                      controller: _searchController,
                      decoration: const InputDecoration(
                        hintText: "Cari pelanggan...",
                        prefixIcon: Icon(Icons.search),
                      ),
                      onChanged: (value) {
                        setModalState(() {
                          _filtered = widget.items
                              .where(
                                (p) => p.nama.toLowerCase().contains(
                                  value.toLowerCase(),
                                ),
                              )
                              .toList();
                        });
                      },
                    ),
                  ),

                  /// LIST PELANGGAN
                  Flexible(
                    child: _filtered.isEmpty
                        ? const Padding(
                            padding: EdgeInsets.all(24),
                            child: Text("Pelanggan tidak ditemukan"),
                          )
                        : ListView.builder(
                            itemCount: _filtered.length,
                            itemBuilder: (_, index) {
                              final p = _filtered[index];
                              return ListTile(
                                title: Text(p.nama),
                                subtitle: Text(p.noTelp),
                                onTap: () {
                                  widget.onChanged(p);
                                  Navigator.pop(context);
                                },
                              );
                            },
                          ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: _openDropdown,
      child: InputDecorator(
        decoration: const InputDecoration(
          labelText: "Nama Pelanggan",
          suffixIcon: Icon(Icons.arrow_drop_down),
        ),
        child: Text(
          widget.value?.nama ?? "Pilih pelanggan",
          style: widget.value == null
              ? TextStyle(color: Colors.grey.shade600)
              : null,
        ),
      ),
    );
  }
}
