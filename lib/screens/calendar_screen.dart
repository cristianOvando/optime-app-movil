import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  _CalendarScreenState createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  Map<String, String> _horarioGenerado = {};

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadSchedule();
  }

  // Cargar el horario desde SharedPreferences
  Future<void> _loadSchedule() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? horarioJson = prefs.getString('schedule');

    if (horarioJson != null) {
      Map<String, String> loadedSchedule = Map<String, String>.from(jsonDecode(horarioJson));
      print("Horario cargado: $loadedSchedule"); // Depuración
      setState(() {
        _horarioGenerado = loadedSchedule;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No hay horario guardado.")),
      );
    }
  }

  // Función para construir la tabla del horario
  Widget _buildHorarioTable() {
    final horas = List.generate(12, (index) => index + 8); // Horas de 8:00 a 19:00

    return Table(
      border: TableBorder.all(color: Colors.transparent), // Borde de la tabla transparente
      columnWidths: {
        0: FixedColumnWidth(120), // Fija el tamaño de la columna de "Hora"
        1: FixedColumnWidth(100), // Fija el tamaño de las columnas de los días
        2: FixedColumnWidth(100),
        3: FixedColumnWidth(100),
        4: FixedColumnWidth(100),
        5: FixedColumnWidth(100),
      },
      children: [
        TableRow(
          decoration: BoxDecoration(
            color: Colors.blueGrey.shade800, // Fondo gris oscuro para el encabezado
            borderRadius: BorderRadius.circular(8), // Bordes redondeados
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
        ...horas.map((hora) {
          return TableRow(
            decoration: BoxDecoration(
              color: hora.isEven ? Colors.grey.shade100 : Colors.white, // Alternar colores de filas
              borderRadius: BorderRadius.circular(8), // Bordes redondeados
            ),
            children: [
              _buildTableCell('$hora:00 - ${hora + 1}:00'),
              _buildHorarioCell('lunes', hora),
              _buildHorarioCell('martes', hora),
              _buildHorarioCell('miercoles', hora),
              _buildHorarioCell('jueves', hora),
              _buildHorarioCell('viernes', hora),
            ],
          );
        }).toList(),
      ],
    );
  }

  // Construir celda de la tabla
  Widget _buildTableCell(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Colors.black87, // Color de texto más suave
        ),
      ),
    );
  }

  // Construir celda de día (Lunes, Martes, etc.)
  Widget _buildHorarioCell(String dia, int hora) {
    final key = '$dia ${hora}:00'; // Generar clave para buscar en el horario
    final materia = _horarioGenerado[key];

    return Container(
      padding: const EdgeInsets.all(8.0),
      height: 50, // Establecer altura fija para las celdas
      decoration: BoxDecoration(
        border: Border.all(color: Colors.blueGrey.shade200), // Borde suave de color gris claro
        borderRadius: BorderRadius.circular(8),
        color: materia != null && materia.isNotEmpty
            ? Colors.lightBlueAccent // Celda con materia en azul
            : Colors.white, // Celda vacía en blanco
        boxShadow: materia != null && materia.isNotEmpty
            ? [BoxShadow(color: Colors.blueAccent.shade100, blurRadius: 4)] // Sombra suave para celdas con materia
            : [],
      ),
      child: Center(
        child: Text(
          materia ?? '', // Si hay una materia, se muestra el nombre
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
        ),
      ),
    );
  }

  // Construir el encabezado de la tabla
  Widget _buildTableHeader(String text) {
    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Pantalla de mi horario'),
    );
  }
}