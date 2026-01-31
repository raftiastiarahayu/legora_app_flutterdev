import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'models/pelanggan_model.dart';

class PelangganRepository {
  static final SupabaseClient _supabase = Supabase.instance.client;

  /// 🔥 NOTIFIER (dipakai semua module)
  static final ValueNotifier<List<Pelanggan>> notifier =
      ValueNotifier<List<Pelanggan>>([]);

  /// 🔥 CACHE LOKAL (OFFLINE-FIRST)
  static final List<Pelanggan> pelangganList = [];

  /// 🔥 Wajib dipanggil setiap data berubah
  static void notify() {
    notifier.value = List.from(pelangganList);
  }

  /// 🔥 SAFE UPDATE (dipakai dialog edit)
  static Future<void> update(Pelanggan pelanggan) async {
    try {
      // 1️⃣ Ambil pelanggan_id
      final pelangganRes = await _supabase
          .from('pelanggan')
          .select('id')
          .eq('nama', pelanggan.nama)
          .eq('no_telp', pelanggan.noTelp)
          .single();

      final pelangganId = pelangganRes['id'];

      // 2️⃣ Loop semua ukuran
      for (final u in pelanggan.ukuranList) {
        // ambil ukuran_pelanggan_id
        final ukuranRes = await _supabase
            .from('ukuran_pelanggan')
            .select('id, jenis_jasa!inner(nama)')
            .eq('pelanggan_id', pelangganId)
            .eq('jenis_jasa.nama', u.jenis)
            .single();

        final ukuranPelangganId = ukuranRes['id'];

        // 3️⃣ Update tiap detail ukuran
        for (final entry in u.ukuran.entries) {
          await _supabase
              .from('detail_ukuran_pelanggan')
              .update({'nilai': entry.value})
              .eq('ukuran_pelanggan_id', ukuranPelangganId)
              .eq('nama_ukuran', entry.key);
        }
      }

      // 4️⃣ Refresh UI lokal
      notify();
    } catch (e) {
      debugPrint('❌ Update pelanggan gagal: $e');
      notify(); // fallback ke cache lokal
    }
  }

  /// =========================================================
  /// 🔥 FETCH DARI SUPABASE (HYBRID – ANTI CRASH)
  /// =========================================================
  static Future<void> fetchFromSupabase() async {
    try {
      final res = await _supabase.from('pelanggan').select('''
        id,
        nama,
        no_telp,
        ukuran_pelanggan (
          id,
          jenis_jasa (
            nama
          ),
          detail_ukuran_pelanggan (
            nama_ukuran,
            nilai
          )
        )
      ''');

      pelangganList.clear();

      for (final p in res as List) {
        final List<UkuranPelanggan> ukuranList = [];

        for (final u in (p['ukuran_pelanggan'] as List? ?? [])) {
          final Map<String, double> ukuranMap = {};

          for (final d in (u['detail_ukuran_pelanggan'] as List? ?? [])) {
            ukuranMap[d['nama_ukuran']] = (d['nilai'] as num).toDouble();
          }

          ukuranList.add(
            UkuranPelanggan(jenis: u['jenis_jasa']['nama'], ukuran: ukuranMap),
          );
        }

        pelangganList.add(
          Pelanggan(
            nama: p['nama'],
            noTelp: p['no_telp'],
            ukuranList: ukuranList,
          ),
        );
      }

      notify();
    } catch (e) {
      debugPrint('❌ Fetch pelanggan gagal: $e');
      notify(); // fallback ke data lokal
    }
  }

  /// =========================================================
  /// 🔥 INSERT PELANGGAN + UKURAN (AMAN)
  /// =========================================================
  static Future<void> insertPelanggan(Pelanggan p) async {
    try {
      final pelangganRes = await _supabase
          .from('pelanggan')
          .insert({'nama': p.nama, 'no_telp': p.noTelp})
          .select()
          .single();

      final pelangganId = pelangganRes['id'];

      for (final u in p.ukuranList) {
        final jenis = await _supabase
            .from('jenis_jasa')
            .select('id')
            .eq('nama', u.jenis)
            .single();

        final ukuranRes = await _supabase
            .from('ukuran_pelanggan')
            .insert({'pelanggan_id': pelangganId, 'jenis_jasa_id': jenis['id']})
            .select()
            .single();

        for (final entry in u.ukuran.entries) {
          await _supabase.from('detail_ukuran_pelanggan').insert({
            'ukuran_pelanggan_id': ukuranRes['id'],
            'nama_ukuran': entry.key,
            'nilai': entry.value,
          });
        }
      }

      pelangganList.add(p); // update cache
      notify();
    } catch (e) {
      debugPrint('❌ Insert pelanggan gagal: $e');
    }
  }

