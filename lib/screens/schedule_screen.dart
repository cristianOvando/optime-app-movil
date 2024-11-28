import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  _ScheduleScreenState createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  final TextEditingController _cuatrimestreController = TextEditingController();
  final TextEditingController _grupoController = TextEditingController();
  String? _selectedMateria;
  String? _selectedCarrera;
  int? _cuatrimestreAlumno;
  bool _editCuatrimestre = false;
  List<Map<String, dynamic>> _materiasAgregadas = [];
  List<Map<String, dynamic>> _materiasDisponibles = [];
  List<Map<String, dynamic>> _horarioGenerado = [];

  Map<String, List<int>> _horarioSeleccionado = {
    "lunes": [],
    "martes": [],
    "miercoles": [],
    "jueves": [],
    "viernes": [],
  };

  final List<int> _horas = List.generate(12, (index) => index + 8);

  /// Alternar selección de celdas de la tabla de horario
  void _toggleHorario(String dia, int hora) {
    setState(() {
      if (_horarioSeleccionado[dia]!.contains(hora)) {
        _horarioSeleccionado[dia]!.remove(hora);
      } else {
        _horarioSeleccionado[dia]!.add(hora);
        _horarioSeleccionado[dia]!.sort();
      }
    });
  }

  /// Cargar materias desde el servidor según el mapId seleccionado
  Future<void> _fetchMaterias(int mapId) async {
    const url = 'https://q3hinyahkg6ypwbfpmqszonexa0zhkzf.lambda-url.us-east-1.on.aws/';
    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({"map_id": mapId}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        _materiasDisponibles = List<Map<String, dynamic>>.from(
          data['mapa_curricular'].map((materia) => {
                "nombre": materia['nombre'],
                "cuatrimestre": materia['cuatrimestre'],
              }),
        );
        _selectedMateria = null;
      });
    } else {
      debugPrint('Error al cargar materias: ${response.statusCode}');
    }
  }

  /// Confirmar el cuatrimestre ingresado
  void _confirmarCuatrimestre() {
    final cuatrimestre = int.tryParse(_cuatrimestreController.text);
    if (cuatrimestre != null && cuatrimestre >= 1 && cuatrimestre <= 15) {
      setState(() {
        _cuatrimestreAlumno = cuatrimestre;
        _editCuatrimestre = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Cuatrimestre $cuatrimestre confirmado.")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Por favor, ingrese un cuatrimestre válido (1-15).")),
      );
    }
  }

  /// Agregar una materia al JSON local
  void _agregarMateria() {
    if (_cuatrimestreAlumno == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Por favor, confirme el cuatrimestre del alumno antes de continuar.")),
      );
      return;
    }

    if (_grupoController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Por favor, ingrese el grupo.")),
      );
      return;
    }

    if (_selectedMateria == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Por favor, seleccione una materia.")),
      );
      return;
    }

    final materiaSeleccionada = _materiasDisponibles.firstWhere(
      (materia) => materia['nombre'] == _selectedMateria,
      orElse: () => {},
    );

    if (materiaSeleccionada.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error al encontrar la materia seleccionada.")),
      );
      return;
    }

    final nuevaMateria = {
      "nombre": materiaSeleccionada['nombre'],
      "cuatrimestre": materiaSeleccionada['cuatrimestre'],
      "grupo": _grupoController.text.toUpperCase(),
      "lunes": List<int>.from(_horarioSeleccionado['lunes']!),
      "martes": List<int>.from(_horarioSeleccionado['martes']!),
      "miercoles": List<int>.from(_horarioSeleccionado['miercoles']!),
      "jueves": List<int>.from(_horarioSeleccionado['jueves']!),
      "viernes": List<int>.from(_horarioSeleccionado['viernes']!),
    };

    setState(() {
      _materiasAgregadas.add(nuevaMateria);
      _horarioSeleccionado = {
        "lunes": [],
        "martes": [],
        "miercoles": [],
        "jueves": [],
        "viernes": [],
      };
      _selectedMateria = null;
      _grupoController.clear();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Materia '${nuevaMateria['nombre']}' agregada.")),
    );
  }

  /// Generar horario y mostrar tabla de respuesta
  Future<void> _generarHorario() async {
    if (_materiasAgregadas.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No hay materias cargadas para generar el horario.")),
      );
      return;
    }

    final json = {
      "cuatrimestre_alumno": _cuatrimestreAlumno,
      "materias": _materiasAgregadas,
    };

    const url = 'https://agoptimecreate.azurewebsites.net/api/genetico?code=mkhKsHY0zupMwpr536oyDHD1T4EPx5ivIDO7zNV2ON4JAzFuCGDNMQ%3D%3D';

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(json),
      );

      if (response.statusCode == 200) {
        setState(() {
          _horarioGenerado = List<Map<String, dynamic>>.from(jsonDecode(response.body));
        });
        print("Horario cargado después de setState: $_horarioGenerado");
        _mostrarHorarioGenerado(); // Mostrar tabla con horario generado
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error al generar el horario: ${response.statusCode}")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error al conectar con el servidor.")),
      );
    }
  }


