import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Crea esta clase si no la tienes
class VideoPlayerScreen extends StatelessWidget {
  final String videoId;
  
  const VideoPlayerScreen({super.key, required this.videoId});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reproduciendo Video'),
        backgroundColor: Colors.black,
      ),
      body: Center(
        child: Text(
          'Aquí iría el reproductor para: $videoId',
          style: const TextStyle(color: Colors.white),
        ),
      ),
      backgroundColor: Colors.black,
    );
  }
}

class CategoriasScreen extends StatefulWidget {
  final int edad;
  final List<String> generosFavoritos;
  
  const CategoriasScreen({
    super.key, 
    required this.edad, 
    required this.generosFavoritos
  });

  @override
  State<CategoriasScreen> createState() => _CategoriasScreenState();
}

class _CategoriasScreenState extends State<CategoriasScreen> 
    with TickerProviderStateMixin {
  late YoutubePlayerController _controller;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  
  // Controladores para búsqueda y filtros
  final TextEditingController _searchController = TextEditingController();
  String _categoriaSeleccionada = 'Todas';
  List<Map<String, dynamic>> _peliculasFiltradas = [];
  
  // Variables para control parental
  late int _edadUsuario;
  bool _isLoading = true;

  // Todas las películas organizadas con clasificaciones de edad
  final List<Map<String, dynamic>> _todasLasPeliculas = const [
    // Películas Destacadas
    {
      'titulo': 'Avengers: Endgame',
      'imagen': 'https://image.tmdb.org/t/p/w500/or06FN3Dka5tukK1e9sl16pB3iy.jpg',
      'descripcion': 'Los Vengadores se reúnen para revertir el Snap de Thanos',
      'categoria': 'Destacadas',
      'trailerId': 'TcMBFSGVi1c',
      'peliculaId': 'PLl99DlL6b4',
      'edadMinima': 13,
    },
    {
      'titulo': 'Dune',
      'imagen': 'https://image.tmdb.org/t/p/w500/d5NXSklXo0qyIYkgV94XAgMIckC.jpg',
      'descripcion': 'Un joven heredero viaja al planeta más peligroso del universo',
      'categoria': 'Destacadas',
      'trailerId': 'n9xhJrPXop4',
      'peliculaId': 'uPIEn0M8su0',
      'edadMinima': 13,
    },
    {
      'titulo': 'Spider-Man: No Way Home',
      'imagen': 'https://image.tmdb.org/t/p/w500/1g0dhYtq4irTY1GPXvft6k4YLjm.jpg',
      'descripcion': 'Peter Parker desata un multiverso al pedir ayuda a Doctor Strange',
      'categoria': 'Destacadas',
      'trailerId': 'JfVOs4VSpmA',
      'peliculaId': 'x8-7mHT9edI',
      'edadMinima': 13,
    },
    {
      'titulo': 'The Batman',
      'imagen': 'https://image.tmdb.org/t/p/w500/seyWFgGInaLqW7nOZvu0ZC95rtx.jpg',
      'descripcion': 'Batman investiga la corrupción en Gotham cuando aparece el Acertijo',
      'categoria': 'Destacadas',
      'trailerId': 'mqqft2x_Aa4',
      'peliculaId': 'aS_d0Ayjw4o',
      'edadMinima': 13,
    },
    // Películas Animadas
    {
      'titulo': 'Encanto',
      'imagen': 'https://image.tmdb.org/t/p/w500/4j0PNHkMr5ax3IA8tjtxcmPU3QT.jpg',
      'descripcion': 'Una familia mágica vive en las montañas de Colombia',
      'categoria': 'Animadas',
      'trailerId': 'CaimKeDcudo',
      'peliculaId': 'JPVIgshtOag',
      'edadMinima': 0,
    },
    {
      'titulo': 'Turning Red',
      'imagen': 'https://image.tmdb.org/t/p/w500/qsdjk9oAKSQMWs0Vt5Pyfh6O4GZ.jpg',
      'descripcion': 'Una adolescente se convierte en panda rojo gigante',
      'categoria': 'Animadas',
      'trailerId': 'XdKzUbAiswE',
      'peliculaId': 'XdKzUbAiswE',
      'edadMinima': 7,
    },
    {
      'titulo': 'Luca',
      'imagen': 'https://image.tmdb.org/t/p/w500/jTswp6KyDYKtvC52GbHagrZbGvD.jpg',
      'descripcion': 'Un niño monstruo marino vive aventuras en Italia',
      'categoria': 'Animadas',
      'trailerId': 'mYfJxlgR2jw',
      'peliculaId': 'mYfJxlgR2jw',
      'edadMinima': 0,
    },
    {
      'titulo': 'Soul',
      'imagen': 'https://image.tmdb.org/t/p/w500/hm58Jw4Lw8OIeECIq5qyPYhAeRJ.jpg',
      'descripcion': 'Un músico de jazz busca su propósito en la vida',
      'categoria': 'Animadas',
      'trailerId': 'xOsLIiBStEs',
      'peliculaId': 'xOsLIiBStEs',
      'edadMinima': 7,
    },
    // Terror
    {
      'titulo': 'The Conjuring',
      'imagen': 'https://image.tmdb.org/t/p/w500/wVYREutTvI2tmxr6ujrHT704wGF.jpg',
      'descripcion': 'Investigadores paranormales ayudan a una familia aterrorizada',
      'categoria': 'Terror',
      'trailerId': 'k10ETZ41q5o',
      'peliculaId': 'ejMMn0t58Lc',
      'edadMinima': 18,
    },
    {
      'titulo': 'Hereditary',
      'imagen': 'https://image.tmdb.org/t/p/w500/lHV8HHlhwNup2VbpiACtlKzaGIQ.jpg',
      'descripcion': 'Una familia devastada descubre secretos aterradores',
      'categoria': 'Terror',
      'trailerId': 'V6wWKNij_1M',
      'peliculaId': 'YHxcDbai7aU',
      'edadMinima': 18,
    },
    {
      'titulo': 'A Quiet Place',
      'imagen': 'https://image.tmdb.org/t/p/w500/nAU74GmpUk7t5iklEp3bufwDq4n.jpg',
      'descripcion': 'Una familia vive en silencio para evitar criaturas mortales',
      'categoria': 'Terror',
      'trailerId': 'WR7cc5t7tv8',
      'peliculaId': 'XEMwSdne6UE',
      'edadMinima': 13,
    },
    {
      'titulo': 'Get Out',
      'imagen': 'https://image.tmdb.org/t/p/w500/tFXcEccSQMf3lfhfXKSU9iRBpa3.jpg',
      'descripcion': 'Un joven descubre secretos perturbadores en casa de su novia',
      'categoria': 'Terror',
      'trailerId': 'DzfpyUB60YY',
      'peliculaId': 'sRfnevzM9kQ',
      'edadMinima': 18,
    },
    // Caricaturas
    {
      'titulo': 'Minions: The Rise of Gru',
      'imagen': 'https://image.tmdb.org/t/p/w500/wKiOkZTN9lUUUNZLmtnwubZYONg.jpg',
      'descripcion': 'Gru y los Minions en nuevas aventuras',
      'categoria': 'Caricaturas',
      'trailerId': 'nb6hRcujn1k',
      'peliculaId': 'nb6hRcujn1k',
      'edadMinima': 5,
    },
    {
      'titulo': 'Sonic the Hedgehog 2',
      'imagen': 'https://image.tmdb.org/t/p/w500/6DrHO1jr3qVrViUO6s6kFiAGM7.jpg',
      'descripcion': 'Sonic se une a Tails para detener al Dr. Robotnik',
      'categoria': 'Caricaturas',
      'trailerId': 'G5kzUpWAusI',
      'peliculaId': 'G5kzUpWAusI',
      'edadMinima': 5,
    },
    {
      'titulo': 'The Bad Guys',
      'imagen': 'https://image.tmdb.org/t/p/w500/7qop80YfuO0BwJa1uXk1DXUUEwv.jpg',
      'descripcion': 'Un grupo de animales criminales intenta ser bueno',
      'categoria': 'Caricaturas',
      'trailerId': 'qa51dog0HN0',
      'peliculaId': 'qa51dog0HN0',
      'edadMinima': 5,
    },
    {
      'titulo': 'Lightyear',
      'imagen': 'https://image.tmdb.org/t/p/w500/ox4goZd956BxqJH6iLwhWPL9ct4.jpg',
      'descripcion': 'La historia del origen del guardián espacial Buzz Lightyear',
      'categoria': 'Caricaturas',
      'trailerId': 'BwPL0Md_QFQ',
      'peliculaId': 'BwPL0Md_QFQ',
      'edadMinima': 5,
    },
    // Romance
    {
      'titulo': 'The Notebook',
      'imagen': 'https://image.tmdb.org/t/p/w500/qom1SZSENdmHFNZBXbtJAU0WTlC.jpg',
      'descripcion': 'Una historia de amor que perdura a través del tiempo',
      'categoria': 'Romance',
      'trailerId': '4M7LIcH8C9U',
      'peliculaId': '4M7LIcH8C9U',
      'edadMinima': 13,
    },
    {
      'titulo': 'La La Land',
      'imagen': 'https://image.tmdb.org/t/p/w500/uDO8zWDhfWwoFdKS4fzkUJt0Rf0.jpg',
      'descripcion': 'Un músico y una actriz persiguen sus sueños en Los Ángeles',
      'categoria': 'Romance',
      'trailerId': '0pdqf4P9MB8',
      'peliculaId': '0pdqf4P9MB8',
      'edadMinima': 13,
    },
    {
      'titulo': 'Titanic',
      'imagen': 'https://image.tmdb.org/t/p/w500/9xjZS2rlVxm8SFx8kPC3aIGCOYQ.jpg',
      'descripcion': 'Una historia de amor épica a bordo del barco más famoso',
      'categoria': 'Romance',
      'trailerId': 'CHekzSiZjrY',
      'peliculaId': 'CHekzSiZjrY',
      'edadMinima': 13,
    },
    {
      'titulo': 'Me Before You',
      'imagen': 'https://image.tmdb.org/t/p/w500/Ia3dzj5LnCj1ZkqDkbJ7VGAIO0y.jpg',
      'descripcion': 'Una joven cambia la vida de un hombre tetrapléjico',
      'categoria': 'Romance',
      'trailerId': 'EbS6pinmAl4',
      'peliculaId': 'EbS6pinmAl4',
      'edadMinima': 13,
    },
  ];

  @override
  void initState() {
    super.initState();
    
    // Usar la edad pasada desde el login
    _edadUsuario = widget.edad;
    
    _controller = YoutubePlayerController(
      initialVideoId: 'oyRxxpD3yNw',
      flags: const YoutubePlayerFlags(
        autoPlay: false,
        mute: false,
      ),
    );

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    );
    _fadeController.forward();

    // Cargar edad del usuario (mejorado)
    _cargarEdadUsuario();
  }

  // Función para obtener la edad del usuario desde Supabase
  Future<void> _cargarEdadUsuario() async {
    try {
      final supabase = Supabase.instance.client;
      final user = supabase.auth.currentUser;
      
      if (user != null) {
        final response = await supabase
            .from('usuarios')
            .select('edad')
            .eq('id', user.id)
            .single();
        
        if (response != null && response['edad'] != null) {
          setState(() {
            _edadUsuario = response['edad'] as int;
          });
        }
      }
    } catch (e) {
      print('Error al cargar edad del usuario: $e');
      // Mantener la edad pasada desde el login como fallback
    }
    
    setState(() {
      _isLoading = false;
    });
    
    // Inicializar con películas filtradas por edad
    _peliculasFiltradas = _todasLasPeliculas.where((pelicula) {
      return _edadUsuario >= (pelicula['edadMinima'] ?? 0);
    }).toList();
  }

  @override
  void dispose() {
    _controller.dispose();
    _fadeController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _filtrarPeliculas() {
    setState(() {
      _peliculasFiltradas = _todasLasPeliculas.where((pelicula) {
        bool coincideCategoria = _categoriaSeleccionada == 'Todas' || 
                                pelicula['categoria'] == _categoriaSeleccionada;
        bool coincideBusqueda = pelicula['titulo'].toLowerCase()
                               .contains(_searchController.text.toLowerCase());
        // Control parental: verificar edad
        bool esAptoParaEdad = _edadUsuario >= (pelicula['edadMinima'] ?? 0);
        
        return coincideCategoria && coincideBusqueda && esAptoParaEdad;
      }).toList();
    });
  }

  void _seleccionarCategoria(String categoria) {
    setState(() {
      _categoriaSeleccionada = categoria;
    });
    _filtrarPeliculas();
  }

  @override
  Widget build(BuildContext context) {
    // Mostrar loading mientras carga la edad
    if (_isLoading) {
      return Scaffold(
        backgroundColor: const Color.fromARGB(255, 39, 38, 38),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                color: Colors.deepPurpleAccent,
                strokeWidth: 3,
              ),
              SizedBox(height: 20),
              Text(
                'Cargando tu perfil...',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 39, 38, 38),
      appBar: AppBar(
        title: Container(
          height: 45,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF2A2A2A), Color(0xFF1A1A1A)],
            ),
            borderRadius: BorderRadius.circular(25),
            border: Border.all(
              color: Colors.deepPurpleAccent.withOpacity(0.3),
              width: 2,
            ),
          ),
          child: TextField(
            controller: _searchController,
            onChanged: (value) => _filtrarPeliculas(),
            style: const TextStyle(color: Colors.white, fontSize: 16),
            decoration: const InputDecoration(
              hintText: 'Buscar películas y series...',
              hintStyle: TextStyle(color: Colors.white54, fontSize: 14),
              prefixIcon: Icon(
                Icons.search, 
                color: Colors.deepPurpleAccent, 
                size: 24,
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            ),
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 39, 38, 38),
        elevation: 4,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              gradient: const LinearGradient(
                colors: [Colors.deepPurpleAccent, Colors.purpleAccent],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.deepPurpleAccent.withOpacity(0.5),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: IconButton(
              icon: const Icon(Icons.play_circle_fill, color: Colors.white),
              tooltip: 'Ir a reproducción',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const VideoPlayerScreen(
                      videoId: 'dQw4w9WgXcQ', // Video por defecto
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          children: [
            // Botones de categorías (movidos arriba)
            Container(
              height: 60,
              margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _buildCategoryButton('Todas'),
                  _buildCategoryButton('Destacadas'),
                  _buildCategoryButton('Animadas'),
                  _buildCategoryButton('Terror'),
                  _buildCategoryButton('Caricaturas'),
                  _buildCategoryButton('Romance'),
                ],
              ),
            ),

            // Reproductor de YouTube
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.deepPurpleAccent.withOpacity(0.3),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: YoutubePlayer(
                  controller: _controller,
                  showVideoProgressIndicator: true,
                  progressIndicatorColor: Colors.deepPurpleAccent,
                  progressColors: const ProgressBarColors(
                    playedColor: Colors.deepPurpleAccent,
                    handleColor: Colors.purpleAccent,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 25),

            // Lista de películas filtradas
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _searchController.text.isNotEmpty 
                          ? 'RESULTADOS DE BÚSQUEDA' 
                          : _categoriaSeleccionada.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.deepPurpleAccent,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 15),
                    Expanded(
                      child: _peliculasFiltradas.isEmpty
                          ? const Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.search_off,
                                    size: 80,
                                    color: Colors.white54,
                                  ),
                                  SizedBox(height: 20),
                                  Text(
                                    'No se encontraron resultados',
                                    style: TextStyle(
                                      color: Colors.white54,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : GridView.builder(
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 15,
                                mainAxisSpacing: 15,
                                childAspectRatio: 0.75,
                              ),
                              itemCount: _peliculasFiltradas.length,
                              itemBuilder: (context, index) {
                                var pelicula = _peliculasFiltradas[index];
                                return _buildMovieCard(pelicula);
                              },
                            ),
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

  Widget _buildCategoryButton(String categoria) {
    bool isSelected = _categoriaSeleccionada == categoria;
    
    return GestureDetector(
      onTap: () => _seleccionarCategoria(categoria),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 15),
        decoration: BoxDecoration(
          gradient: isSelected
              ? const LinearGradient(
                  colors: [Colors.deepPurpleAccent, Colors.purpleAccent],
                )
              : const LinearGradient(
                  colors: [Color(0xFF2A2A2A), Color(0xFF1A1A1A)],
                ),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: isSelected 
                ? Colors.purpleAccent 
                : Colors.white12,
            width: 2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.deepPurpleAccent.withOpacity(0.5),
                    blurRadius: 15,
                    spreadRadius: 2,
                  ),
                ]
              : null,
        ),
        child: Text(
          categoria,
          style: TextStyle(
            color: Colors.white,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
            fontSize: 14,
            letterSpacing: 1,
          ),
        ),
      ),
    );
  }

  Widget _buildMovieCard(Map<String, dynamic> pelicula) {
    return GestureDetector(
      onTap: () => _showMovieOptionsDialog(context, pelicula),
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF2A2A2A), Color(0xFF1A1A1A)],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white12),
          boxShadow: [
            BoxShadow(
              color: Colors.deepPurpleAccent.withOpacity(0.2),
              blurRadius: 15,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          children: [
            Expanded(
              flex: 4,
              child: Container(
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                  child: Image.network(
                    pelicula['imagen'],
                    fit: BoxFit.cover,
                    width: double.infinity,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: Colors.grey[800],
                      child: const Center(
                        child: Icon(
                          Icons.broken_image, 
                          color: Colors.white,
                          size: 40,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                      child: Text(
                        pelicula['titulo'],
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          height: 1.1,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
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

  void _showMovieOptionsDialog(BuildContext context, Map<String, dynamic> pelicula) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1F1B24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          title: Text(
            pelicula['titulo'],
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.deepPurpleAccent,
              letterSpacing: 1,
            ),
            textAlign: TextAlign.center,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Image.network(
                  pelicula['imagen'],
                  height: 200,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 200,
                    color: Colors.grey[800],
                    child: const Center(
                      child: Icon(Icons.broken_image, color: Colors.white),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                pelicula['descripcion'],
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.white,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 25),
              const Text(
                '¿QUÉ DESEAS HACER?',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurpleAccent,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
          actions: [
            Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      elevation: 8,
                      shadowColor: Colors.orange.shade200,
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                      _controller.load(pelicula['trailerId']);
                    },
                    child: const Text(
                      "VER TRAILER",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurpleAccent,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      elevation: 8,
                      shadowColor: Colors.deepPurpleAccent.shade200,
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                      _controller.load(pelicula['peliculaId']);
                    },
                    child: const Text(
                      "VER PELÍCULA",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    "CANCELAR",
                    style: TextStyle(
                      color: Colors.deepPurpleAccent.shade200,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}