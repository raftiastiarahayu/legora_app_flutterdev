class UkuranPelanggan {
  final int id;
  final String jenis; // nama jenis jasa
  final Map<String, double> ukuran;

  UkuranPelanggan({
    required this.id,
    required this.jenis,
    required this.ukuran,
  });

  factory UkuranPelanggan.fromSupabase(Map<String, dynamic> map) {
    final ukuranMap = <String, double>{};

    for (final item in map['detail_ukuran_pelanggan']) {
      ukuranMap[item['nama_ukuran']] = (item['nilai'] as num).toDouble();
    }

    return UkuranPelanggan(
      id: map['id'],
      jenis: map['jenis_jasa']['nama'],
      ukuran: ukuranMap,
    );
  }
}
