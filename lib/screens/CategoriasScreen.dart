import 'package:flixly/screens/ReproduccionScreen.dart';
import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';


class CategoriasScreen extends StatefulWidget {
  final int edad;
  final List<String> generosFavoritos;

  const CategoriasScreen({
    super.key,
    required this.edad,
    required this.generosFavoritos,
  });

  @override
  State<CategoriasScreen> createState() => _CategoriasScreenState();
}

class _CategoriasScreenState extends State<CategoriasScreen> {
  late YoutubePlayerController _controller;

  final List<Map<String, dynamic>> peliculas = [
    // Acción
    {
      'titulo': 'Avengers: Endgame',
      'imagen': 'https://image.tmdb.org/t/p/w500/or06FN3Dka5tukK1e9sl16pB3iy.jpg',
      'descripcion': 'Los Vengadores se unen para revertir el Snap de Thanos',
      'categoria': 'Populares',
      'genero': 'Acción',
      'paraMayores': false,
    },
    {
      'titulo': 'Deadpool',
      'imagen': 'https://image.tmdb.org/t/p/w500/1DPmUzUo5eA4rM5ZljO4vm3ebDT.jpg',
      'descripcion': 'Superhéroe irreverente con humor negro',
      'categoria': 'Populares',
      'genero': 'Acción',
      'paraMayores': true,
    },
    {
      'titulo': 'John Wick',
      'imagen': 'https://image.tmdb.org/t/p/w500/ziEuG1essDuWuC5lpWUaw1uXY2O.jpg',
      'descripcion': 'Asesino retirado vuelve a la acción',
      'categoria': 'Tendencias',
      'genero': 'Acción',
      'paraMayores': true,
    },
    // Animación
    {
      'titulo': 'Toy Story',
      'imagen': 'https://image.tmdb.org/t/p/w500/uXDfjJbdP4ijW5hWSBrPrlKpxab.jpg',
      'descripcion': 'Las aventuras de juguetes que cobran vida',
      'categoria': 'Nuevas Llegadas',
      'genero': 'Animación',
      'paraMayores': false,
    },
    {
      'titulo': 'Soul',
      'imagen': 'https://image.tmdb.org/t/p/w500/hm58Jw4Lw8OIeECIq5qyPYhAeRJ.jpg',
      'descripcion': 'Un músico con una segunda oportunidad',
      'categoria': 'Populares',
      'genero': 'Animación',
      'paraMayores': false,
    },
    {
      'titulo': 'Saul Gone',
      'imagen': 'https://image.tmdb.org/t/p/w500/7F2Y2reCJyK2Bt4cvM9Uhzk1R1.jpg',
      'descripcion': 'Película animada para adultos',
      'categoria': 'Populares',
      'genero': 'Animación',
      'paraMayores': true,
    },
    // Fantasía
    {
      'titulo': 'Harry Potter y la Piedra Filosofal',
      'imagen': 'https://image.tmdb.org/t/p/w500/eWRT4fpiL5tIucV8MGbZ9FvAPaW.jpg',
      'descripcion': 'Un niño descubre que es mago',
      'categoria': 'Tendencias',
      'genero': 'Fantasía',
      'paraMayores': false,
    },
    {
      'titulo': 'El Laberinto del Fauno',
      'imagen': 'https://image.tmdb.org/t/p/w500/4iGmGkN81CSq7FvTXN02nOV0GmE.jpg',
      'descripcion': 'Oscura historia de fantasía para adultos',
      'categoria': 'Populares',
      'genero': 'Fantasía',
      'paraMayores': true,
    },
    {
      'titulo': 'El Señor de los Anillos: La Comunidad del Anillo',
      'imagen': 'https://image.tmdb.org/t/p/w500/6oom5QYQ2yQTMJIbnvbkBL9cHo6.jpg',
      'descripcion': 'Un viaje épico para destruir un anillo',
      'categoria': 'Nuevas Llegadas',
      'genero': 'Fantasía',
      'paraMayores': false,
    },
    // Aventura
    {
      'titulo': 'Jumanji: Bienvenidos a la Jungla',
      'imagen': 'https://image.tmdb.org/t/p/w500/d9nBoowhjiiYc4FBNtQkPY7c11H.jpg',
      'descripcion': 'Un juego mágico los lleva a una aventura',
      'categoria': 'Populares',
      'genero': 'Aventura',
      'paraMayores': false,
    },
    {
      'titulo': 'Indiana Jones y el Reino de la Calavera de Cristal',
      'imagen': 'https://image.tmdb.org/t/p/w500/rxRpbeI6WqgeJeXjSWYg63s4zju.jpg',
      'descripcion': 'Indiana Jones en una peligrosa misión',
      'categoria': 'Tendencias',
      'genero': 'Aventura',
      'paraMayores': true,
    },
    {
      'titulo': 'Piratas del Caribe',
      'imagen': 'https://image.tmdb.org/t/p/w500/2dKqFGsH6AfB9F9V6RztIxA5bBa.jpg',
      'descripcion': 'Aventuras de piratas en el Caribe',
      'categoria': 'Populares',
      'genero': 'Aventura',
      'paraMayores': false,
    },
    // Comedia
    {
      'titulo': 'La Gran Apuesta',
      'imagen': 'https://image.tmdb.org/t/p/w500/8HH3xbpT5RQk6EsIMtXqTIl6NK5.jpg',
      'descripcion': 'Comedia dramática sobre la crisis financiera',
      'categoria': 'Populares',
      'genero': 'Comedia',
      'paraMayores': true,
    },
    {
      'titulo': 'Mi Pobre Angelito',
      'imagen': 'https://image.tmdb.org/t/p/w500/ciHqTHnfkFqsTPTHZKdQ2ZBBOVZ.jpg',
      'descripcion': 'Un niño defiende su casa en Navidad',
      'categoria': 'Nuevas Llegadas',
      'genero': 'Comedia',
      'paraMayores': false,
    },
    {
      'titulo': 'Superbad',
      'imagen': 'https://image.tmdb.org/t/p/w500/ek8e8txUyUwd2BNqj6lFEerJfbq.jpg',
      'descripcion': 'Comedia juvenil sobre la amistad',
      'categoria': 'Populares',
      'genero': 'Comedia',
      'paraMayores': true,
    },
    // Familiar
    {
      'titulo': 'Coco',
      'imagen': 'https://image.tmdb.org/t/p/w500/eKi8dIrr8voobbaGzDpe8w0PVbC.jpg',
      'descripcion': 'Un niño busca sus raíces en el Día de Muertos',
      'categoria': 'Populares',
      'genero': 'Familiar',
      'paraMayores': false,
    },
    {
      'titulo': 'The Boy and the Beast',
      'imagen': 'https://image.tmdb.org/t/p/w500/j6QYpcz1IhF5ZXZ3hNKl6gCjChq.jpg',
      'descripcion': 'Historia de aventura y crecimiento para adultos',
      'categoria': 'Tendencias',
      'genero': 'Familiar',
      'paraMayores': true,
    },
    {
      'titulo': 'Up',
      'imagen': 'https://image.tmdb.org/t/p/w500/pthWTCy5ij2v6MwqoD3AcP3vRbC.jpg',
      'descripcion': 'Una aventura llena de emociones',
      'categoria': 'Nuevas Llegadas',
      'genero': 'Familiar',
      'paraMayores': false,
    },
  ];

