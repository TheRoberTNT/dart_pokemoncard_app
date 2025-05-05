import "dart:convert";
import "dart:math";
import "package:http/http.dart" as http;
import "dart:io";
import "db.dart";

class Pokemon {
  String? nombre;
  List<String> tipos = [];
  int vida = 0;
  int ataque = 0;
  int defensa = 0;
  int ataqueEspecial = 0;
  int defensaEspecial = 0;
  int velocidad = 0;

  Pokemon();

  String tiposComoCadena() {
    return tipos.join(',');
  }

  void tiposDesdeCadena(String cadena) {
    tipos = cadena.split(',');
  }

  Pokemon.fromAPI(datos) {
    nombre = datos['name'];
    for (var elemento in datos['types']) {
      tipos.add(elemento['type']['name']);
    }
    for (var elemento in datos['stats']) {
      switch (elemento['stat']['name']) {
        case 'hp':
          vida = elemento['base_stat'] ?? 0;
          break;
        case 'attack':
          ataque = elemento['base_stat'];
          break;
        case 'defense':
          defensa = elemento['base_stat'];
          break;
        case 'special-attack':
          ataqueEspecial = elemento['base_stat'];
          break;
        case 'special-defense':
          defensaEspecial = elemento['base_stat'];
          break;
        case 'speed':
          velocidad = elemento['base_stat'];
          break;
      }
    }
  }

  obtenerPokemon(String nombre) async {
    Uri url = Uri.parse("https://pokeapi.co/api/v2/pokemon/$nombre");
    var respuesta = await http.get(url);
    try {
      if (respuesta.statusCode == 200) {
        var body = json.decode(respuesta.body);
        Pokemon pokemon = Pokemon.fromAPI(body);
        return pokemon;
      } else if (respuesta.statusCode == 404) {
        throw ("El pokemon que buscas no existe!");
      // ignore: curly_braces_in_flow_control_structures
      } else throw ("Ha habido un error de conexión");
    } catch (e) {
      stdout.writeln(e);
    }
  }

  static imprimirInfo(Pokemon pokemon) {
    stdout.writeln("Nombre: ${pokemon.nombre}");
    stdout.writeln("Tipos:");
    for(var elemento in pokemon.tipos){
       stdout.writeln("    $elemento");
     }
    stdout.writeln("Estadísticas:");
    stdout.writeln("    Vida:             ${pokemon.vida}");
    stdout.writeln("    Ataque:           ${pokemon.ataque}");
    stdout.writeln("    Defensa:          ${pokemon.defensa}");
    stdout.writeln("    Ataque especial:  ${pokemon.ataqueEspecial}");
    stdout.writeln("    Defensa especial: ${pokemon.defensaEspecial}");
    stdout.writeln("    Velocidad:        ${pokemon.velocidad}");
  }

  Future<List<Pokemon>> obtenerPokemonesAleatorios(int cantidad) async {
    List<Pokemon> pokemones = [];
    for (int i = 0; i < cantidad; i++) {
      int idAleatorio = (1 + (Random().nextDouble() * 897).floor());
      Uri url = Uri.parse("https://pokeapi.co/api/v2/pokemon/$idAleatorio");
      var respuesta = await http.get(url);
      if (respuesta.statusCode == 200) {
        var body = json.decode(respuesta.body);
        pokemones.add(Pokemon.fromAPI(body));
      } else {
      i--;
      continue;
      }
    }
    return pokemones;
  }

  Future<void> guardarPokemonEnDB(Pokemon pokemon) async {
    var conn = await DB.obtenerConexion();
    try {
      await conn.query(
        '''
        INSERT INTO pokemon (nombre, tipo, hp, def, attk, speed, attk_special, def_special)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?)
        ''',
        [
        pokemon.nombre,
        pokemon.tiposComoCadena(),
        pokemon.vida,
        pokemon.defensa,
        pokemon.ataque,
        pokemon.velocidad,
        pokemon.ataqueEspecial,
        pokemon.defensaEspecial,
      ],
    );
      print("Pokemon guardado exitosamente.");
    }   catch (e) {
      print("Error al guardar el Pokemon: $e");
    } finally {
      await conn.close();
    }
  }
}