void _mostrarHorarioGenerado() {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text("Horario Generado"),
        content: SingleChildScrollView(
          child: SizedBox(
            width: MediaQuery.of(context).size.width * 0.9,
            child: Column(
              children: [
                Table(
                  border: TableBorder.all(color: Colors.black),
                  children: [
                    TableRow(
                      children: [
                        _buildTableHeader('Hora'),
                        _buildTableHeader('Lun'),
                        _buildTableHeader('Mar'),
                        _buildTableHeader('Mié'),
                        _buildTableHeader('Jue'),
                        _buildTableHeader('Vie'),
                      ],
                    ),
                    ..._horas.map((hora) {
                      return TableRow(
                        children: [
                          _buildTableCell('$hora:00 - ${hora + 1}:00'),
                          _buildHorarioGeneradoCell('lunes', hora),
                          _buildHorarioGeneradoCell('martes', hora),
                          _buildHorarioGeneradoCell('miercoles', hora),
                          _buildHorarioGeneradoCell('jueves', hora),
                          _buildHorarioGeneradoCell('viernes', hora),
                        ],
                      );
                    }),
                  ],
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              // 1. Crear un mapa vacío para guardar el horario
              Map<String, String> horarioGenerado = {};

              // 2. Recorrer todos los días de la semana y todas las horas
              for (String dia in ['lunes', 'martes', 'miercoles', 'jueves', 'viernes']) {
                for (int hora in _horas) {
                  // Crear la clave para el horario
                  String key = '$dia $hora:00';
                  // Obtener la clase para esa hora y día
                  String? value = _getClassAt(dia, hora);
                  
                  if (value != null) {
                    // Si hay una clase para esa hora y día, agregarla al mapa
                    horarioGenerado[key] = value;
                  } else {
                    // Si no hay clase, lo dejamos vacío o con algún valor por defecto
                    horarioGenerado[key] = '';  // O puedes dejarlo como null, dependiendo de cómo quieras gestionar los horarios vacíos
                  }
                }
              }

              // 3. Convertir el horario generado a JSON (cadena)
              String horarioJson = json.encode(horarioGenerado);

              // 4. Obtener las preferencias compartidas
              SharedPreferences prefs = await SharedPreferences.getInstance();

              // 5. Guardar el horario completo en SharedPreferences
              await prefs.setString('schedule', horarioJson);

              // 6. Mostrar el horario guardado en la consola
              print("Horario guardado: $horarioGenerado");

              // 7. Cerrar el diálogo después de guardar
              Navigator.of(context).pop();
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: Colors.green, // Color distintivo
            ),
            child: const Text("Guardar"),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("Cerrar"),
          ),
        ],
      );
    },
  );
}

