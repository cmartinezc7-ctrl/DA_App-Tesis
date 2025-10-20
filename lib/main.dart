import 'package:flutter/material.dart';
import 'app_theme.dart';
import 'screens/splash_view.dart';
import 'screens/login_view.dart';
import 'screens/home_view.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized(); //Inicializar app
  runApp(const DASelfAssessmentApp()); //Ejecutar app
}

class DASelfAssessmentApp extends StatelessWidget {
  const DASelfAssessmentApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Analisis de Datos',
      theme: buildTheme(),
      debugShowCheckedModeBanner: false,
      initialRoute: SplashView.route,
      routes: {
        SplashView.route: (_) => const SplashView(),
        LoginView.route : (_) => const LoginView(),
        HomeView.route  : (_) => const HomeView(),
      },
    );
  }
}
