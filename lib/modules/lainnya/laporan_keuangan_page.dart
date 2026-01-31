import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import '../../core/theme/sutura_text.dart';
import '../../data/keuangan_repository.dart';

class LaporanKeuanganPage extends StatefulWidget {
  const LaporanKeuanganPage({super.key});

  @override
  State<LaporanKeuanganPage> createState() => _LaporanKeuanganPageState();
}

class _LaporanKeuanganPageState extends State<LaporanKeuanganPage> {
  int bulanTerpilih = DateTime.now().month;
  int tahunTerpilih = DateTime.now().year;

  final List<String> namaBulan = [
    "Januari",
    "Februari",
    "Maret",
    "April",
    "Mei",
    "Juni",
    "Juli",
    "Agustus",
    "September",
    "Oktober",
    "November",
    "Desember",
  ];

  List<Map<String, dynamic>> get transaksiTerfilter {
    return KeuanganRepository.transaksi.where((t) {
      return t["bulan"] == bulanTerpilih && t["tahun"] == tahunTerpilih;
    }).toList();
  }

  int get totalMasuk =>
      transaksiTerfilter.fold(0, (sum, t) => sum + (t["masuk"] as int));

  int get totalKeluar =>
      transaksiTerfilter.fold(0, (sum, t) => sum + (t["keluar"] as int));

  int get labaBersih => totalMasuk - totalKeluar;

  Future<void> exportPdf() async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                "Laporan Keuangan",
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 4),
              pw.Text(
                "Bulan: ${namaBulan[bulanTerpilih - 1]}, Tahun: $tahunTerpilih",
                style: pw.TextStyle(fontSize: 14, color: PdfColors.grey700),
              ),
              pw.SizedBox(height: 12),

              // Ringkasan
              pw.Container(
                padding: const pw.EdgeInsets.all(10),
                decoration: pw.BoxDecoration(
                  color: PdfColors.grey300,
                  borderRadius: pw.BorderRadius.circular(6),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      "Ringkasan",
                      style: pw.TextStyle(
                        fontSize: 16,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(height: 6),
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text("Total Pemasukan:"),
                        pw.Text(
                          "Rp $totalMasuk",
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                        ),
                      ],
                    ),
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text("Total Pengeluaran:"),
                        pw.Text(
                          "Rp $totalKeluar",
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                        ),
                      ],
                    ),
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text("Laba Bersih:"),
                        pw.Text(
                          "Rp $labaBersih",
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              pw.SizedBox(height: 16),
              pw.Text(
                "Detail Transaksi",
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 8),

              // Tabel transaksi
              pw.TableHelper.fromTextArray(
                headers: ["Tgl", "Catatan", "Jenis", "Masuk", "Keluar"],
                data: transaksiTerfilter.map((t) {
                  final d = t["tgl"] as DateTime;
                  return [
                    "${d.day}/${d.month}/${d.year}",
                    t["catatan"],
                    t["jenis"],
                    "Rp ${t["masuk"]}",
                    "Rp ${t["keluar"]}",
                  ];
                }).toList(),
                headerStyle: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.white,
                ),
                headerDecoration: pw.BoxDecoration(color: PdfColors.blue),
                cellAlignment: pw.Alignment.centerLeft,
                cellPadding: const pw.EdgeInsets.all(6),
                border: pw.TableBorder.all(color: PdfColors.grey),
              ),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(onLayout: (format) async => pdf.save());
  }

  @override
  Widget build(BuildContext context) {
    final tahunSekitar = List.generate(11, (i) => DateTime.now().year - 5 + i);

    return Scaffold(
      appBar: AppBar(title: const Text("Laporan Keuangan")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Filter Laporan", style: SuturaText.subtitle),
            const SizedBox(height: 12),

            /// 🔽 PILIH BULAN & TAHUN
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<int>(
                    decoration: const InputDecoration(labelText: "Bulan"),
                    initialValue: bulanTerpilih,
                    items: List.generate(12, (i) {
                      return DropdownMenuItem(
                        value: i + 1,
                        child: Text(namaBulan[i]),
                      );
                    }),
                    onChanged: (v) {
                      if (v != null) setState(() => bulanTerpilih = v);
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<int>(
                    decoration: const InputDecoration(labelText: "Tahun"),
                    initialValue: tahunTerpilih,
                    items: tahunSekitar.map((t) {
                      return DropdownMenuItem(value: t, child: Text("$t"));
                    }).toList(),
                    onChanged: (v) {
                      if (v != null) setState(() => tahunTerpilih = v);
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            /// 📊 RINGKASAN
            Text("Ringkasan", style: SuturaText.subtitle),
            const SizedBox(height: 8),

            _item("Total Pemasukan", "Rp $totalMasuk"),
            _item("Total Pengeluaran", "Rp $totalKeluar"),
            _item("Laba Bersih", "Rp $labaBersih"),

            const SizedBox(height: 24),

            /// 📄 EXPORT PDF
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.picture_as_pdf),
                label: const Text("Export PDF"),
                onPressed: exportPdf,
              ),
            ),

            const SizedBox(height: 24),

            /// 📋 TABEL TRANSAKSI
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: const [
                    DataColumn(label: Text("Tgl")),
                    DataColumn(label: Text("Catatan")),
                    DataColumn(label: Text("Jenis")),
                    DataColumn(label: Text("Masuk")),
                    DataColumn(label: Text("Keluar")),
                  ],
                  rows: transaksiTerfilter.map((t) {
                    final d = t["tgl"] as DateTime;
                    return DataRow(
                      cells: [
                        DataCell(Text("${d.day}/${d.month}/${d.year}")),
                        DataCell(Text(t["catatan"])),
                        DataCell(Text(t["jenis"])),
                        DataCell(Text("Rp ${t["masuk"]}")),
                        DataCell(Text("Rp ${t["keluar"]}")),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _item(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
