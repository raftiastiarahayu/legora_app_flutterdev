import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'models/profile_model.dart';

class ProfileRepository {
  static final _supabase = Supabase.instance.client;

  static final ValueNotifier<Profile?> notifier = ValueNotifier<Profile?>(null);

  static Future<void> fetch() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    final res = await _supabase
        .from('profiles')
        .select()
        .eq('id', user.id)
        .single();

    notifier.value = Profile.fromMap(res);
  }

  static Future<void> update(Profile profile) async {
    await _supabase
        .from('profiles')
        .update(profile.toMap())
        .eq('id', profile.id);

    notifier.value = profile;
  }

  static void clear() {
    notifier.value = null;
  }
}
