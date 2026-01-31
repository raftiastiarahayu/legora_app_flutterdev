import 'package:supabase_flutter/supabase_flutter.dart';
import 'models/jenis_jasa_model.dart';

class MasterDataRepository {
  static final SupabaseClient _supabase = Supabase.instance.client;

  /// cache global (dipakai semua page)
  static final List<JenisJasa> jenisJasaList = [];

  /// CLEAR cache global
  static void clear() {
    jenisJasaList.clear();
  }

  /// FETCH dari Supabase (optional)
  static Future<void> fetchJenisJasa() async {
    final res = await _supabase.from('jenis_jasa').select();
    jenisJasaList
      ..clear()
      ..addAll(
        (res as List).map(
          (e) => JenisJasa(
            nama: e['nama'],
            ukuran: List<String>.from(e['ukuran']),
          ),
        ),
      );
  }

  /// INSERT ke Supabase (optional)
  static Future<void> insertJenisJasa(JenisJasa data) async {
    await _supabase.from('jenis_jasa').insert({
      'nama': data.nama,
      'ukuran': data.ukuran,
    });
    jenisJasaList.add(data); // update cache lokal
  }

  /// UPDATE Supabase (optional)
  static Future<void> updateJenisJasa(String oldNama, JenisJasa data) async {
    await _supabase
        .from('jenis_jasa')
        .update({'nama': data.nama, 'ukuran': data.ukuran})
        .eq('nama', oldNama);

    final idx = jenisJasaList.indexWhere((e) => e.nama == oldNama);
    if (idx != -1) jenisJasaList[idx] = data; // update cache
  }

  /// DELETE Supabase (optional)
  static Future<void> deleteJenisJasa(String nama) async {
    await _supabase.from('jenis_jasa').delete().eq('nama', nama);
    jenisJasaList.removeWhere((e) => e.nama == nama); // update cache
  }
}
