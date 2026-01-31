class UkuranPelanggan {
  String jenis;
  Map<String, double> ukuran;
  UkuranPelanggan({required this.jenis, required this.ukuran});
}

class Pelanggan {
  String nama;
  String noTelp;
  List<UkuranPelanggan> ukuranList;
  Pelanggan({
    required this.nama,
    required this.noTelp,
    List<UkuranPelanggan>? ukuranList,
  }) : ukuranList = ukuranList ?? [];
}
