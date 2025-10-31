import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../app_theme.dart';
import 'login_view.dart';
import 'home_view.dart';

class SplashView extends StatefulWidget {
  static const route = '/';
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeScale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..forward();

    _fadeScale = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutExpo,
    );

    _boot();
  }

  Future<void> _boot() async {
    await Future.delayed(const Duration(seconds: 2)); // ⏳ tiempo del splash

    final user = FirebaseAuth.instance.currentUser;

    if (!mounted) return;
    Navigator.pushReplacementNamed(
      context,
      user != null ? HomeView.route : LoginView.route,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF5A55AE),
              Color(0xFF7B5FC3),
              Color(0xFF9D8BE3),
            ],
          ),
        ),
        child: Center(
          child: ScaleTransition(
            scale: _fadeScale,
            child: FadeTransition(
              opacity: _fadeScale,
              child: Text(
                'DataQuest',
                style: Theme.of(context).textTheme.displayMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
