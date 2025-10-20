import 'dart:async'; //metodo asincrono para ejecutar el splash
import 'package:flutter/material.dart'; //material design
import 'package:shared_preferences/shared_preferences.dart'; //almacenamiento local
import '../app_theme.dart'; //colores
import 'login_view.dart'; //inicio de sesion
import 'home_view.dart'; //pantalla principal

class SplashView extends StatefulWidget {
  static const route = '/';
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  @override
  void initState() {
    super.initState();
    _boot();
  }

  Future<void> _boot() async {
    // Le damos un tiempito para que el splash nativo transicione suave
    await Future.delayed(const Duration(milliseconds: 900));

    final prefs = await SharedPreferences.getInstance();
    final loggedIn = prefs.getBool('loggedIn') ?? false;

    if (!mounted) return;
    Navigator.pushReplacementNamed(
      context, loggedIn ? HomeView.route : LoginView.route,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset('assets/logo.png', width: 120),
                const SizedBox(height: 16),
                Text(
                  'APP ANALISIS DE DATOS',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withOpacity(.9),
                    letterSpacing: 1.1,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
