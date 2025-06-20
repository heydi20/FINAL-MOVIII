import 'package:flixly/auth/LoginScreen.dart';
import 'package:flixly/auth/RegisterScreen.dart';
import 'package:flixly/main.dart';
import 'package:flutter/material.dart';



class MiDrawer extends StatelessWidget {
  const MiDrawer({super.key});

  final Color _drawerBackground = const Color(0xFF121212);
  final Color _purpleGradientStart = const Color(0xFF7B4EFF);
  final Color _purpleGradientEnd = const Color(0xFF9A67EA);
  final Color _iconColor = Colors.white70;
  final Color _textColor = Colors.white70;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: _drawerBackground,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [_purpleGradientStart, _purpleGradientEnd],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  CircleAvatar(
                    radius: 44,
                    backgroundColor: Colors.white24,
                    child: Icon(
                      Icons.person,
                      size: 52,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          color: _purpleGradientEnd.withOpacity(0.6),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Bienvenido, Usuario',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(
                          color: _purpleGradientEnd.withOpacity(0.7),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          _buildListTile(
            context,
            icon: Icons.login,
            label: 'Iniciar Sesión',
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const Login()),
              );
            },
          ),

          _buildListTile(
            context,
            icon: Icons.person_add,
            label: 'Registrarse',
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const Registro()),
              );
            },
          ),

        

          _buildListTile(
            context,
            icon: Icons.home,
            label: 'Inicio',
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProyectoF()),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildListTile(BuildContext context,
      {required IconData icon,
      required String label,
      required VoidCallback onTap}) {
    return ListTile(
      leading: Icon(
        icon,
        color: _iconColor,
        size: 28,
        shadows: [
          Shadow(
            color: _purpleGradientEnd.withOpacity(0.5),
            blurRadius: 4,
          ),
        ],
      ),
      title: Text(
        label,
        style: TextStyle(
          color: _textColor,
          fontSize: 18,
          fontWeight: FontWeight.w600,
          shadows: [
            Shadow(
              color: _purpleGradientEnd.withOpacity(0.3),
              blurRadius: 3,
            ),
          ],
        ),
      ),
      onTap: onTap,
      hoverColor: _purpleGradientEnd.withOpacity(0.15),
      splashColor: _purpleGradientEnd.withOpacity(0.25),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    );
  }
}