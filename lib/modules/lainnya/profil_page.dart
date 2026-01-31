import 'package:flutter/material.dart';
import '../../core/theme/sutura_text.dart';
import '../../core/widgets/sutura_card.dart';
import '../../core/widgets/sutura_button.dart';
import '../../data/profile_repository.dart';
import '../../data/models/profile_model.dart';

class ProfilPage extends StatefulWidget {
  const ProfilPage({super.key});

  @override
  State<ProfilPage> createState() => _ProfilPageState();
}

class _ProfilPageState extends State<ProfilPage> {
  final _namaCtrl = TextEditingController();
  final _usahaCtrl = TextEditingController();
  final _usernameCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    ProfileRepository.fetch();
  }

  void _isiController(Profile p) {
    _namaCtrl.text = p.namaLengkap;
    _usahaCtrl.text = p.namaUsaha;
    _usernameCtrl.text = p.username;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Profil")),
      body: ValueListenableBuilder<Profile?>(
        valueListenable: ProfileRepository.notifier,
        builder: (context, profile, _) {
          if (profile == null) {
            return const Center(child: CircularProgressIndicator());
          }

          _isiController(profile);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                /// FOTO
                CircleAvatar(
                  radius: 48,
                  backgroundColor: Colors.grey.shade300,
                  child: const Icon(Icons.person, size: 48),
                ),
                const SizedBox(height: 12),
                Text(profile.namaLengkap, style: SuturaText.title),
                Text(profile.email, style: SuturaText.subtitle),

                const SizedBox(height: 24),

                /// FORM
                SuturaCard(
                  child: Column(
                    children: [
                      TextField(
                        controller: _namaCtrl,
                        decoration: const InputDecoration(
                          labelText: "Nama Lengkap",
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _usahaCtrl,
                        decoration: const InputDecoration(
                          labelText: "Nama Usaha",
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _usernameCtrl,
                        decoration: const InputDecoration(
                          labelText: "Username",
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                SuturaButton(
                  text: "Simpan Perubahan",
                  onPressed: () async {
                    final updated = Profile(
                      id: profile.id,
                      email: profile.email,
                      namaLengkap: _namaCtrl.text,
                      namaUsaha: _usahaCtrl.text,
                      username: _usernameCtrl.text,
                    );

                    await ProfileRepository.update(updated);

                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Profil berhasil disimpan")),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
