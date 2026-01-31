class UserSession {
  static String? nama;
  static String? email;

  static bool get isLoggedIn => email != null;

  static void login({required String namaUser, required String emailUser}) {
    nama = namaUser;
    email = emailUser;
  }

  static void logout() {
    nama = null;
    email = null;
  }
}
