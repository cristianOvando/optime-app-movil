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

  Future<void> _loadSchedule() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? horarioJson = prefs.getString('schedule');

    if (horarioJson != null) {
      Map<String, String> loadedSchedule =
          Map<String, String>.from(jsonDecode(horarioJson));
      print("Horario cargado: $loadedSchedule");
      setState(() {
        _horarioGenerado = loadedSchedule;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No hay horario guardado.")),
      );
    }
  }

  Widget _buildHorarioTable() {
    final horas = List.generate(8, (index) => index + 8);

    return Table(
      border: TableBorder.all(color: const Color.fromARGB(255, 28, 28, 28)),
      columnWidths: {
        0: FixedColumnWidth(80),
        1: FixedColumnWidth(100),
        2: FixedColumnWidth(100),
        3: FixedColumnWidth(100),
        4: FixedColumnWidth(100),
        5: FixedColumnWidth(100),
      },
      children: [
        TableRow(
          decoration: BoxDecoration(
            color: const Color(0xFFB5CEE3),
            borderRadius: BorderRadius.circular(8),
          ),
          children: [
            _buildTableHeader('Hora'),
            _buildTableHeader('Lunes'),
            _buildTableHeader('Martes'),
            _buildTableHeader('Miércoles'),
            _buildTableHeader('Jueves'),
            _buildTableHeader('Viernes'),
          ],
        ),
        ...horas.map((hora) {
          return TableRow(
            decoration: const BoxDecoration(
              color: Color(0xFFB5CEE3),
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

  Widget _buildTableCell(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: Color.fromARGB(255, 29, 29, 29),
        ),
      ),
    );
  }

  Widget _buildHorarioCell(String dia, int hora) {
    final key = '$dia ${hora}:00';
    final materia = _horarioGenerado[key];

    return Container(
      padding: const EdgeInsets.all(8.0),
      height: 70,
      decoration: BoxDecoration(
        color: materia != null && materia.isNotEmpty
            ? const Color(0xFF4B97D5)
            : const Color.fromARGB(255, 228, 228, 228),
      ),
      child: Center(
        child: Text(
          materia ?? '',
          textAlign: TextAlign.center,
          style: const TextStyle(
              fontSize: 9, color: Colors.white, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }

  Widget _buildTableHeader(String text) {
    return Container(
      padding: const EdgeInsets.all(10.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Color.fromARGB(255, 29, 29, 29),
          fontWeight: FontWeight.bold,
          fontSize: 11,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.picture_as_pdf,
              color: Colors.blue,
              size: 24,
            ),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Para próximas actualizaciones.'),
                ),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: RefreshIndicator(
                onRefresh: _loadSchedule,
                child: SingleChildScrollView(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: _buildHorarioTable(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
