import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'models/transaksi_keuangan_model.dart';

class KeuanganRepository {
  static final SupabaseClient _supabase = Supabase.instance.client;

  // 🔥 CACHE LOKAL
  static final List<Map<String, dynamic>> transaksi = [];
  static final List<TransaksiKeuangan> keuanganList = [];
  static final ValueNotifier<int> notifier = ValueNotifier(0);

  /// ================= FETCH =================
  static Future<void> fetch() async {
    final res = await _supabase
        .from('transaksi_keuangan')
        .select()
        .order('tgl');

    transaksi
      ..clear()
      ..addAll(res);

    keuanganList
      ..clear()
      ..addAll(res.map<TransaksiKeuangan>((e) => TransaksiKeuangan.fromMap(e)));

    notifier.value++;
  }

  /// ================= ADD =================
  static Future<void> add(Map<String, dynamic> data) async {
    await _supabase.from('transaksi_keuangan').insert(data);

    transaksi.add(data);
    keuanganList.add(TransaksiKeuangan.fromMap(data));

    notifier.value++;
  }

  /// ================= DELETE =================
  static Future<void> delete(int index) async {
    if (index >= 0 && index < transaksi.length) {
      await _supabase
          .from('transaksi_keuangan')
          .delete()
          .eq('id', transaksi[index]['id']);

      transaksi.removeAt(index);
      keuanganList.removeAt(index);

      notifier.value++;
    }
  }

  /// ================= CLEAR =================
  static void clear() {
    transaksi.clear();
    keuanganList.clear();
    notifier.value++;
  }

  static int totalMasukBulanIni() {
    final now = DateTime.now();

    return keuanganList
        .where((k) => k.tgl.month == now.month && k.tgl.year == now.year)
        .fold(0, (sum, k) => sum + k.masuk);
  }

  static int totalKeluarBulanIni() {
    final now = DateTime.now();

    return keuanganList
        .where((k) => k.tgl.month == now.month && k.tgl.year == now.year)
        .fold(0, (sum, k) => sum + k.keluar);
  }

  static List<TransaksiKeuangan> bulanIni() {
    final now = DateTime.now();
    return keuanganList
        .where((k) => k.tgl.month == now.month && k.tgl.year == now.year)
        .toList();
  }
}
