import 'dart:io';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';

class Registro extends StatefulWidget {
  const Registro({super.key});

  @override
  State<Registro> createState() => _RegistroState();
}

class _RegistroState extends State<Registro> with TickerProviderStateMixin {
  final TextEditingController _correo = TextEditingController();
  final TextEditingController _contrasenia = TextEditingController();
  final TextEditingController _nombre = TextEditingController();
  final TextEditingController _edad = TextEditingController();
  final TextEditingController _telefono = TextEditingController();
  String _genero = 'Masculino';
  bool _isLoading = false;
  bool _obscurePassword = true;
  XFile? imagen;

  late AnimationController _animController;
  late AnimationController _fadeController;
  late AnimationController _shimmerController;
  late AnimationController _pulseController;
  
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _shimmerAnimation;
  late Animation<double> _pulseAnimation;

  // Nueva paleta de colores cinematográfica
  final Color _backgroundColor = const Color(0xFF0A0A0A);
  final Color _primaryPurple = const Color(0xFF6C63FF);
  final Color _secondaryPurple = const Color(0xFF9D50BB);
  final Color _accentColor = const Color(0xFFFF6B9D);
  final Color _cardColor = const Color(0xFF1A1A1A);
  final Color _goldAccent = const Color(0xFFFFD700);

  @override
  void initState() {
    super.initState();

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
    _nombre.dispose();
    _edad.dispose();
    _telefono.dispose();
    _animController.dispose();
    _fadeController.dispose();
    _shimmerController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> registrarse() async {
    final correo = _correo.text.trim();
    final contrasenia = _contrasenia.text;

    if (correo.isEmpty || contrasenia.isEmpty || _nombre.text.isEmpty || _edad.text.isEmpty || _telefono.text.isEmpty) {
      if (!mounted) return;
      _showCustomSnackBar('Por favor completa todos los campos', isError: true);
      return;
    }

    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });

    final supabase = Supabase.instance.client;

