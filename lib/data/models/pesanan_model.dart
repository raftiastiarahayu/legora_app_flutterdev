import '../pesanan_repository.dart';

enum JenisPesanan { jahit, permak }

enum StatusPesanan { proses, selesai }

class Pesanan {
  final int? id; // ✅ TAMBAHAN

  final DateTime deadline;
  final String nama;
  final String catatan;
  final JenisPesanan jenis;

  int? harga;
  DateTime? tanggalSelesai;

  StatusPesanan _status;

  final String? ukuran;
  final String? fotoPath;

  Pesanan({
    this.id, // ✅ WAJIB
    required this.deadline,
    required this.nama,
    required this.catatan,
    required this.jenis,
    StatusPesanan status = StatusPesanan.proses,
    this.ukuran,
    this.fotoPath,
    this.harga,
    this.tanggalSelesai,
  }) : _status = status;

  StatusPesanan get status => _status;

  set status(StatusPesanan value) {
    _status = value;
    PesananRepository.notifier.value++;
  }
}
