class JenisJasa {
  String nama;
  List<String> ukuran;

  JenisJasa({required this.nama, required this.ukuran});

  // Dari Map (Supabase)
  factory JenisJasa.fromMap(Map<String, dynamic> map) {
    return JenisJasa(
      nama: map['nama'] ?? '',
      ukuran: List<String>.from(map['ukuran'] ?? []),
    );
  }

  // Untuk insert/update ke Supabase
  Map<String, dynamic> toMap() {
    return {'nama': nama, 'ukuran': ukuran};
  }
}
