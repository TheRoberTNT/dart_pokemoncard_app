import 'package:mysql1/mysql1.dart';

class DB {
  static const String _host = 'localhost';
  static const int _port = 3306;
  static const String _user = 'root';
  static const String _nombreBBDD = 'mypokemoncard_db';

  static instalarBBDD() async {
    var settings = ConnectionSettings(
      host: _host, 
      port: _port,
      user: _user,
    );
    var conn = await MySqlConnection.connect(settings);
    try{
      await _crearBBDD(conn);
      await _crearTablas(conn);
    } catch(e){
      print(e);
    } finally {
      await conn.close();
    }
  }

  static Future<MySqlConnection> obtenerConexion() async {
    var settings = ConnectionSettings(
      host: _host,
      port: _port,
      user: _user,
      db: _nombreBBDD,
    );
    return await MySqlConnection.connect(settings);
  }

  static Future<void> _crearBBDD(MySqlConnection conn) async {
    await conn.query('CREATE DATABASE IF NOT EXISTS $_nombreBBDD');
    await conn.query('USE $_nombreBBDD');
    print('Base de datos creada o ya existente...');
    print('Conectado a $_nombreBBDD...');
  }

  static Future<void> _crearTablas(MySqlConnection conn) async {
    try {
      await _crearTablaUsuario(conn);
      await _crearTablaSobre(conn);
      await _crearTablaPokemon(conn);
      await _crearTablaColeccion(conn);
      await _crearTablaColeccionCartas(conn);
    } catch (e) {
      print('Error al crear tablas: $e');
      rethrow;
    }
  }

  static _crearTablaUsuario(connection) async{
    try {
      await connection!.query('''
        CREATE TABLE IF NOT EXISTS usuario(
        idusuario INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
        nombre VARCHAR(50) NOT NULL UNIQUE,
        password VARCHAR(10) NOT NULL
        )
      ''');
      print('Cargando Tabla Usuario ...');
    } catch (error) {
      print('Error al inicializar la tabla usuarios: $error');
    } finally {
      print ('Tabla usuario completada');
    }
  }

  static _crearTablaSobre(connection) async{
    try {
      await connection!.query('''
        CREATE TABLE IF NOT EXISTS sobre(
        id_sobre INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
        nombre VARCHAR(30) NOT NULL UNIQUE,
        cantidad_cartas INT NOT NULL,
        cooldown DATETIME NOT NULL
        )
      ''');
      print('Cargando Tabla Sobre...');
    } catch (error) {
      print('Error al inicializar la tabla sobre: $error');
    } finally {
      print ('Tabla Sobre completada');
    }
  }
  static _crearTablaPokemon(connection) async {
    try {
      await connection!.query('''
        CREATE TABLE IF NOT EXISTS pokemon(
          id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
          nombre VARCHAR(30) NOT NULL UNIQUE,
          tipo VARCHAR(40) NOT NULL,
          hp INT NOT NULL,
          def INT NOT NULL,
          attk INT NOT NULL,
          speed INT NOT NULL,
          attk_special INT NOT NULL,
          def_special INT NOT NULL
        )
      ''');
      print('Cargando Tabla Pokemon...');
    } catch (error) {
      print('Error al inicializar la tabla pokemon: $error');
    } finally {
      print('Tabla pokemon completada');
    }
  }

  static _crearTablaColeccion(connection) async {
    try {
      await connection!.query('''
        CREATE TABLE IF NOT EXISTS coleccion(
          id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
          id_usuario INT NOT NULL UNIQUE,
          FOREIGN KEY (id_usuario) REFERENCES usuario(idusuario) ON DELETE CASCADE
        )
      ''');
      print('Cargando Tabla Coleccion...');
    } catch (error) {
      print('Error al inicializar la tabla coleccion: $error');
    } finally {
      print('Tabla coleccion completada');
    }
  }

  static _crearTablaColeccionCartas(connection) async {
    try {
      await connection!.query('''
        CREATE TABLE IF NOT EXISTS coleccion_cartas(
          id_coleccion INT NOT NULL,
          id_pokemon INT NOT NULL,
          cantidad INT NOT NULL DEFAULT 1,
          PRIMARY KEY (id_coleccion, id_pokemon),
          FOREIGN KEY (id_coleccion) REFERENCES coleccion(id) ON DELETE CASCADE,
          FOREIGN KEY (id_pokemon) REFERENCES pokemon(id) ON DELETE CASCADE
        )
      ''');
      print('Cargando Tabla Coleccion Cartas...');
    } catch (error) {
      print('Error al inicializar la tabla coleccion_cartas: $error');
    } finally {
      print('Tabla coleccion_cartas completada');
    }
  }
}