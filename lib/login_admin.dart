import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dashboard_principal.dart';
import 'admin_config.dart';

class LoginAdmin extends StatefulWidget {
  const LoginAdmin({super.key});

  @override
  State<LoginAdmin> createState() => _LoginAdminState();
}

class _LoginAdminState extends State<LoginAdmin> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _auth = FirebaseAuth.instance;
  bool _cargando = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_emailController.text.trim().isEmpty ||
        _passwordController.text.trim().isEmpty) {
      _mostrarError('Por favor completa todos los campos');
      return;
    }

    setState(() => _cargando = true);
    try {
      final emailIngresado = _emailController.text.trim();
      if (!AdminConfig.esAdmin(emailIngresado)) {
        throw FirebaseAuthException(
            code: 'not-admin',
            message:
                'Acceso denegado: Este correo no tiene permisos de administrador.');
      }

      await _auth.signInWithEmailAndPassword(
        email: emailIngresado,
        password: _passwordController.text.trim(),
      );

      final user = _auth.currentUser;
      if (user != null && !AdminConfig.esAdmin(user.email)) {
        await _auth.signOut();
        throw FirebaseAuthException(
            code: 'not-admin',
            message:
                'Acceso revocado: Usuario sin privilegios de administrador.');
      }

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const DashboardPrincipal()),
        );
      }
    } on FirebaseAuthException catch (e) {
      String mensaje;
      switch (e.code) {
        case 'not-admin':
          mensaje = e.message ?? 'Acceso denegado';
          break;
        case 'user-not-found':
          mensaje = 'Usuario no encontrado';
          break;
        case 'wrong-password':
          mensaje = 'Contraseña incorrecta';
          break;
        case 'invalid-email':
          mensaje = 'Email inválido';
          break;
        case 'invalid-credential':
          mensaje = 'Credenciales inválidas';
          break;
        default:
          mensaje = 'Error: ${e.message}';
      }
      _mostrarError(mensaje);
    } catch (e) {
      _mostrarError('Error inesperado: $e');
    } finally {
      if (mounted) {
        setState(() => _cargando = false);
      }
    }
  }

  void _mostrarError(String mensaje) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje, style: GoogleFonts.inter(color: Colors.white)),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width > 800;

    return Scaffold(
      body: Row(
        children: [
          if (isDesktop)
            Expanded(
              flex: 5,
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF0f172a), Color(0xFF1e293b)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset('assets/imagen/taxi_2.png',
                          width: 300, height: 300),
                      const SizedBox(height: 20),
                      Text(
                        'Click Admin Panel',
                        style: GoogleFonts.outfit(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Gestión centralizada de CLICK EXPRESS',
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          Expanded(
            flex: 4,
            child: Container(
              color:
                  isDesktop ? const Color(0xFF1e293b) : const Color(0xFF0f172a),
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 450),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (!isDesktop) ...[
                          Icon(Icons.local_taxi,
                              size: 80,
                              color: Theme.of(context).colorScheme.primary),
                          const SizedBox(height: 20),
                        ],
                        Text(
                          'Bienvenido de nuevo',
                          style: GoogleFonts.outfit(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Inicia sesión para continuar al panel',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            color: Colors.white54,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 48),
                        TextField(
                          controller: _emailController,
                          style: GoogleFonts.inter(color: Colors.white),
                          decoration: InputDecoration(
                            labelText: 'Correo Institucional',
                            labelStyle:
                                GoogleFonts.inter(color: Colors.white54),
                            prefixIcon: const Icon(Icons.email_outlined,
                                color: Colors.white54),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(
                                  color: Colors.white.withValues(alpha: 0.1)),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(
                                  color: Colors.white.withValues(alpha: 0.1)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(
                                  color: Theme.of(context).colorScheme.primary),
                            ),
                            filled: true,
                            fillColor: const Color(0xFF0f172a),
                          ),
                          keyboardType: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: 20),
                        TextField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          style: GoogleFonts.inter(color: Colors.white),
                          decoration: InputDecoration(
                            labelText: 'Contraseña',
                            labelStyle:
                                GoogleFonts.inter(color: Colors.white54),
                            prefixIcon: const Icon(Icons.lock_outline,
                                color: Colors.white54),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                                color: Colors.white54,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(
                                  color: Colors.white.withValues(alpha: 0.1)),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(
                                  color: Colors.white.withValues(alpha: 0.1)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(
                                  color: Theme.of(context).colorScheme.primary),
                            ),
                            filled: true,
                            fillColor: const Color(0xFF0f172a),
                          ),
                          onSubmitted: (_) => _login(),
                        ),
                        const SizedBox(height: 40),
                        ElevatedButton(
                          onPressed: _cargando ? null : _login,
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                Theme.of(context).colorScheme.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 0,
                          ),
                          child: _cargando
                              ? const SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: CircularProgressIndicator(
                                      color: Colors.white, strokeWidth: 2),
                                )
                              : Text(
                                  'Ingresar al panel',
                                  style: GoogleFonts.inter(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
