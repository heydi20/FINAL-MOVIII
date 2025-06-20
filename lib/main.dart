import 'package:flixly/auth/LoginScreen.dart';
import 'package:flixly/auth/RegisterScreen.dart';
import 'package:flixly/navigation/Drawer.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';



Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://smvgtvblaflvfbzcmngk.supabase.co',     
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNtdmd0dmJsYWZsdmZiemNtbmdrIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDk2NDQzOTgsImV4cCI6MjA2NTIyMDM5OH0.GQHAPqGZLKGel2ux8DzUiMRSW7W_atSoD46pwxNYEsU',                
  );

  runApp(const ProyectoF());
}

class ProyectoF extends StatelessWidget {
  const ProyectoF({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Cuerpo(),
    );
  }
}

class Cuerpo extends StatefulWidget {
  const Cuerpo({super.key});

  @override
  State<Cuerpo> createState() => _CuerpoState();
}

class _CuerpoState extends State<Cuerpo> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _logoController;
  
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _logoAnimation;

  final Color _backgroundColor = const Color(0xFF0A0A0A);
  final Color _primaryPurple = const Color(0xFF6C63FF);
  final Color _secondaryPurple = const Color(0xFF9D50BB);
  final Color _accentColor = const Color(0xFFFF6B9D);

  @override
  void initState() {
    super.initState();
    
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.elasticOut));
    
    _logoAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.bounceOut),
    );
    
    // Iniciar animaciones
    _logoController.forward();
    Future.delayed(const Duration(milliseconds: 300), () {
      _fadeController.forward();
    });
    Future.delayed(const Duration(milliseconds: 600), () {
      _slideController.forward();
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _logoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        title: ShaderMask(
          shaderCallback: (bounds) => LinearGradient(
            colors: [_primaryPurple, _accentColor],
          ).createShader(bounds),
          child: const Text(
            'Flixly',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.5,
              fontSize: 20,
            ),
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                _backgroundColor,
                _primaryPurple.withOpacity(0.1),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      drawer: const MiDrawer(),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: const Alignment(0, -0.3),
            radius: 1.5,
            colors: [
              _primaryPurple.withOpacity(0.15),
              _secondaryPurple.withOpacity(0.08),
              _backgroundColor,
              _backgroundColor,
            ],
          ),
        ),
        child: Stack(
          children: [
            // Elementos decorativos animados
            _buildFloatingElements(),
            
            // Contenido principal
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 20),
                    
                    // Logo con animación
                    ScaleTransition(
                      scale: _logoAnimation,
                      child: _buildAnimatedLogo(),
                    ),
                    
                    const SizedBox(height: 40),
                    
                    // Título principal con animación
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: SlideTransition(
                        position: _slideAnimation,
                        child: _buildWelcomeTitle(),
                      ),
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Subtítulo con efectos
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: _buildSubtitle(),
                    ),
                    
                    const SizedBox(height: 30),
                    
                    // Tarjetas de características
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: _buildFeatureCards(),
                    ),
                    
                    const SizedBox(height: 40),
                    
                    // Botones mejorados
                    SlideTransition(
                      position: _slideAnimation,
                      child: Column(
                        children: [
                          _buildGlowingButton(
                            context,
                            icon: Icons.play_circle_fill_rounded,
                            label: 'Iniciar Sesión',
                            onPressed: () {
                              Navigator.push(
                                context,
                                PageRouteBuilder(
                                  pageBuilder: (context, animation, secondaryAnimation) => const Login(),
                                  transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                    return SlideTransition(
                                      position: Tween<Offset>(
                                        begin: const Offset(1.0, 0.0),
                                        end: Offset.zero,
                                      ).animate(animation),
                                      child: child,
                                    );
                                  },
                                ),
                              );
                            },
                            gradient: LinearGradient(
                              colors: [_primaryPurple, _secondaryPurple],
                            ),
                            isPrimary: true,
                          ),
                          
                          const SizedBox(height: 16),
                          
                          _buildGlowingButton(
                            context,
                            icon: Icons.person_add_alt_1_rounded,
                            label: 'Crear Cuenta',
                            onPressed: () {
                              Navigator.push(
                                context,
                                PageRouteBuilder(
                                  pageBuilder: (context, animation, secondaryAnimation) => const Registro(),
                                  transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                    return SlideTransition(
                                      position: Tween<Offset>(
                                        begin: const Offset(-1.0, 0.0),
                                        end: Offset.zero,
                                      ).animate(animation),
                                      child: child,
                                    );
                                  },
                                ),
                              );
                            },
                            gradient: LinearGradient(
                              colors: [_accentColor, _secondaryPurple],
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 30),
                    
                    // Footer decorativo
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: _buildFooter(),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingElements() {
    return Stack(
      children: [
        // Círculos flotantes animados
        TweenAnimationBuilder(
          duration: const Duration(seconds: 4),
          tween: Tween<double>(begin: 0, end: 1),
          builder: (context, value, child) {
            return Positioned(
              top: 80 + (20 * value),
              right: -30 + (15 * value),
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      _primaryPurple.withOpacity(0.2),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            );
          },
        ),
        
        TweenAnimationBuilder(
          duration: const Duration(seconds: 5),
          tween: Tween<double>(begin: 0, end: 1),
          builder: (context, value, child) {
            return Positioned(
              bottom: 200 - (25 * value),
              left: -60 + (10 * value),
              child: Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      _accentColor.withOpacity(0.15),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            );
          },
        ),
        
        // Estrellas parpadeantes
        ...List.generate(8, (index) => _buildTwinklingStars(index)),
      ],
    );
  }

  Widget _buildTwinklingStars(int index) {
    return TweenAnimationBuilder(
      duration: Duration(milliseconds: 1500 + (index * 200)),
      tween: Tween<double>(begin: 0, end: 1),
      builder: (context, value, child) {
        return Positioned(
          top: (50 + index * 80).toDouble(),
          left: (30 + index * 45).toDouble(),
          child: Opacity(
            opacity: 0.3 + (0.7 * value),
            child: Icon(
              Icons.star,
              color: _accentColor,
              size: 8 + (index % 3) * 4,
            ),
          ),
        );
      },
    );
  }

  Widget _buildAnimatedLogo() {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: LinearGradient(
          colors: [
            _primaryPurple.withOpacity(0.3),
            _accentColor.withOpacity(0.3),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: _primaryPurple.withOpacity(0.4),
            blurRadius: 30,
            spreadRadius: 5,
          ),
          BoxShadow(
            color: _accentColor.withOpacity(0.3),
            blurRadius: 40,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
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
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Image.asset(
            'assets/logo.jpg',
            width: 100,
            height: 100,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeTitle() {
    return Column(
      children: [
        ShaderMask(
          shaderCallback: (bounds) => LinearGradient(
            colors: [
              _primaryPurple,
              _accentColor,
              Colors.white,
            ],
            stops: const [0.0, 0.6, 1.0],
          ).createShader(bounds),
          child: const Text(
            '¡Bienvenid@ a',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w600,
              color: Colors.white,
              letterSpacing: 1.2,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        ShaderMask(
          shaderCallback: (bounds) => LinearGradient(
            colors: [_accentColor, _primaryPurple],
          ).createShader(bounds),
          child: const Text(
            'Flixly!',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        
        const SizedBox(height: 15),
        
        // Línea decorativa animada
        Container(
          width: 120,
          height: 3,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(2),
            gradient: LinearGradient(
              colors: [_primaryPurple, _accentColor, _primaryPurple],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubtitle() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10),
      child: Text(
        'Descubre un mundo infinito de entretenimiento.\nPelículas de todos los géneros te esperan.',
        style: TextStyle(
          fontSize: 16,
          color: Colors.grey[300],
          height: 1.6,
          fontWeight: FontWeight.w400,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildFeatureCards() {
    return Row(
      children: [
        Expanded(
          child: _buildFeatureCard(
            icon: Icons.movie_filter_rounded,
            title: 'HD Quality',
            description: 'Calidad premium',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildFeatureCard(
            icon: Icons.devices_rounded,
            title: 'Multi-Device',
            description: 'Todos tus dispositivos',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildFeatureCard(
            icon: Icons.favorite_rounded,
            title: 'Favorites',
            description: 'Tus favoritas',
          ),
        ),
      ],
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.08),
            Colors.white.withOpacity(0.03),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [_primaryPurple.withOpacity(0.3), _accentColor.withOpacity(0.3)],
              ),
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            description,
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 10,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildGlowingButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    required LinearGradient gradient,
    bool isPrimary = false,
  }) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: gradient,
        boxShadow: [
          BoxShadow(
            color: gradient.colors.first.withOpacity(0.4),
            blurRadius: 20,
            spreadRadius: 1,
            offset: const Offset(0, 8),
          ),
          if (isPrimary)
            BoxShadow(
              color: gradient.colors.first.withOpacity(0.3),
              blurRadius: 30,
              spreadRadius: 3,
              offset: const Offset(0, 12),
            ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(28),
          onTap: onPressed,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  color: Colors.white,
                  size: 22,
                ),
                const SizedBox(width: 12),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    letterSpacing: 0.8,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.security_rounded,
              color: Colors.grey[500],
              size: 16,
            ),
            const SizedBox(width: 8),
            Text(
              'Seguro y confiable',
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 12,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          width: 40,
          height: 2,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(1),
            color: Colors.grey[700],
          ),
        ),
      ],
    );
  }
}