// ignore_for_file: unnecessary_getters_setters

import 'db.dart';


class Usuario{
  String? _user;
  String? _password;

  String? get user => _user;
  String? get password => _password;

  set user (String? user){
    _user = user;
  }

  set password (String? password){
    _password = password;
  }

  static Future<bool> comprobarSiExisteUsuario(String nombre) async {
    bool existe = true;
    var conn;
    try {
      conn = await DB.obtenerConexion();
      var registros =
        await conn.query("SELECT * FROM usuario WHERE nombre = ?", [nombre]);
      if(registros.length == 0){
        existe = false;
      }
    } catch (e) {
      print (e);
    } finally {
      conn.close();
    }
    return existe;
  }
}