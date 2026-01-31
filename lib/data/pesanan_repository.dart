import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'models/pesanan_model.dart';

class PesananRepository {
  static final SupabaseClient _supabase = Supabase.instance.client;

  static final List<Pesanan> _pesanan = [];
  static final ValueNotifier<int> notifier = ValueNotifier(0);

  static List<Pesanan> get jahit =>
      _pesanan.where((e) => e.jenis == JenisPesanan.jahit).toList();

  static List<Pesanan> get permak =>
      _pesanan.where((e) => e.jenis == JenisPesanan.permak).toList();

  /// =============================
  /// FETCH
  /// =============================
  static Future<void> fetchPesanan() async {
    final res = await _supabase.from('pesanan').select().order('id');

    _pesanan
      ..clear()
      ..addAll(
        (res as List).map(
          (e) => Pesanan(
            id: e['id'],
            nama: e['nama'] ?? '',
            catatan: e['catatan'] ?? '',
            deadline: DateTime.parse(e['deadline']),
            jenis: e['jenis'] == 'jahit'
                ? JenisPesanan.jahit
                : JenisPesanan.permak,
            ukuran: e['ukuran'],
            fotoPath: e['foto_path'],
            harga: e['harga'],
            tanggalSelesai: e['tanggal_selesai'] != null
                ? DateTime.parse(e['tanggal_selesai'])
                : null,
            status: e['status'] == 'selesai'
                ? StatusPesanan.selesai
                : StatusPesanan.proses,
          ),
        ),
      );

    notifier.value++;
  }

  /// =============================
  /// ADD
  /// =============================
  static Future<void> add(Pesanan p) async {
    final res = await _supabase
        .from('pesanan')
        .insert({
          'nama': p.nama,
          'catatan': p.catatan,
          'deadline': p.deadline.toIso8601String(),
          'jenis': p.jenis == JenisPesanan.jahit ? 'jahit' : 'permak',
          'ukuran': p.ukuran,
          'foto_path': p.fotoPath,
          'harga': p.harga,
          'tanggal_selesai': p.tanggalSelesai?.toIso8601String(),
          'status': p.status == StatusPesanan.selesai ? 'selesai' : 'proses',
        })
        .select()
        .single();

    _pesanan.add(
      Pesanan(
        id: res['id'],
        nama: p.nama,
        catatan: p.catatan,
        deadline: p.deadline,
        jenis: p.jenis,
        ukuran: p.ukuran,
        fotoPath: p.fotoPath,
        harga: p.harga,
        tanggalSelesai: p.tanggalSelesai,
        status: p.status,
      ),
    );

    notifier.value++;
  }

  /// =============================
  /// UPDATE (PAKAI ID)
  /// =============================
  static Future<void> update(Pesanan newP) async {
    if (newP.id == null) return;

    await _supabase
        .from('pesanan')
        .update({
          'nama': newP.nama,
          'catatan': newP.catatan,
          'deadline': newP.deadline.toIso8601String(),
          'jenis': newP.jenis == JenisPesanan.jahit ? 'jahit' : 'permak',
          'ukuran': newP.ukuran,
          'foto_path': newP.fotoPath,
          'harga': newP.harga,
          'tanggal_selesai': newP.tanggalSelesai?.toIso8601String(),
          'status': newP.status == StatusPesanan.selesai ? 'selesai' : 'proses',
        })
        .eq('id', newP.id!);

    final index = _pesanan.indexWhere((e) => e.id == newP.id);
    if (index != -1) _pesanan[index] = newP;

    notifier.value++;
  }

  /// =============================
  /// DELETE (PAKAI ID)
  /// =============================
  static Future<void> delete(Pesanan p) async {
    if (p.id == null) return;

    await _supabase.from('pesanan').delete().eq('id', p.id!);

    _pesanan.removeWhere((e) => e.id == p.id);
    notifier.value++;
  }

  /// =============================
  /// CLEAR
  /// =============================
  static void clear() {
    _pesanan.clear();
    notifier.value++;
  }
}
