import 'package:flixly/screens/CategoriasScreen.dart';
import 'package:flutter/material.dart';

import 'package:supabase_flutter/supabase_flutter.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> with TickerProviderStateMixin {
  final TextEditingController _correo = TextEditingController();
  final TextEditingController _contrasenia = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  
  late AnimationController _animController;
  late AnimationController _fadeController;
  late AnimationController _shimmerController;
  late AnimationController _pulseController;
  
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _shimmerAnimation;
  late Animation<double> _pulseAnimation;
  
  bool _isPasswordVisible = false;
  bool _isLoading = false;
  bool _rememberMe = false;

  // Paleta de colores cinematográfica consistente con registro
  final Color _backgroundColor = const Color(0xFF0A0A0A);
  final Color _primaryPurple = const Color(0xFF6C63FF);
  final Color _secondaryPurple = const Color(0xFF9D50BB);
  final Color _accentColor = const Color(0xFFFF6B9D);
  final Color _cardColor = const Color(0xFF1A1A1A);
  final Color _goldAccent = const Color(0xFFFFD700);

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
      lowerBound: 0.95,
      upperBound: 1.0,
    );

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _scaleAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.elasticOut,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.8),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOutCubic,
    ));

    _shimmerAnimation = Tween<double>(
      begin: -2.0,
      end: 2.0,
    ).animate(CurvedAnimation(
      parent: _shimmerController,
      curve: Curves.easeInOut,
    ));

    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _fadeController.forward();
  }

  @override
  void dispose() {
    _correo.dispose();
    _contrasenia.dispose();
    _animController.dispose();
    _fadeController.dispose();
    _shimmerController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.topCenter,
            radius: 1.5,
            colors: [
              _primaryPurple.withOpacity(0.1),
              _backgroundColor,
              _cardColor,
              _backgroundColor,
            ],
            stops: const [0.0, 0.3, 0.7, 1.0],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    _buildBackButton(),
                    const SizedBox(height: 20),
                    _buildHeader(),
                    const SizedBox(height: 30),
                    Container(
                      margin: const EdgeInsets.all(16),
                      child: _buildForm(size),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBackButton() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(left: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [
              Colors.white.withOpacity(0.1),
              Colors.white.withOpacity(0.05),
            ],
          ),
          border: Border.all(
            color: Colors.white.withOpacity(0.2),
            width: 1,
          ),
        ),
        
      ),
    );
  }



  Widget _buildHeader() {
    return Column(
      children: [
       
        
        // Título con animación shimmer
        AnimatedBuilder(
          animation: _shimmerAnimation,
          builder: (context, child) {
            return ShaderMask(
              shaderCallback: (bounds) {
                return LinearGradient(
                  colors: [
                    Colors.white.withOpacity(0.8),
                    _goldAccent,
                    Colors.white.withOpacity(0.8),
                  ],
                  stops: [
                    (_shimmerAnimation.value - 0.5).clamp(0.0, 1.0),
                    _shimmerAnimation.value.clamp(0.0, 1.0),
                    (_shimmerAnimation.value + 0.5).clamp(0.0, 1.0),
                  ],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ).createShader(bounds);
              },
              child: const Text(
                "¡Bienvenid@ de vuelta!",
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 1.2,
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 8),
        Text(
          "Tu cine personal te ha extrañado 🎬",
          style: TextStyle(
            fontSize: 18,
            color: Colors.grey[300],
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }

  Widget _buildForm(Size size) {
    return Form(
      key: _formKey,
      child: Container(
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              _cardColor.withOpacity(0.9),
              _cardColor.withOpacity(0.7),
            ],
          ),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: _primaryPurple.withOpacity(0.4),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: _primaryPurple.withOpacity(0.2),
              blurRadius: 30,
              spreadRadius: 5,
              offset: const Offset(0, 15),
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 20,
              spreadRadius: 3,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          children: [
            // Campo de correo
            _buildStyledTextField(
              controller: _correo,
              label: "Correo electrónico",
              icon: Icons.email_rounded,
              keyboardType: TextInputType.emailAddress,
              color: _primaryPurple,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor ingresa tu correo';
                }
                if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                  return 'Ingresa un correo válido';
                }
                return null;
              },
            ),
            const SizedBox(height: 25),
            
            // Campo de contraseña
            _buildPasswordField(),
            const SizedBox(height: 20),
            
            // Recordar datos y olvido de contraseña
            _buildRememberAndForgot(),
            const SizedBox(height: 40),
            
            // Botón de login
            _buildLoginButton(size),
            const SizedBox(height: 25),
            
            // Divisor
            _buildDivider(),
            const SizedBox(height: 20),
            
            // Botones sociales
            _buildSocialButtons(),
            const SizedBox(height: 25),
            
            // Enlace de registro
            _buildRegisterLink(),
          ],
        ),
      ),
    );
  }

  Widget _buildStyledTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    required Color color,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _cardColor.withOpacity(0.9),
            _cardColor.withOpacity(0.6),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withOpacity(0.4), width: 2),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 15,
            spreadRadius: 2,
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        validator: validator,
        style: const TextStyle(color: Colors.white, fontSize: 16),
        cursorColor: color,
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
          prefixIcon: Icon(icon, color: color, size: 24),
          labelText: label,
          labelStyle: TextStyle(color: color.withOpacity(0.9), fontSize: 16),
          border: InputBorder.none,
          errorStyle: TextStyle(color: Colors.red[300]),
        ),
      ),
    );
  }

  Widget _buildPasswordField() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _cardColor.withOpacity(0.9),
            _cardColor.withOpacity(0.6),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _secondaryPurple.withOpacity(0.4), width: 2),
        boxShadow: [
          BoxShadow(
            color: _secondaryPurple.withOpacity(0.1),
            blurRadius: 15,
            spreadRadius: 2,
          ),
        ],
      ),
      child: TextFormField(
        controller: _contrasenia,
        obscureText: !_isPasswordVisible,
        style: const TextStyle(color: Colors.white, fontSize: 16),
        cursorColor: _secondaryPurple,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Por favor ingresa tu contraseña';
          }
          if (value.length < 6) {
            return 'La contraseña debe tener al menos 6 caracteres';
          }
          return null;
        },
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),

          prefixIcon: Icon(Icons.lock_rounded, color: _secondaryPurple, size: 24),
          suffixIcon: IconButton(
            icon: Icon(
              _isPasswordVisible ? Icons.visibility_off_rounded : Icons.visibility_rounded,
              color: _secondaryPurple.withOpacity(0.8),
              size: 24,
            ),
            onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
          ),
          labelText: "Contraseña",
          labelStyle: TextStyle(color: _secondaryPurple.withOpacity(0.9), fontSize: 16),
          border: InputBorder.none,
          errorStyle: TextStyle(color: Colors.red[300]),
        ),
      ),
    );
  }