    try {
      final res = await supabase.auth.signUp(
        email: correo,
        password: contrasenia,
      );

      final user = res.user;

      if (user != null) {
        String? imageUrl;

        if (imagen != null) {
          imageUrl = await subirImagen(imagen!);
        }

        await supabase.from('usuarios').insert({
          'id': user.id,
          'nombre': _nombre.text.trim(),
          'edad': int.tryParse(_edad.text.trim()),
          'telefono': _telefono.text.trim(),
          'genero': _genero,
          'avatar_url': imageUrl,
        });

        if (!mounted) return;
        _showCustomSnackBar('¡Bienvenido a Flixly! 🎬 Tu aventura cinematográfica comienza ahora', isError: false);

        await Future.delayed(const Duration(seconds: 2));
        if (!mounted) return;
        Navigator.pop(context);
      } else {
        if (!mounted) return;
        _showCustomSnackBar('Error: No se pudo completar el registro', isError: true);
      }
    } catch (e) {
      if (!mounted) return;
      _showCustomSnackBar('Error al registrar: $e', isError: true);
    } finally {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showCustomSnackBar(String message, {required bool isError}) {
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
        backgroundColor: isError ? Colors.red.shade700 : _primaryPurple,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  Future<String?> subirImagen(XFile image) async {
    final supabase = Supabase.instance.client;

    try {
      final avatarFile = File(image.path);
      final String fileName = 'avatars/avatar_${DateTime.now().millisecondsSinceEpoch}.png';

      await supabase.storage
          .from('user-images') 
          .upload(fileName, avatarFile);

      final imageUrl = supabase.storage.from('user-images').getPublicUrl(fileName);
      return imageUrl;
    } catch (e) {
      print('Error al subir imagen: $e');
      return null;
    }
  }

  Future<void> seleccionarImagen() async {
    final picker = ImagePicker();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                _cardColor,
                _backgroundColor,
              ],
            ),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
            border: Border.all(color: _primaryPurple.withOpacity(0.3), width: 2),
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 12),
                Container(
                  width: 50,
                  height: 5,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [_primaryPurple, _accentColor]),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                const SizedBox(height: 25),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.movie_outlined, color: _goldAccent, size: 28),
                    const SizedBox(width: 12),
                    const Text(
                      "Agregar foto de perfil",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  "Prepárate para el primer plano",
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 16,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(height: 30),
                _buildImageOption(
                  icon: Icons.photo_library_rounded,
                  title: "Galería de Recuerdos",
                  subtitle: "Selecciona tu mejor toma",
                  gradient: LinearGradient(colors: [_primaryPurple, _secondaryPurple]),
                  onTap: () async {
                    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
                    if (pickedFile != null) {
                      setState(() {
                        imagen = pickedFile;
                      });
                    }
                    Navigator.of(context).pop();
                  },
                ),
                _buildImageOption(
                  icon: Icons.camera_alt_rounded,
                  title: "Cámara",
                  subtitle: "Captura el momento perfecto",
                  gradient: LinearGradient(colors: [_accentColor, _primaryPurple]),
                  onTap: () async {
                    final pickedFile = await picker.pickImage(source: ImageSource.camera);
                    if (pickedFile != null) {
                      setState(() {
                        imagen = pickedFile;
                      });
                    }
                    Navigator.of(context).pop();
                  },
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildImageOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required LinearGradient gradient,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: gradient.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: gradient.colors.first.withOpacity(0.4), width: 2),
              boxShadow: [
                BoxShadow(
                  color: gradient.colors.first.withOpacity(0.2),
                  blurRadius: 15,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: gradient,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: gradient.colors.first.withOpacity(0.4),
                        blurRadius: 10,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: Icon(icon, color: Colors.white, size: 28),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward_ios_rounded, color: gradient.colors.first, size: 20),
              ],
            ),
          ),
        ),
      ),
    );
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

  Widget _buildHeader() {
    return Column(
      children: [
      
        const SizedBox(height: 20),
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
                "¡Únete a Flixly!",
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
          "Tu cine personal te espera 🍿",
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
    return Container(
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
          _buildAvatarSection(),
          const SizedBox(height: 35),
          
          _buildStyledTextField(
            controller: _nombre,
            label: "Nombre de estrella",
            icon: Icons.person_rounded,
            color: _primaryPurple,
            labelColor: Colors.white,
          ),
          const SizedBox(height: 25),
          
          Row(
            children: [
              Expanded(
                child: _buildStyledTextField(
                  controller: _edad,
                  label: "Edad",
                  icon: Icons.cake_rounded,
                  keyboardType: TextInputType.number,
                  color: _secondaryPurple,
                  labelColor: Colors.white,
                ),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: _buildGenderDropdown(),
              ),
            ],
          ),
          const SizedBox(height: 25),
          
          _buildStyledTextField(
            controller: _telefono,
            label: "Teléfono",
            icon: Icons.phone_rounded,
            keyboardType: TextInputType.phone,
            color: _accentColor,
            labelColor: Colors.white,
          ),
          const SizedBox(height: 25),
          
          _buildStyledTextField(
            controller: _correo,
            label: "Email de contacto",
            icon: Icons.email_rounded,
            keyboardType: TextInputType.emailAddress,
            color: _primaryPurple,
             labelColor: Colors.white,
          ),
          const SizedBox(height: 25),
          
          _buildPasswordField(),
          const SizedBox(height: 40),
          
          _buildRegisterButton(size),
          const SizedBox(height: 25),
          
          _buildLoginLink(),
        ],
      ),
    );
  }

  Widget _buildAvatarSection() {
    return Column(
      children: [
        GestureDetector(
          onTap: seleccionarImagen,
          child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: imagen != null ? null : LinearGradient(
                colors: [
                  _primaryPurple.withOpacity(0.3),
                  _accentColor.withOpacity(0.3),
                  _goldAccent.withOpacity(0.2),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border.all(
                color: _primaryPurple,
                width: 4,
              ),
              boxShadow: [
                BoxShadow(
                  color: _primaryPurple.withOpacity(0.4),
                  blurRadius: 20,
                  spreadRadius: 3,
                ),
                BoxShadow(
                  color: _accentColor.withOpacity(0.2),
                  blurRadius: 30,
                  spreadRadius: 8,
                ),
              ],
            ),
            child: imagen != null
                ? ClipOval(
                    child: Image.file(
                      File(imagen!.path),
                      fit: BoxFit.cover,
                      width: 120,
                      height: 120,
                    ),
                  )
                : Icon(
                    Icons.add_a_photo_rounded,
                    size: 45,
                    color: _primaryPurple,
                  ),
          ),
        ),
       
        
      ],
    );
  }