  static Future<void> deletePelanggan(Pelanggan pelanggan) async {
    try {
      // 1️⃣ Cari ID pelanggan di Supabase
      final res = await _supabase
          .from('pelanggan')
          .select('id')
          .eq('nama', pelanggan.nama)
          .eq('no_telp', pelanggan.noTelp)
          .single();

      final pelangganId = res['id'];

      // 2️⃣ Hapus pelanggan
      // ukuran_pelanggan & detail_ukuran_pelanggan
      // akan TERHAPUS otomatis (ON DELETE CASCADE)
      await _supabase.from('pelanggan').delete().eq('id', pelangganId);

      // 3️⃣ Hapus dari cache lokal
      pelangganList.removeWhere(
        (p) => p.nama == pelanggan.nama && p.noTelp == pelanggan.noTelp,
      );

      notify(); // 🔥 update UI
    } catch (e) {
      debugPrint('❌ Gagal hapus pelanggan: $e');
    }
  }

  static Future<void> addUkuranToPelanggan({
    required Pelanggan pelanggan,
    required UkuranPelanggan ukuranBaru,
  }) async {
    try {
      // 1️⃣ Ambil pelanggan_id
      final pelangganRes = await _supabase
          .from('pelanggan')
          .select('id')
          .eq('nama', pelanggan.nama)
          .eq('no_telp', pelanggan.noTelp)
          .single();

      final pelangganId = pelangganRes['id'];

      // 2️⃣ Ambil jenis_jasa_id dari master
      final jenisRes = await _supabase
          .from('jenis_jasa')
          .select('id')
          .eq('nama', ukuranBaru.jenis)
          .single();

      final jenisJasaId = jenisRes['id'];

      // 3️⃣ Insert ke ukuran_pelanggan
      final ukuranPelangganRes = await _supabase
          .from('ukuran_pelanggan')
          .insert({'pelanggan_id': pelangganId, 'jenis_jasa_id': jenisJasaId})
          .select()
          .single();

      final ukuranPelangganId = ukuranPelangganRes['id'];

      // 4️⃣ Insert detail ukuran
      for (final entry in ukuranBaru.ukuran.entries) {
        await _supabase.from('detail_ukuran_pelanggan').insert({
          'ukuran_pelanggan_id': ukuranPelangganId,
          'nama_ukuran': entry.key,
          'nilai': entry.value,
        });
      }

      // 5️⃣ Update cache lokal (INI PENTING)
      pelanggan.ukuranList.add(ukuranBaru);
      notify();
    } catch (e) {
      debugPrint('❌ Gagal tambah ukuran: $e');
    }
  }

  static Future<void> updatePelangganSupabase({
    required Pelanggan oldData,
    required Pelanggan newData,
  }) async {
    try {
      // 1️⃣ Cari pelanggan_id
      final res = await _supabase
          .from('pelanggan')
          .select('id')
          .eq('nama', oldData.nama)
          .eq('no_telp', oldData.noTelp)
          .single();

      final pelangganId = res['id'];

      // 2️⃣ Update tabel pelanggan
      await _supabase
          .from('pelanggan')
          .update({'nama': newData.nama, 'no_telp': newData.noTelp})
          .eq('id', pelangganId);

      // 3️⃣ Update cache lokal
      final idx = pelangganList.indexWhere(
        (p) => p.nama == oldData.nama && p.noTelp == oldData.noTelp,
      );

      if (idx != -1) {
        pelangganList[idx] = newData;
      }

      notify();
    } catch (e) {
      debugPrint('❌ Gagal update pelanggan: $e');
    }
  }

  static Future<void> updateUkuranSupabase({
    required Pelanggan pelanggan,
    required UkuranPelanggan ukuran,
  }) async {
    try {
      // 1️⃣ Ambil pelanggan_id
      final pelangganRes = await _supabase
          .from('pelanggan')
          .select('id')
          .eq('nama', pelanggan.nama)
          .eq('no_telp', pelanggan.noTelp)
          .single();

      final pelangganId = pelangganRes['id'];

      // 2️⃣ Ambil ukuran_pelanggan_id
      final ukuranRes = await _supabase
          .from('ukuran_pelanggan')
          .select('id, jenis_jasa!inner(nama)')
          .eq('pelanggan_id', pelangganId)
          .eq('jenis_jasa.nama', ukuran.jenis)
          .single();

      final ukuranPelangganId = ukuranRes['id'];

      // 3️⃣ Update semua detail ukuran
      for (final entry in ukuran.ukuran.entries) {
        await _supabase
            .from('detail_ukuran_pelanggan')
            .update({'nilai': entry.value})
            .eq('ukuran_pelanggan_id', ukuranPelangganId)
            .eq('nama_ukuran', entry.key);
      }

      // 4️⃣ Refresh cache lokal (BIAR UI LANGSUNG UPDATE)
      notify();
    } catch (e) {
      debugPrint('❌ Gagal update ukuran: $e');
    }
  }
}
