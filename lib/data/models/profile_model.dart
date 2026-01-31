class Profile {
  final String id;
  final String namaLengkap;
  final String namaUsaha;
  final String username;
  final String email;

  Profile({
    required this.id,
    required this.namaLengkap,
    required this.namaUsaha,
    required this.username,
    required this.email,
  });

  factory Profile.fromMap(Map<String, dynamic> map) {
    return Profile(
      id: map['id'],
      namaLengkap: map['nama_lengkap'],
      namaUsaha: map['nama_usaha'],
      username: map['username'],
      email: map['email'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nama_lengkap': namaLengkap,
      'nama_usaha': namaUsaha,
      'username': username,
    };
  }
}
