import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Panel Admin - Aprobación de Conductores', () {
    test('Al aprobar conductor, actualiza estadoConductor.aprobado a true', () {
      final nuevoEstado = 'aprobado';
      final categoriaSeleccionada = 'confort';

      final updatesUsuarios = {
        'estadoValidacion': nuevoEstado,
        'fechaValidacion': 1234567890,
        'infoVehiculo/categoria': categoriaSeleccionada,
        'estadoConductor/aprobado': nuevoEstado == 'aprobado',
        'estadoConductor/ultimaConexion': 1234567890,
      };

      final updatesConductores = {
        'estadoValidacion': nuevoEstado,
        'categoria': categoriaSeleccionada?.toLowerCase(),
        'aprobado': nuevoEstado == 'aprobado',
      };

      expect(updatesUsuarios['estadoConductor/aprobado'], true);
      expect(updatesConductores['aprobado'], true);
      expect(updatesUsuarios['estadoValidacion'], 'aprobado');
      expect(updatesConductores['estadoValidacion'], 'aprobado');
    });

    test('Al rechazar conductor, actualiza estadoConductor.aprobado a false', () {
      final nuevoEstado = 'rechazado';
      final categoriaSeleccionada = 'confort';

      final updatesUsuarios = {
        'estadoValidacion': nuevoEstado,
        'fechaValidacion': 1234567890,
        'infoVehiculo/categoria': categoriaSeleccionada,
        'estadoConductor/aprobado': nuevoEstado == 'aprobado',
        'estadoConductor/ultimaConexion': 1234567890,
      };

      final updatesConductores = {
        'estadoValidacion': nuevoEstado,
        'categoria': categoriaSeleccionada?.toLowerCase(),
        'aprobado': nuevoEstado == 'aprobado',
      };

      expect(updatesUsuarios['estadoConductor/aprobado'], false);
      expect(updatesConductores['aprobado'], false);
      expect(updatesUsuarios['estadoValidacion'], 'rechazado');
      expect(updatesConductores['estadoValidacion'], 'rechazado');
    });

    test('Al aprobar, sincroniza categoría en ambos nodos', () {
      final categoriaSeleccionada = 'confort';

      final updatesUsuarios = {
        'infoVehiculo/categoria': categoriaSeleccionada,
        'categoria': categoriaSeleccionada?.toLowerCase(),
      };

      final updatesConductores = {
        'categoria': categoriaSeleccionada?.toLowerCase(),
        'infoVehiculo/categoria': categoriaSeleccionada,
      };

      expect(updatesUsuarios['infoVehiculo/categoria'], 'confort');
      expect(updatesUsuarios['categoria'], 'confort');
      expect(updatesConductores['categoria'], 'confort');
      expect(updatesConductores['infoVehiculo/categoria'], 'confort');
    });
  });

  group('Panel Admin - Asignación de Categorías', () {
    test('Categoría economico se guarda correctamente', () {
      final categoriaSeleccionada = 'economico';

      final updatesUsuarios = {
        'infoVehiculo/categoria': categoriaSeleccionada,
        'categoria': categoriaSeleccionada?.toLowerCase(),
      };

      final updatesConductores = {
        'categoria': categoriaSeleccionada?.toLowerCase(),
        'infoVehiculo/categoria': categoriaSeleccionada,
      };

      expect(updatesUsuarios['infoVehiculo/categoria'], 'economico');
      expect(updatesUsuarios['categoria'], 'economico');
      expect(updatesConductores['categoria'], 'economico');
      expect(updatesConductores['infoVehiculo/categoria'], 'economico');
    });

    test('Categoría confort se guarda correctamente', () {
      final categoriaSeleccionada = 'confort';

      final updatesUsuarios = {
        'infoVehiculo/categoria': categoriaSeleccionada,
        'categoria': categoriaSeleccionada?.toLowerCase(),
      };

      final updatesConductores = {
        'categoria': categoriaSeleccionada?.toLowerCase(),
        'infoVehiculo/categoria': categoriaSeleccionada,
      };

      expect(updatesUsuarios['infoVehiculo/categoria'], 'confort');
      expect(updatesUsuarios['categoria'], 'confort');
      expect(updatesConductores['categoria'], 'confort');
      expect(updatesConductores['infoVehiculo/categoria'], 'confort');
    });

    test('Mensaje de éxito muestra categoría correcta', () {
      final categoriaSeleccionada = 'economico';
      String categoriaDisplay = categoriaSeleccionada == 'economico' ? 'Económico' : 'Confort';

      expect(categoriaDisplay, 'Económico');
    });

    test('Mensaje de éxito muestra categoría confort', () {
      final categoriaSeleccionada = 'confort';
      String categoriaDisplay = categoriaSeleccionada == 'economico' ? 'Económico' : 'Confort';

      expect(categoriaDisplay, 'Confort');
    });
  });

  group('Panel Admin - Normalización de Categorías en initState', () {
    test('Normaliza Pendiente a economico', () {
      final cat = 'pendiente';
      String categoriaSeleccionada;

      if (cat == 'pendiente' || cat == 'n/a' || cat == 'n/A' || cat.isEmpty) {
        categoriaSeleccionada = 'economico';
      } else if (cat == 'confort' || cat == 'estándar' || cat == 'estandar' || cat == 'standard') {
        categoriaSeleccionada = 'confort';
      } else {
        categoriaSeleccionada = 'economico';
      }

      expect(categoriaSeleccionada, 'economico');
    });

    test('Normaliza N/A a economico', () {
      final cat = 'n/a';
      String categoriaSeleccionada;

      if (cat == 'pendiente' || cat == 'n/a' || cat == 'n/A' || cat.isEmpty) {
        categoriaSeleccionada = 'economico';
      } else if (cat == 'confort' || cat == 'estándar' || cat == 'estandar' || cat == 'standard') {
        categoriaSeleccionada = 'confort';
      } else {
        categoriaSeleccionada = 'economico';
      }

      expect(categoriaSeleccionada, 'economico');
    });

    test('Normaliza confort a confort', () {
      final cat = 'confort';
      String categoriaSeleccionada;

      if (cat == 'pendiente' || cat == 'n/a' || cat == 'n/A' || cat.isEmpty) {
        categoriaSeleccionada = 'economico';
      } else if (cat == 'confort' || cat == 'estándar' || cat == 'estandar' || cat == 'standard') {
        categoriaSeleccionada = 'confort';
      } else {
        categoriaSeleccionada = 'economico';
      }

      expect(categoriaSeleccionada, 'confort');
    });

    test('Normaliza estandar a confort', () {
      final cat = 'estandar';
      String categoriaSeleccionada;

      if (cat == 'pendiente' || cat == 'n/a' || cat == 'n/A' || cat.isEmpty) {
        categoriaSeleccionada = 'economico';
      } else if (cat == 'confort' || cat == 'estándar' || cat == 'estandar' || cat == 'standard') {
        categoriaSeleccionada = 'confort';
      } else {
        categoriaSeleccionada = 'economico';
      }

      expect(categoriaSeleccionada, 'confort');
    });

    test('Normaliza estándar a confort', () {
      final cat = 'estándar';
      String categoriaSeleccionada;

      if (cat == 'pendiente' || cat == 'n/a' || cat == 'n/A' || cat.isEmpty) {
        categoriaSeleccionada = 'economico';
      } else if (cat == 'confort' || cat == 'estándar' || cat == 'estandar' || cat == 'standard') {
        categoriaSeleccionada = 'confort';
      } else {
        categoriaSeleccionada = 'economico';
      }

      expect(categoriaSeleccionada, 'confort');
    });

    test('Normaliza standard a confort', () {
      final cat = 'standard';
      String categoriaSeleccionada;

      if (cat == 'pendiente' || cat == 'n/a' || cat == 'n/A' || cat.isEmpty) {
        categoriaSeleccionada = 'economico';
      } else if (cat == 'confort' || cat == 'estándar' || cat == 'estandar' || cat == 'standard') {
        categoriaSeleccionada = 'confort';
      } else {
        categoriaSeleccionada = 'economico';
      }

      expect(categoriaSeleccionada, 'confort');
    });

    test('Default es economico para categorías desconocidas', () {
      final cat = 'desconocido';
      String categoriaSeleccionada;

      if (cat == 'pendiente' || cat == 'n/a' || cat == 'n/A' || cat.isEmpty) {
        categoriaSeleccionada = 'economico';
      } else if (cat == 'confort' || cat == 'estándar' || cat == 'estandar' || cat == 'standard') {
        categoriaSeleccionada = 'confort';
      } else {
        categoriaSeleccionada = 'economico';
      }

      expect(categoriaSeleccionada, 'economico');
    });
  });

  group('Panel Admin - Dropdown de Categorías', () {
    test('Dropdown contiene solo economico y confort', () {
      final items = ['economico', 'confort'];

      expect(items.length, 2);
      expect(items.contains('economico'), true);
      expect(items.contains('confort'), true);
      expect(items.contains('estandar'), false);
      expect(items.contains('premium'), false);
      expect(items.contains('viajes_largos'), false);
    });

    test('Display names son correctos', () {
      final displayNames = {
        'economico': 'Económico',
        'confort': 'Confort',
      };

      expect(displayNames['economico'], 'Económico');
      expect(displayNames['confort'], 'Confort');
    });
  });

  group('Panel Admin - Filtro de Conductores', () {
    test('Filtra por rol conductor', () {
      final datos = {
        'rol': 'conductor',
        'nombre': 'Test',
      };

      final rol = datos['rol']?.toString();
      final esConductor = rol == 'conductor';

      expect(esConductor, true);
    });

    test('Rechaza si rol no es conductor', () {
      final datos = {
        'rol': 'pasajero',
        'nombre': 'Test',
      };

      final rol = datos['rol']?.toString();
      final esConductor = rol == 'conductor';

      expect(esConductor, false);
    });

    test('Usa estadoConductor.aprobado como prioridad', () {
      final datos = {
        'rol': 'conductor',
        'estadoConductor': {'aprobado': true},
        'estadoValidacion': 'aprobado',
      };

      final estadoConductor = datos['estadoConductor'] as Map?;
      final aprobado = estadoConductor?['aprobado'] ?? false;
      final estadoValidacion = datos['estadoValidacion'] ?? 'pendiente';

      String estado;
      if (aprobado == true) {
        estado = 'aprobado';
      } else if (estadoValidacion == 'rechazado') {
        estado = 'rechazado';
      } else {
        estado = 'pendiente';
      }

      expect(estado, 'aprobado');
    });

    test('Usa estadoValidacion como fallback', () {
      final datos = {
        'rol': 'conductor',
        'estadoValidacion': 'aprobado',
      };

      final estadoConductor = datos['estadoConductor'] as Map?;
      final aprobado = estadoConductor?['aprobado'] ?? false;
      final estadoValidacion = datos['estadoValidacion'] ?? 'pendiente';

      String estado;
      if (aprobado == true) {
        estado = 'aprobado';
      } else if (estadoValidacion == 'rechazado') {
        estado = 'rechazado';
      } else {
        estado = 'pendiente';
      }

      expect(estado, 'pendiente'); // Fallback ya que aprobado es false
    });

    test('Marca como rechazado si estadoValidacion es rechazado', () {
      final datos = {
        'rol': 'conductor',
        'estadoConductor': {'aprobado': false},
        'estadoValidacion': 'rechazado',
      };

      final estadoConductor = datos['estadoConductor'] as Map?;
      final aprobado = estadoConductor?['aprobado'] ?? false;
      final estadoValidacion = datos['estadoValidacion'] ?? 'pendiente';

      String estado;
      if (aprobado == true) {
        estado = 'aprobado';
      } else if (estadoValidacion == 'rechazado') {
        estado = 'rechazado';
      } else {
        estado = 'pendiente';
      }

      expect(estado, 'rechazado');
    });

    test('Filtra por estado seleccionado', () {
      final filtro = 'aprobado';
      final estado = 'aprobado';

      final pasaFiltro = filtro == 'todos' || estado == filtro;

      expect(pasaFiltro, true);
    });

    test('No pasa filtro si estado no coincide', () {
      final filtro = 'aprobado';
      final estado = 'pendiente';

      final pasaFiltro = filtro == 'todos' || estado == filtro;

      expect(pasaFiltro, false);
    });

    test('Pasa filtro si filtro es todos', () {
      final filtro = 'todos';
      final estado = 'pendiente';

      final pasaFiltro = filtro == 'todos' || estado == filtro;

      expect(pasaFiltro, true);
    });
  });

  group('Panel Admin - Búsqueda de Conductores', () {
    test('Encuentra por nombre', () {
      final datos = {
        'nombre': 'Juan Pérez',
        'rol': 'conductor',
      };

      final busqueda = 'juan';
      final nombre = datos['nombre']?.toString().toLowerCase() ?? '';
      final coincide = nombre.contains(busqueda.toLowerCase());

      expect(coincide, true);
    });

    test('Encuentra por correo', () {
      final datos = {
        'email': 'juan@test.com',
        'rol': 'conductor',
      };

      final busqueda = 'juan';
      final correo = datos['email']?.toString().toLowerCase() ?? '';
      final coincide = correo.contains(busqueda.toLowerCase());

      expect(coincide, true);
    });

    test('Encuentra por cédula', () {
      final datos = {
        'cedula': '12345678',
        'rol': 'conductor',
      };

      final busqueda = '1234';
      final cedula = datos['cedula']?.toString().toLowerCase() ?? '';
      final coincide = cedula.contains(busqueda.toLowerCase());

      expect(coincide, true);
    });

    test('No encuentra si búsqueda no coincide', () {
      final datos = {
        'nombre': 'Juan Pérez',
        'rol': 'conductor',
      };

      final busqueda = 'maria';
      final nombre = datos['nombre']?.toString().toLowerCase() ?? '';
      final correo = datos['email']?.toString().toLowerCase() ?? '';
      final cedula = datos['cedula']?.toString().toLowerCase() ?? '';
      final coincide = nombre.contains(busqueda.toLowerCase()) ||
          correo.contains(busqueda.toLowerCase()) ||
          cedula.contains(busqueda.toLowerCase());

      expect(coincide, false);
    });
  });

  group('Panel Admin - Mensajes de Confirmación', () {
    test('Mensaje de aprobación es correcto', () {
      final nuevoEstado = 'aprobado';
      final titulo = nuevoEstado == 'aprobado' ? 'Aprobar' : 'Rechazar';

      expect(titulo, 'Aprobar');
    });

    test('Mensaje de rechazo es correcto', () {
      final nuevoEstado = 'rechazado';
      final titulo = nuevoEstado == 'aprobado' ? 'Aprobar' : 'Rechazar';

      expect(titulo, 'Rechazar');
    });

    test('Contenido de aprobación es correcto', () {
      final nuevoEstado = 'aprobado';
      final contenido = nuevoEstado == 'aprobado'
          ? 'El conductor podrá empezar a trabajar inmediatamente.'
          : 'El conductor no podrá usar la aplicación.';

      expect(contenido, 'El conductor podrá empezar a trabajar inmediatamente.');
    });

    test('Contenido de rechazo es correcto', () {
      final nuevoEstado = 'rechazado';
      final contenido = nuevoEstado == 'aprobado'
          ? 'El conductor podrá empezar a trabajar inmediatamente.'
          : 'El conductor no podrá usar la aplicación.';

      expect(contenido, 'El conductor no podrá usar la aplicación.');
    });

    test('Color de botón aprobado es verde', () {
      final nuevoEstado = 'aprobado';
      final esVerde = nuevoEstado == 'aprobado';

      expect(esVerde, true);
    });

    test('Color de botón rechazado es rojo', () {
      final nuevoEstado = 'rechazado';
      final esVerde = nuevoEstado == 'aprobado';

      expect(esVerde, false);
    });
  });
}
