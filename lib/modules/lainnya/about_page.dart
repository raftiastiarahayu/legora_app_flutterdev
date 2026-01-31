import 'package:flutter/material.dart';
import '../../core/theme/sutura_text.dart';
import '../../core/widgets/sutura_card.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("About")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SuturaCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Sutura App", style: SuturaText.title),
              const SizedBox(height: 8),
              Text("Versi 1.0.0", style: SuturaText.subtitle),
              const SizedBox(height: 16),
              Text(
                "Sutura App adalah aplikasi manajemen usaha jahit "
                "yang membantu mencatat pesanan, pelanggan, dan keuangan.",
                style: SuturaText.body,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
