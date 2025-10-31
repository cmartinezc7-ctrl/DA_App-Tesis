import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'app_theme.dart';
import 'screens/splash_view.dart';
import 'screens/login_view.dart';
import 'screens/home_view.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const DataQuestApp());
}

class DataQuestApp extends StatelessWidget {
  const DataQuestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DataQuest',
      debugShowCheckedModeBanner: false,
      theme: buildTheme(),
      initialRoute: SplashView.route,
      routes: {
        SplashView.route: (_) => const SplashView(),
        LoginView.route: (_) => const LoginView(),
        HomeView.route: (_) => const HomeView(),
      },
    );
  }
}
