import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../components/my_textfield.dart';
import '../components/my_button.dart';
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
        _mostrarHorarioGenerado(); 
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
      contentPadding: EdgeInsets.all(12), 
      content: SingleChildScrollView(  
        child: Column(
          mainAxisSize: MainAxisSize.min, 
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.9,
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical, 
                child: Table(
                  columnWidths: {
                    0: FlexColumnWidth(1.5),
                    1: FlexColumnWidth(1),
                    2: FlexColumnWidth(1),
                    3: FlexColumnWidth(1),
                    4: FlexColumnWidth(1),
                    5: FlexColumnWidth(1),
                  },
                  border: TableBorder.all(
                    color: const Color.fromARGB(255, 29, 29, 29),
                    width: 1.0,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  children: [
                    TableRow(
                      decoration: BoxDecoration(
                        color: Color(0xFF167BCE), 
                      ),
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
              ),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded( 
                  child: MyButton(
                    onTap: () async {
                      Map<String, String> horarioGenerado = {};
                      for (String dia in ['lunes', 'martes', 'miercoles', 'jueves', 'viernes']) {
                        for (int hora in _horas) {
                          String key = '$dia $hora:00';
                          String? value = _getClassAt(dia, hora);
                          if (value != null) {
                            horarioGenerado[key] = value;
                          } else {
                            horarioGenerado[key] = ''; 
                          }
                        }
                      }
                      String horarioJson = json.encode(horarioGenerado);
                      SharedPreferences prefs = await SharedPreferences.getInstance();
                      await prefs.setString('schedule', horarioJson);
                      print("Horario guardado: $horarioGenerado");
                      Navigator.of(context).pop();
                    },
                    buttonText: 'Guardar',
                    width: 170,
                    height: 45.0,
                    borderRadius: 20.0,
                    color: Color(0xFF167BCE),
                    textColor: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    borderSide: BorderSide(
                      color: Colors.black, 
                      width: 0.5,
                    ),
                  ),
                ),
                SizedBox(width: 10), 
                Expanded( 
                  child: MyButton(
                    onTap: () => Navigator.of(context).pop(),
                    buttonText: 'Cerrar',
                    width: 90,
                    height: 45.0,
                    borderRadius: 20.0,
                    color: Colors.grey,
                    textColor: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    borderSide: BorderSide(
                      color: Colors.black, 
                      width: 0.5,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  },
);
}

String? _getClassAt(String dia, int hora) {
  for (var materia in _materiasAgregadas) {
    if (materia[dia]?.contains(hora) ?? false) {
      return '${materia['nombre']} (${materia['cuatrimestre']}${materia['grupo']})';
    }
  }
  return null; 
}

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
        padding: const EdgeInsets.all(3.0),
        decoration: BoxDecoration(
          color: Color(0xFF4B97D5),
          border: Border.all(color: const Color.fromARGB(255, 29, 29, 29)),
        ),
        child: Text(
          '$abreviatura\n(${materia['cuatrimestre']}${materia['grupo']})',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 9),
        ),
      );
    } else {
      return Container(
        decoration: BoxDecoration(
          border: Border.all(color: const Color.fromARGB(255, 29, 29, 29)),
        ),
        height: 50,
      );
    }
  }

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
        decoration: BoxDecoration(
          color: isSelected ? Color(0xFF4B97D5) : const Color.fromARGB(255, 255, 255, 255),
          border: Border.all(color: const Color.fromARGB(255, 30, 30, 30)),
        ),
        height: 52,
        child: Center(
          child: Text(
            isSelected ? hora.toString() : '',
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color:Color.fromARGB(255, 255, 255, 255),
            ),
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
          color: Color(0xFFB5CEE3),
          border: Border.all(color: const Color.fromARGB(255, 29, 29, 29)),
        ),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 9)
        ),
      ),
    );
  }

  Widget _buildTableHeader(String text) {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          color: Color(0xFFB5CEE3),
          border: Border.all(color: const Color.fromARGB(255, 29, 29, 29)),
        ),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Color.fromARGB(255, 29, 29, 29),
            fontSize: 8
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
  return Scaffold(
    body: Padding(
      padding: const EdgeInsets.all(14.0),
      child: Column(
        children: [
          if (_cuatrimestreAlumno == null)
            MyTextField(
            controller: _cuatrimestreController,
            hintText: 'Cuatrimestre del Alumno (1-15)',
            obscureText: false,
            prefixIcon: const Icon(Icons.numbers),
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
            ],
            onChanged: (value) {
              final numValue = int.tryParse(value);
              if (numValue == null || numValue < 1 || numValue > 15) {
                _cuatrimestreController.text = '';
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Ingrese un número válido entre 1 y 15")),
                );
              }
            },
            width: 400,
            height: 70,
            borderRadius: 15.0,
            hintTextStyle: TextStyle(
              color: Colors.grey,
              fontSize: 16,
            ),
            textStyle: TextStyle(
              color: Colors.black,
              fontSize: 18,
            ),
            enabledBorderSide: BorderSide(
              color: const Color.fromARGB(255, 181, 206, 227),
              width: 0.5,
            ),
            focusedBorderSide: BorderSide(
              color: const Color.fromARGB(255, 75, 151, 213),
              width: 1.5,
            ),
            fillColor: Colors.white,
          ),
          if (_cuatrimestreAlumno == null)
            MyButton(
              onTap: _confirmarCuatrimestre, 
              buttonText: 'Confirmar Cuatrimestre', 
              width: 300,
              height: 45.0, 
              borderRadius: 20.0, 
              color: Color(0xFF167BCE), 
              textColor: Colors.white,
              fontSize: 12, 
              fontWeight: FontWeight.w600, 
              borderSide: BorderSide(
                color: Colors.black, 
                width: 0.5, 
              ),
            ),
          if (_cuatrimestreAlumno != null)
            Row(
              children: [
                Text(
                  "Cuatrimestre del alumno: $_cuatrimestreAlumno",
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
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
                MyTextField(
                controller: _cuatrimestreController,
                hintText: 'Editar Cuatrimestre del Alumno',
                obscureText: false,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                onChanged: (value) {
                  final numValue = int.tryParse(value);
                  if (numValue == null || numValue < 1 || numValue > 15) {
                    _cuatrimestreController.text = '';
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Ingrese un número válido entre 1 y 15")),
                    );
                  }
                },
                width: 400,
                height: 40,
                borderRadius: 15.0,
                hintTextStyle: TextStyle(
                  color: Colors.grey,
                  fontSize: 11,
                ),
                textStyle: TextStyle(
                  color: Colors.black,
                  fontSize: 13,
                ),
                enabledBorderSide: BorderSide(
                  color: const Color.fromARGB(255, 181, 206, 227),
                  width: 0.5,
                ),
                focusedBorderSide: BorderSide(
                  color: const Color.fromARGB(255, 75, 151, 213),
                  width: 1.5,
                ),
                fillColor: Colors.white,
              ),
              const SizedBox(height: 10),
                MyButton(
                  onTap: _confirmarCuatrimestre,
                  buttonText: 'Guardar Cuatrimestre',
                  width: 300,
                  height: 50.0, 
                  borderRadius: 20.0, 
                  color: Color(0xFF167BCE), 
                  textColor: Colors.white,
                  fontSize: 11, 
                  fontWeight: FontWeight.w600, 
                  borderSide: BorderSide(
                    color: Colors.black, 
                    width: 0.5, 
                  ),
                ),
              ],
            ),
          const SizedBox(height: 20),
          if (_cuatrimestreAlumno != null)
            Container(
              width: 300, 
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: Color.fromARGB(255, 58, 58, 58), 
                borderRadius: BorderRadius.circular(20.0), 
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2), 
                    blurRadius: 5.0, 
                    offset: Offset(0, 2), 
                  ),
                ],
              ),
              child: DropdownButton<String>(
                value: _selectedCarrera,
                hint: Text(
                  'Seleccione una carrera',
                  style: TextStyle(
                    color: Colors.white, 
                    fontSize: 11.0,
                    fontWeight: FontWeight.w600,
                  ),
                ),
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
                iconSize: 20, 
                isExpanded: true,
                dropdownColor: const Color.fromARGB(255, 53, 53, 53),
                style: TextStyle(color: Colors.white), 
                iconEnabledColor: Colors.white, 
                underline: SizedBox.shrink(), 
              ),
            ),
          const SizedBox(height: 20),

          if (_cuatrimestreAlumno != null)
            MyTextField(
              controller: _grupoController,
              hintText: 'Grupo (A-Z)',
              obscureText: false,
              keyboardType: TextInputType.text,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^[A-Z]*$')),
              ],
              onChanged: (value) {
                if (!RegExp(r'^[A-Z]*$').hasMatch(value)) {
                  _grupoController.text = '';
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Ingrese únicamente letras mayúsculas (A-Z)")),
                  );
                }
              },
              width: 300,
              height: 50,
              borderRadius: 15.0,
              hintTextStyle: TextStyle(
                color: Colors.grey,
                fontSize: 11,
              ),
              textStyle: TextStyle(
                color: Colors.black,
                fontSize: 11,
              ),
              enabledBorderSide: BorderSide(
                color: const Color.fromARGB(255, 181, 206, 227),
                width: 0.5,
              ),
              focusedBorderSide: BorderSide(
                color: const Color.fromARGB(255, 75, 151, 213),
                width: 1.5,
              ),
              fillColor: Colors.white,
            ),
          const SizedBox(height: 20),
          if (_cuatrimestreAlumno != null)
          Container(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: Color(0xFF4B97D5),
                borderRadius: BorderRadius.circular(20.0),
              ),
              child: Expanded( 
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedMateria,
                    hint: Text(
                      'Seleccione una materia',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11.0,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    items: _materiasDisponibles
                        .map((materia) => DropdownMenuItem<String>(
                              value: materia['nombre'] as String,
                              child: Text(
                                "${materia['nombre']} (Cuat. ${materia['cuatrimestre']})",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 11.0,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedMateria = value;
                      });
                    },
                    iconSize: 24,
                    dropdownColor: Color(0xFF4B97D5),
                    style: TextStyle(color: Colors.white),
                    iconEnabledColor: const Color.fromARGB(255, 255, 255, 255),
                    isExpanded: true, 
                    borderRadius: BorderRadius.circular(8.0),
                    itemHeight: 50.0,
                    menuMaxHeight: 200.0, 
                  ),
                ),
              ),
            ),
          const SizedBox(height: 20),

          if (_cuatrimestreAlumno != null)
            Expanded(
              child: SingleChildScrollView(
                child: _buildHorarioTable(),
              ),
            ),
          const SizedBox(height: 15),
          if (_cuatrimestreAlumno != null)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                MyButton(
                  onTap: _agregarMateria,
                  buttonText: 'Agregar Materia',
                  width: 164,
                  height: 44.0, 
                  borderRadius: 20.0, 
                  color: Color(0xFF4B97D5), 
                  textColor: Colors.white,
                  fontSize: 10, 
                  fontWeight: FontWeight.w600, 
                  borderSide: BorderSide(
                    color: Colors.black, 
                    width: 0.5, 
                  ),
                ),
          MyButton(
                  onTap: _generarHorario,
                  buttonText: 'Generar Horario',
                  width: 164,
                  height: 44.0, 
                  borderRadius: 20.0, 
                  color: Color(0xFF167BCE), 
                  textColor: Colors.white,
                  fontSize: 10, 
                  fontWeight: FontWeight.w600, 
                  borderSide: BorderSide(
                    color: Colors.black, 
                    width: 0.5, 
              ),
           ),
          ],
          ),
          const SizedBox(height: 10),
          if (_materiasAgregadas.isNotEmpty)
          GestureDetector(
            onTap: _mostrarModalMaterias,
            child: Container(
              width: 150,
              height: 50.0,
              decoration: BoxDecoration(
                color: Color(0xFFB5CEE3),
                borderRadius: BorderRadius.circular(20.0),
                border: Border.all(color: const Color.fromARGB(255, 38, 38, 38), width: 0.4),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center, 
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(
                    Icons.list_alt,
                    color: const Color.fromARGB(255, 29, 29, 29),
                    size: 18,
                  ),
                  Text(
                    'Ver materias agregadas',
                    style: const TextStyle(
                      color: Color.fromARGB(255, 68, 68, 68),
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center, 
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

  void _mostrarModalMaterias() {
    showDialog(
  context: context,
  builder: (BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0), 
      ),
      title: Text(
        'Materias Seleccionadas',
        style: TextStyle(
          color: Color(0xFF167BCE), 
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
      content: _materiasAgregadas.isEmpty
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.info_outline,
                  color: Color.fromARGB(255, 206, 22, 22), 
                  size: 30,
                ),
                const SizedBox(width: 10),
                const Text(
                  'No has seleccionado ninguna materia.',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            )
          : SizedBox(
              width: double.maxFinite,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _materiasAgregadas.length,
                itemBuilder: (context, index) {
                  final materia = _materiasAgregadas[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 5.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    elevation: 3,
                    child: ListTile(
                      contentPadding: EdgeInsets.all(10.0),
                      title: Text(
                        materia['nombre'],
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF167BCE), 
                        ),
                      ),
                      subtitle: Text(
                        'Cuatrimestre: ${materia['cuatrimestre']}',
                        style: TextStyle(
                          color: Color(0xFF167BCE).withOpacity(0.7), 
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
      actions: [
        GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: Container(
            width: 162,
            height: 50.0,
            decoration: BoxDecoration(
              color: Color(0xFF167BCE), 
              borderRadius: BorderRadius.circular(20.0),
              border: Border.all(color: Colors.black, width: 0.5),
            ),
            child: Center(
              child: Text(
                'Cerrar',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  },
);
}
}