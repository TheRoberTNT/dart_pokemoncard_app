import 'db.dart';
import 'menu.dart';

void main() async {
  try {
    await DB.instalarBBDD();
    final conn = await DB.obtenerConexion();
    final menu = Menu(conn);
    menu.menuInicio();
  } catch (e) {
    print('Error inicializando la aplicación: $e');
  }
}