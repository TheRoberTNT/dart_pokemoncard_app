import 'package:mysql1/mysql1.dart';
import 'usuario.dart';
import 'dart:io';

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
    stdout.writeln('''Bienvenido ${usuario.user}
    Elije una opción:
    1 - Abrir sobre
    2 - Mirar tu colección
    3 - Salir''');
    String respuesta = stdin.readLineSync() ?? "Error";
    switch (respuesta) {
      case "1":
        stdout.writeln("WIP");
        menu();
        break;
      case "2":
        stdout.writeln("WIP");
        menu();
        break;
      case "3":
        exit(0);
      default:
        stdout.writeln("La opción no es válida, prueba otra vez");
        menu();
    }
  }
}