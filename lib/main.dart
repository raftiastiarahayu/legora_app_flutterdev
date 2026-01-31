import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/theme/sutura_theme.dart';
import 'modules/splashscreen/splashcreen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://hmomuimhpfkdtnokjtub.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imhtb211aW1ocGZrZHRub2tqdHViIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Njk3NzEyNDYsImV4cCI6MjA4NTM0NzI0Nn0.hRFm7WH22O0L5OUzyOGw4AN31QVJ8390X2Dng0TJznI',
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 800),
      builder: (_, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: SuturaTheme.light(),
          home: const SplashPage(),
        );
      },
    );
  }
}
