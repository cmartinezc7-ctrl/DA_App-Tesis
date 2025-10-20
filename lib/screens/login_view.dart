import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../app_theme.dart';
import 'home_view.dart';

class LoginView extends StatefulWidget {
  static const route = '/login';
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _formKey = GlobalKey<FormState>();
  final _userCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscure = true;
  bool _loading = false;

  @override
  void dispose() {
    _userCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _fakeLogin() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    // Simulamos un "login" y guardamos estado local
    final prefs = await SharedPreferences.getInstance();
    await Future.delayed(const Duration(milliseconds: 700));
    await prefs.setBool('loggedIn', true);

    if (!mounted) return;
    Navigator.pushReplacementNamed(context, HomeView.route);
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  Image.asset('assets/logo.png', width: 150),

                  // Card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(.95),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(.15),
                          blurRadius: 18, offset: const Offset(0, 12),
                        )
                      ],
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          TextFormField(
                            controller: _userCtrl,
                            textInputAction: TextInputAction.next,
                            decoration: const InputDecoration(
                              prefixIcon: Icon(Icons.person_outline),
                              hintText: 'Usuario',
                            ),
                            validator: (v) =>
                            (v == null || v.trim().isEmpty) ? 'Ingresa tu usuario' : null,
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _passCtrl,
                            obscureText: _obscure,
                            decoration: InputDecoration(
                              prefixIcon: const Icon(Icons.lock_outline),
                              hintText: 'Contraseña',
                              suffixIcon: IconButton(
                                icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility),
                                onPressed: () => setState(() => _obscure = !_obscure),
                              ),
                            ),
                            validator: (v) =>
                            (v == null || v.isEmpty) ? 'Ingresa tu contraseña' : null,
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _loading ? null : _fakeLogin,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.accentYellow,
                                foregroundColor: Colors.black87,
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 6),
                                child: _loading
                                    ? const SizedBox(
                                  height: 22, width: 22,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                                    : const Text('Ingresar',
                                    style: TextStyle(fontWeight: FontWeight.w700)),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text('Otras opciones de inicio de sesión',
                              style: textTheme.bodySmall?.copyWith(color: Colors.black54)),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () {}, // placeholder
                                  icon: const FaIcon(FontAwesomeIcons.facebookF, size: 18),
                                  label: const Text('Facebook'),
                                  style: OutlinedButton.styleFrom(
                                    minimumSize: const Size.fromHeight(48),
                                    foregroundColor: const Color(0xFF1877F2),
                                    side: const BorderSide(color: Color(0xFFE0E3EB)),
                                    backgroundColor: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () {}, // placeholder
                                  icon: const FaIcon(FontAwesomeIcons.google, size: 18),
                                  label: const Text('Google'),
                                  style: OutlinedButton.styleFrom(
                                    minimumSize: const Size.fromHeight(48),
                                    foregroundColor: const Color(0xFFDB4437),
                                    side: const BorderSide(color: Color(0xFFE0E3EB)),
                                    backgroundColor: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),
                  Text(
                    'Prototipo — la autenticación real se implementará después.',
                    textAlign: TextAlign.center,
                    style: textTheme.bodySmall?.copyWith(color: Colors.white70),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
