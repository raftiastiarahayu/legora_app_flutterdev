import 'package:flutter/material.dart';
import 'widgets/ringkasan_keuangan.dart';
import 'widgets/filter_periode.dart';
import 'widgets/tabel_transaksi.dart';
import 'widgets/pilih_jenis_transaksi_sheet.dart';
import '../../core/widgets/sutura_button.dart';
import '../../data/keuangan_repository.dart';

class KeuanganPage extends StatefulWidget {
  const KeuanganPage({super.key});

  @override
  State<KeuanganPage> createState() => _KeuanganPageState();
}

class _KeuanganPageState extends State<KeuanganPage> {
  int bulanTerpilih = DateTime.now().month;
  int tahunTerpilih = DateTime.now().year;

  @override
  void initState() {
    super.initState();
    KeuanganRepository.fetch();
  }

  /// Filter pakai field `tgl` (YYYY-MM-DD)
  List<Map<String, dynamic>> _filterData(List<Map<String, dynamic>> data) {
    return data.where((t) {
      final date = DateTime.tryParse(t['tgl']);
      if (date == null) return false;
      return date.month == bulanTerpilih && date.year == tahunTerpilih;
    }).toList();
  }

  void _tambahTransaksi(Map<String, dynamic> data) async {
    await KeuanganRepository.add(data);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Keuangan")),
      body: ValueListenableBuilder(
        valueListenable: KeuanganRepository.notifier,
        builder: (context, _, __) {
          final transaksiTerfilter = _filterData(KeuanganRepository.transaksi);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                RingkasanKeuangan(data: transaksiTerfilter),
                const SizedBox(height: 24),

                FilterPeriode(
                  bulan: bulanTerpilih,
                  tahun: tahunTerpilih,
                  onChanged: (b, t) {
                    setState(() {
                      bulanTerpilih = b;
                      tahunTerpilih = t;
                    });
                  },
                ),

                const SizedBox(height: 16),

                TabelTransaksi(
                  data: transaksiTerfilter,
                  onHapus: (index) async {
                    await KeuanganRepository.delete(index);
                  },
                ),

                const SizedBox(height: 24),

                SuturaButton(
                  text: "Tambah Transaksi",
                  onPressed: () {
                    showPilihJenisTransaksi(
                      context,
                      onSubmit: _tambahTransaksi,
                      bulan: bulanTerpilih,
                      tahun: tahunTerpilih,
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
