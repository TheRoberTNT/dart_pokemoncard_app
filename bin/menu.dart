import 'package:mysql1/mysql1.dart';
import 'usuario.dart';
import 'dart:io';
import 'pokemon.dart';
import 'db.dart';

class Menu{
  final MySqlConnection _connection;
  Usuario usuario = Usuario();
  Menu(this._connection);

  void menuInicio(){
    stdout.writeln('''Bienvenido:
      1 - Iniciar Sesión
      2 - Registrarse
      3 - Salir''');
    String respuesta = stdin.readLineSync() ?? "Error";
    switch (respuesta){
      case "1":
        inicioSesion();
        break;
      case "2":
        registrar();
        break;
      case "3":
        exit(0);
    }
  }

  void inicioSesion() async {
    try {
      stdout.writeln("Introduce tu usuario:");
      String user = stdin.readLineSync() ?? 'Error';
      stdout.writeln("Introduce tu contraseña:");
      String password = stdin.readLineSync() ?? 'Error';

      var result = await _connection.query(
      'SELECT * FROM usuario WHERE nombre = ? AND password = ?',
      [user, password],
      );

      if (result.isNotEmpty) {
        stdout.writeln("Login correcto");
        usuario.user = user;
        usuario.password = password;
        menu();
      } else {
        stdout.writeln("Login incorrecto");
        menuInicio();
      }
    } catch (error) {
      print("Error durante el inicio de sesión: $error");
      menuInicio();
    }
  }

  void registrar() async {
    bool creado = false;
    do {
      stdout.writeln("Introduce tu usuario:");
      String user = stdin.readLineSync() ?? 'Error';
      stdout.writeln("Introduce tu contraseña:");
      String password = stdin.readLineSync() ?? 'Error';

      try {
        bool existe = await Usuario.comprobarSiExisteUsuario(user);
        if (existe) {
          stdout.writeln("El usuario ya existe, prueba otra vez");
        } else {
          await _connection.query(
            'INSERT INTO usuario (nombre, password) VALUES (?, ?)',
            [user, password],
          );

          await _connection.query(
          'INSERT INTO coleccion (id_usuario) VALUES ((SELECT idusuario FROM usuario WHERE nombre = ?))',
          [user],
          );
          stdout.writeln('''Usuario creado con éxito!
          Volviendo al menú...''');
          creado = true;
          menuInicio();
        }
      } catch (error) {
        print(error);
      }
    } while (!creado);
  }

  void menu() {
    stdout.writeln('''Bienvenid@ ${usuario.user}
    Elije una opción:
    1 - Abrir sobre
    2 - Mirar tu colección
    0 - Salir''');
    String respuesta = stdin.readLineSync() ?? "Error";
    switch (respuesta) {
      case "1":
        abrirSobre();
        break;
      case "2":
        verColeccion();
        break;
      case "0":
        exit(0);
      default:
        stdout.writeln("La opción no es válida, prueba otra vez");
        menu();
    }
  }

  void abrirSobre() async {
    stdout.writeln("Abriendo un sobre...");
    try {
      List<Pokemon> pokemones = await Pokemon().obtenerPokemonesAleatorios(5);
      for (var pokemon in pokemones) {
        try {
          await pokemon.guardarPokemonEnDB(pokemon);
          await DB().guardarPokemonEnColeccion(pokemon,usuario.user!);
        } catch (e) {
          stdout.writeln("Error al imprimir la información del Pokémon: $e");
        }
      }
      stdout.writeln("¡Sobre abierto con éxito! Los Pokémon se han añadido a tu colección.");
    } catch (e) {
      stdout.writeln("Error al abrir el sobre: $e");
    }
    menu();
  }

  void verColeccion() async {
    stdout.writeln("\n=== TU COLECCIÓN DE POKÉMON ===");
    try {
      var resultados = await _connection.query('''
        SELECT p.nombre, p.tipo, p.hp, p.def, p.attk, p.speed, p.attk_special, p.def_special, cc.cantidad
        FROM coleccion_cartas cc
        JOIN pokemon p ON cc.id_pokemon = p.id
        JOIN coleccion c ON cc.id_coleccion = c.id
        JOIN usuario u ON c.id_usuario = u.idusuario
        WHERE u.nombre = ?
        ORDER BY p.nombre
      ''', [usuario.user]);

      if (resultados.isEmpty) {
        stdout.writeln("\nNo tienes Pokémon en tu colección aún.");
        stdout.writeln("¡Abre algunos sobres para empezar!\n");
      } else {
        stdout.writeln("\nTienes ${resultados.length} tipos diferentes de Pokémon:");
        stdout.writeln("--------------------------------------------------");
      
        for (var fila in resultados) {
          stdout.writeln("Nombre: ${fila['nombre']}");
          stdout.writeln("Tipos: ${fila['tipo']}");
          stdout.writeln("Cantidad: ${fila['cantidad']}");
          stdout.writeln("Estadísticas:");
          stdout.writeln("  - HP: ${fila['hp']}");
          stdout.writeln("  - Ataque: ${fila['attk']}");
          stdout.writeln("  - Defensa: ${fila['def']}");
          stdout.writeln("  - Velocidad: ${fila['speed']}");
          stdout.writeln("  - Ataque Especial: ${fila['attk_special']}");
          stdout.writeln("  - Defensa Especial: ${fila['def_special']}");
          stdout.writeln("--------------------------------------------------");
        }
      
        int totalCartas = resultados.fold(0, (sum, fila) => sum + fila['cantidad'] as int);
        stdout.writeln("\nTotal de cartas en tu colección: $totalCartas\n");
      }
    } catch (e) {
      stdout.writeln("\nError al mostrar la colección: $e\n");
    }
    menu();
  }
}