Widget _buildRememberAndForgot() {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Expanded(
        child: Row(
          children: [
            Checkbox(
              value: _rememberMe,
              activeColor: _primaryPurple,
              onChanged: (value) {
                setState(() {
                  _rememberMe = value ?? false;
                });
              },
            ),
            Flexible(
              child: Text(
                "Recordarme",
                style: TextStyle(
                  color: Colors.grey[300],
                  fontSize: 14,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
      TextButton(
        onPressed: () {
          // Acción para recuperar contraseña
        },
        child: Text(
          "¿Olvidaste tu contraseña?",
          style: TextStyle(
            color: _accentColor,
            fontSize: 14,
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ),
    ],
  );
}


  Widget _buildLoginButton(Size size) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Container(
        width: size.width,
        height: 65,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [_primaryPurple, _secondaryPurple, _accentColor],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: _primaryPurple.withOpacity(0.5),
              blurRadius: 25,
              spreadRadius: 3,
              offset: const Offset(0, 10),
            ),
            BoxShadow(
              color: _accentColor.withOpacity(0.3),
              blurRadius: 35,
              spreadRadius: 8,
              offset: const Offset(0, 15),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: _isLoading
              ? null
              : () async {
                  await _animController.forward();
                  await _animController.reverse();
                  _handleLogin();
                },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          child: _isLoading
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 3,
                    ),
                    SizedBox(width: 15),
                    Text(
                      "Ingresando a tu cine...",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.login_rounded, color: Colors.white, size: 28),
                    SizedBox(width: 12),
                    Text(
                      "¡ENTRAR A MI CINE!",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(child: Divider(color: Colors.grey[600], thickness: 1)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'O continúa con',
            style: TextStyle(color: Colors.grey[400], fontSize: 14),
          ),
        ),
        Expanded(child: Divider(color: Colors.grey[600], thickness: 1)),
      ],
    );
  }

  Widget _buildSocialButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildSocialButton(
          icon: Icons.g_mobiledata_rounded,
          label: 'Google',
          gradient: LinearGradient(colors: [Colors.red[400]!, Colors.orange[400]!]),
        ),
        const SizedBox(width: 16),
        _buildSocialButton(
          icon: Icons.facebook_rounded,
          label: 'Facebook',
          gradient: LinearGradient(colors: [Colors.blue[600]!, Colors.blue[800]!]),
        ),
      ],
    );
  }

  Widget _buildSocialButton({
    required IconData icon,
    required String label,
    required LinearGradient gradient,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        gradient: gradient.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: gradient.colors.first.withOpacity(0.4),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: gradient.colors.first, size: 20),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: gradient.colors.first,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRegisterLink() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: _primaryPurple.withOpacity(0.3)),
      ),
      child: TextButton(
        onPressed: () => Navigator.pop(context),
        child: RichText(
          text: TextSpan(
            text: "¿Nuevo en Flixly? ",
            style: TextStyle(
              color: Colors.grey[300],
              fontSize: 16,
            ),
            children: [
              TextSpan(
                text: "¡Únete aquí! 🎭",
                style: TextStyle(
                  color: _primaryPurple,
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  decoration: TextDecoration.underline,
                  decorationColor: _primaryPurple,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);
    
    try {
      await login(_correo.text, _contrasenia.text, context);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showForgotPasswordDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: _cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.help_outline_rounded, color: _primaryPurple, size: 28),
            const SizedBox(width: 12),
            Text(
              'Recuperar Contraseña',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        content: Text(
          'Esta función estará disponible próximamente. Por favor contacta al soporte si necesitas ayuda.',
          style: TextStyle(color: Colors.grey[300], fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [_primaryPurple, _accentColor]),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Entendido',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Future<void> login(String correo, String contrasenia, BuildContext context) async {
  if (correo.isEmpty || contrasenia.isEmpty) {
    _showCustomSnackBar(context, 'Por favor completa todos los campos', isError: true);
    return;
  }

  final supabase = Supabase.instance.client;

  try {
    final AuthResponse res = await supabase.auth.signInWithPassword(
      email: correo,
      password: contrasenia,
    );

    final User? user = res.user;

    if (user != null) {
      _showCustomSnackBar(context, '¡Bienvenid@ de vuelta a tu cine personal! 🎬', isError: false);

     
      int edad = 25; 
      List<String> generosFavoritos = ['Acción', 'Comedia']; 

      await Future.delayed(const Duration(seconds: 2));

  
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => CategoriasScreen(
            edad: edad,
            generosFavoritos: generosFavoritos,
          ),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      );
    } else {
      _showCustomSnackBar(context, 'Error: No se pudo iniciar sesión', isError: true);
    }


    
  } catch (e) {
    String errorMessage = 'Error al iniciar sesión';

    if (e.toString().contains('Invalid login credentials')) {
      errorMessage = 'Credenciales incorrectas. Verifica tu correo y contraseña.';
    } else if (e.toString().contains('Email not confirmed')) {
      errorMessage = 'Por favor confirma tu correo electrónico.';
    }

    _showCustomSnackBar(context, errorMessage, isError: true);
  }
}

void _showCustomSnackBar(BuildContext context, String message, {required bool isError}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isError ? Colors.red.withOpacity(0.2) : Colors.green.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              isError ? Icons.movie_filter : Icons.movie_creation_outlined,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
      backgroundColor: isError ? Colors.red.shade700 : const Color(0xFF6C63FF),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.all(16),
      duration: const Duration(seconds: 4),
    ),
  );
}