Widget _buildGenderDropdown() {
  return Container(
    width: double.infinity, // Asegura que el dropdown ocupe todo el ancho
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
      border: Border.all(color: _accentColor.withOpacity(0.4), width: 2),
      boxShadow: [
        BoxShadow(
          color: _accentColor.withOpacity(0.1),
          blurRadius: 15,
          spreadRadius: 2,
        ),
      ],
    ),
    child: DropdownButtonFormField<String>(
      isExpanded: true, // ✅ Esta línea evita el overflow
      value: _genero,
      onChanged: (String? newValue) {
        setState(() {
          _genero = newValue!;
        });
      },
      items: <String>['Masculino', 'Femenino', 'Otro']
          .map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(
            value,
            style: const TextStyle(color: Colors.white, fontSize: 16),
          ),
        );
      }).toList(),
      decoration: InputDecoration(
        labelText: 'Género',
        labelStyle: TextStyle(color: _accentColor.withOpacity(0.9), fontSize: 16),
        prefixIcon: Icon(Icons.wc_rounded, color: _accentColor, size: 24),
        border: InputBorder.none,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      ),
      dropdownColor: _cardColor,
      iconEnabledColor: _accentColor,
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
      child: TextField(
        controller: _contrasenia,
        obscureText: _obscurePassword,
        style: const TextStyle(color: Colors.white, fontSize: 16),
        cursorColor: _secondaryPurple,
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
          prefixIcon: Icon(Icons.lock_rounded, color: _secondaryPurple, size: 24),
          suffixIcon: IconButton(
            icon: Icon(
              _obscurePassword ? Icons.visibility_rounded : Icons.visibility_off_rounded,
              color: _secondaryPurple.withOpacity(0.8),
              size: 24,
            ),
            onPressed: () {
              setState(() {
                _obscurePassword = !_obscurePassword;
              });
            },
          ),
          labelText: "Contraseña secreta",
          labelStyle: TextStyle(color: _secondaryPurple.withOpacity(0.9), fontSize: 16),
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildRegisterButton(Size size) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Container(
        width: size.width,
        height: 65,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [_primaryPurple, _secondaryPurple, _accentColor, _goldAccent],
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
                  registrarse();
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
                      "Preparando tu experiencia...",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                )
         :Row(
  mainAxisAlignment: MainAxisAlignment.center,
  children: [
    const Icon(Icons.movie_outlined, color: Colors.white, size: 28),
    const SizedBox(width: 12),
    Flexible(
      child: Text(
        "¡COMENZAR MI AVENTURA!",
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.0,
        ),
      ),
    ),
  ],
)
        )
      ),
    );
  }

  Widget _buildLoginLink() {
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
            text: "¿Ya eres parte de la familia? ",
            style: TextStyle(
              color: Colors.grey[300],
              fontSize: 16,
            ),
            children: [
              TextSpan(
                text: "¡Entra aquí! 🎭",
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
Widget _buildStyledTextField({
  required TextEditingController controller,
  required String label,
  required IconData icon,
  bool obscureText = false,
  TextInputType keyboardType = TextInputType.text,
  required Color color,
  Color labelColor = Colors.white,
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
    child: TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white),
      cursorColor: color,
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        prefixIcon: Icon(icon, color: color),
        labelText: label,
        labelStyle: TextStyle(color: labelColor), 
        border: InputBorder.none,
      ),
    ),
  );
}
}