  final List<String> generosPermitidos = [
    'Animación',
    'Fantasía',
    'Aventura',
    'Comedia',
    'Familiar',
  ];

  @override
  void initState() {
    super.initState();
    _controller = YoutubePlayerController(
      initialVideoId: 'oyRxxpD3yNw',
      flags: const YoutubePlayerFlags(
        autoPlay: true,
        mute: false,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool esMayorEdad = widget.edad >= 18;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Películas'),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 170, 181, 240),
        elevation: 4,
        actions: [
          IconButton(
            icon: const Icon(Icons.play_circle_fill),
            tooltip: 'Ir a reproducción',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Reproduccionscreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: YoutubePlayerBuilder(
        player: YoutubePlayer(
          controller: _controller,
          showVideoProgressIndicator: true,
          progressIndicatorColor: Colors.blueAccent,
        ),
        builder: (context, player) {
          return Column(
            children: [
              player,
              if (!esMayorEdad)
                Container(
                  width: double.infinity,
                  color: Colors.redAccent.withOpacity(0.1),
                  padding: const EdgeInsets.all(12),
                  child: const Text(
                    "🔒 Algunas películas están restringidas por tu edad.",
                    style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),
                  ),
                ),
              Expanded(
                child: Peliculas(
                  edad: widget.edad,
                  generosFavoritos: widget.generosFavoritos,
                  peliculas: peliculas,
                  generosPermitidos: generosPermitidos,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class Peliculas extends StatelessWidget {
  final int edad;
  final List<String> generosFavoritos;
  final List<Map<String, dynamic>> peliculas;
  final List<String> generosPermitidos;

  const Peliculas({
    super.key,
    required this.edad,
    required this.generosFavoritos,
    required this.peliculas,
    required this.generosPermitidos,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildRecomendadas(context),
          _buildSeccionPeliculas(context, 'Populares'),
          _buildSeccionPeliculas(context, 'Tendencias'),
          _buildSeccionPeliculas(context, 'Nuevas Llegadas'),
        ],
      ),
    );
  }

  Widget _buildRecomendadas(BuildContext context) {
    final esMayor = edad >= 18;
    final List<Map<String, dynamic>> recomendadas = [];

    for (var genero in generosPermitidos) {
      final peliMenor = peliculas.firstWhere(
        (p) => p['genero'] == genero && p['paraMayores'] == false,
        orElse: () => {},
      );
      final peliMayor = peliculas.firstWhere(
        (p) => p['genero'] == genero && p['paraMayores'] == true,
        orElse: () => {},
      );

      if (peliMenor.isNotEmpty) recomendadas.add(peliMenor);
      if (peliMayor.isNotEmpty && esMayor) recomendadas.add(peliMayor);
    }

    if (recomendadas.isEmpty) return const SizedBox();

    return _buildCarrusel(context, "🎯 Recomendado para ti", recomendadas);
  }

  Widget _buildSeccionPeliculas(BuildContext context, String categoria) {
    final esMayor = edad >= 18;
    final filtradas = peliculas.where((p) {
      return p['categoria'] == categoria &&
          (esMayor || p['paraMayores'] == false);
    }).toList();

    if (filtradas.isEmpty) return const SizedBox();

    return _buildCarrusel(context, categoria, filtradas);
  }

  Widget _buildCarrusel(BuildContext context, String titulo, List<Map<String, dynamic>> data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: Text(
            titulo,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        SizedBox(
          height: 220,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: data.length,
            itemBuilder: (context, index) {
              var pelicula = data[index];
              return GestureDetector(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text(pelicula['titulo']),
                      content: Text(pelicula['descripcion']),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('Cerrar'),
                        ),
                      ],
                    ),
                  );
                },
                child: Container(
                  width: 150,
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          pelicula['imagen'],
                          height: 150,
                          width: 150,
                          fit: BoxFit.contain, // <-- Cambiado para mostrar imagen completa
                          errorBuilder: (context, error, stackTrace) => Container(
                            height: 150,
                            width: 150,
                            color: Colors.grey,
                            child: const Icon(Icons.broken_image),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        pelicula['titulo'],
                        style: const TextStyle(fontWeight: FontWeight.bold),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        pelicula['descripcion'],
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}