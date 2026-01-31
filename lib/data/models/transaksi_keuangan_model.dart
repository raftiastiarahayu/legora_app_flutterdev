class TransaksiKeuangan {
  final DateTime tgl;
  final String catatan;
  final String kategori; // Rumah / Usaha
  final int masuk;
  final int keluar;

  double? harga;
  DateTime? tanggalSelesai;

  TransaksiKeuangan({
    required this.tgl,
    required this.catatan,
    required this.kategori,
    required this.masuk,
    required this.keluar,
  });

  /// 🔹 DARI SUPABASE -> MODEL
  factory TransaksiKeuangan.fromMap(Map<String, dynamic> map) {
    return TransaksiKeuangan(
      tgl: DateTime.parse(map['tgl']),
      catatan: map['catatan'] ?? '',
      kategori: map['jenis'] ?? '', // 🔥 mapping aman
      masuk: map['masuk'] ?? 0,
      keluar: map['keluar'] ?? 0,
    );
  }

  /// 🔹 DARI MODEL -> SUPABASE (kalau nanti perlu)
  Map<String, dynamic> toMap() {
    return {
      'tgl': tgl,
      'catatan': catatan,
      'jenis': kategori,
      'masuk': masuk,
      'keluar': keluar,
    };
  }
}