// Función para obtener la clase en una hora específica
String? _getClassAt(String dia, int hora) {
  // Buscar en la lista de materias agregadas
  for (var materia in _materiasAgregadas) {
    // Verificar si la materia está programada en ese día y hora
    if (materia[dia]?.contains(hora) ?? false) {
      return '${materia['nombre']} (${materia['cuatrimestre']}${materia['grupo']})'; // Devolver la materia con su grupo
    }
  }
  return null; // Si no hay clase en ese día y hora, devolver null
}

  /// Celdas de horario generado (respuesta del servidor)
  Widget _buildHorarioGeneradoCell(String dia, int hora) {
    final materia = _horarioGenerado.firstWhere(
      (materia) => materia[dia].contains(hora),
      orElse: () => {},
    );

    if (materia.isNotEmpty) {
      final abreviatura = materia['nombre']
          .split(' ')
          .map((word) => word[0])
          .join()
          .toUpperCase();
      return Container(
        padding: const EdgeInsets.all(4.0),
        decoration: BoxDecoration(
          color: Colors.lightBlueAccent,
          border: Border.all(color: Colors.black),
        ),
        child: Text(
          '$abreviatura\n(${materia['cuatrimestre']}${materia['grupo']})',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 10),
        ),
      );
    } else {
      return Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black),
        ),
        height: 40,
      );
    }
  }

  /// Construir la tabla de horario interactivo
  Widget _buildHorarioTable() {
    return Column(
      children: [
        Row(
          children: [
            _buildTableHeader('Hora'),
            _buildTableHeader('Lunes'),
            _buildTableHeader('Martes'),
            _buildTableHeader('Miércoles'),
            _buildTableHeader('Jueves'),
            _buildTableHeader('Viernes'),
          ],
        ),
        ..._horas.map((hora) {
          return Row(
            children: [
              _buildTableCell('$hora:00 - ${hora + 1}:00'),
              _buildHorarioCell('lunes', hora),
              _buildHorarioCell('martes', hora),
              _buildHorarioCell('miercoles', hora),
              _buildHorarioCell('jueves', hora),
              _buildHorarioCell('viernes', hora),
            ],
          );
        }),
      ],
    );
  }

  Widget _buildHorarioCell(String dia, int hora) {
    final isSelected = _horarioSeleccionado[dia]!.contains(hora);
    return Expanded(
      child: GestureDetector(
        onTap: () => _toggleHorario(dia, hora),
        child: Container(
          margin: const EdgeInsets.all(4.0),
          decoration: BoxDecoration(
            color: isSelected ? Colors.blueAccent : Colors.grey[300],
            border: Border.all(color: Colors.black),
          ),
          height: 40,
          child: Center(
            child: Text(
              isSelected ? hora.toString() : '',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTableCell(String text) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          border: Border.all(color: Colors.black),
        ),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 12)
        ),
      ),
    );
  }

  Widget _buildTableHeader(String text) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: Colors.blueAccent,
          border: Border.all(color: Colors.black),
        ),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 9
          ),
        ),
      ),
    );
  }

  

  @override
  Widget build(BuildContext context) {
  return Scaffold(
    body: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          if (_cuatrimestreAlumno == null)
            TextField(
              controller: _cuatrimestreController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Cuatrimestre del Alumno (1-15)',
                border: OutlineInputBorder(),
              ),
            ),
          if (_cuatrimestreAlumno == null)
            ElevatedButton(
              onPressed: _confirmarCuatrimestre,
              child: const Text("Confirmar Cuatrimestre"),
            ),
          if (_cuatrimestreAlumno != null)
            Row(
              children: [
                Text(
                  "Cuatrimestre del Alumno: $_cuatrimestreAlumno",
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () {
                    setState(() {
                      _editCuatrimestre = true;
                      _cuatrimestreController.text = _cuatrimestreAlumno.toString();
                    });
                  },
                ),
              ],
            ),
          if (_editCuatrimestre)
            Column(
              children: [
                TextField(
                  controller: _cuatrimestreController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Editar Cuatrimestre del Alumno',
                    border: OutlineInputBorder(),
                  ),
                ),
                ElevatedButton(
                  onPressed: _confirmarCuatrimestre,
                  child: const Text("Guardar Cuatrimestre"),
                ),
              ],
            ),
          const SizedBox(height: 16),

          if (_cuatrimestreAlumno != null)
            DropdownButton<String>(
              value: _selectedCarrera,
              hint: const Text('Seleccione una carrera'),
              items: const [
                DropdownMenuItem(value: '1', child: Text('Ing. en Software')),
                DropdownMenuItem(value: '2', child: Text('Ing. en Biomédica')),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedCarrera = value;
                  _fetchMaterias(int.parse(value!));
                });
              },
            ),
          const SizedBox(height: 16),

          if (_cuatrimestreAlumno != null)
            TextField(
              controller: _grupoController,
              decoration: const InputDecoration(
                labelText: 'Grupo (A-Z)',
                border: OutlineInputBorder(),
              ),
            ),
          const SizedBox(height: 16),

          if (_cuatrimestreAlumno != null)
            DropdownButton<String>(
              value: _selectedMateria,
              hint: const Text('Seleccione una materia'),
              items: _materiasDisponibles
                  .map((materia) => DropdownMenuItem(
                        value: materia['nombre'] as String,
                        child: Text("${materia['nombre']} (Cuat. ${materia['cuatrimestre']})"),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _selectedMateria = value;
                });
              },
              iconSize: 15,  // Ajusta el tamaño del ícono
              isExpanded: true,  // Asegura que el DropdownButton ocupe todo el espacio disponible
            ),
          const SizedBox(height: 16),

          if (_cuatrimestreAlumno != null)
            Expanded(
              child: SingleChildScrollView(
                child: _buildHorarioTable(),
              ),
            ),
          const SizedBox(height: 16),

          if (_cuatrimestreAlumno != null)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: _agregarMateria,
                  child: const Text('Agregar Materia'),
                ),
                ElevatedButton(
                  onPressed: _generarHorario,
                  child: const Text('Generar Horario'),
                ),
              ],
            ),
          const SizedBox(height: 16),

          if (_materiasAgregadas.isNotEmpty)
            ElevatedButton(
              onPressed: _mostrarModalMaterias,
              child: const Text('Ver Materias Seleccionadas'),
            ),
        ],
      ),
    ),
  );
}


  void _mostrarModalMaterias() {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Materias Seleccionadas'),
        content: _materiasAgregadas.isEmpty
            ? const Text('No has seleccionado ninguna materia.')
            : SizedBox(
                width: double.maxFinite,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _materiasAgregadas.length,
                  itemBuilder: (context, index) {
                    final materia = _materiasAgregadas[index];
                    return ListTile(
                      title: Text(materia['nombre']),
                      subtitle: Text('Cuatrimestre: ${materia['cuatrimestre']}'),
                    );
                  },
                ),
              ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cerrar'),
          ),
        ],
      );
    },
  );
}

}