import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:percent_indicator/percent_indicator.dart';

class TimerScreen extends StatefulWidget {
  const TimerScreen({Key? key}) : super(key: key);

  @override
  State<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen> {
  late Timer _timer;
  bool isRunning = false;
  int secondsElapsed = 0;
  int totalTimeStudied = 0; 

  @override
  void dispose() {
    if (isRunning) {
      _timer.cancel();
    }
    super.dispose();
  }

  void startTimer() {
    setState(() => isRunning = true);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        secondsElapsed++;
      });
    });
  }

  void stopTimer() async {
    if (isRunning) {
      _timer.cancel();
      setState(() => isRunning = false);

      final minutes = (secondsElapsed / 60).floor();
      final formattedTime = formatFullTime(secondsElapsed);

      if (minutes <= 0) {
        showSnackBar(context, 'No se puede guardar un tiempo de estudio de 0 minutos.');
        return;
      }
      showDialog(
        context: context,
        barrierDismissible: false, 
        builder: (context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: const Text(
              'Tiempo registrado',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF167BCE),
              ),
              textAlign: TextAlign.center,
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.check_circle, size: 60, color: Colors.green),
                const SizedBox(height: 10),
                Text(
                  'Has estudiado $formattedTime',
                  style: const TextStyle(
                    fontSize: 18,
                    color: Color.fromARGB(221, 0, 0, 0),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () async {
                    Navigator.pop(context);
                    await saveStudyData(1, minutes); 
                    resetTimer();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF167BCE),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Aceptar',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          );
        },
      );
    }
  }

  void resetTimer() {
    setState(() {
      totalTimeStudied += secondsElapsed; 
      secondsElapsed = 0;
      isRunning = false;
    });
  }

  Future<void> saveStudyData(int userId, int minutes) async {
    final date = DateTime.now().toIso8601String().split('T')[0];
    final studyData = {
      "user_id": userId,
      "minutes": minutes,
      "date": date,
    };

    print("Datos enviados: $studyData"); 

    try {
      final response = await sendStudyData(studyData);

      if (response.statusCode == 200) {
        print("Respuesta del servidor: ${response.body}"); 
        showSnackBar(context, 'Datos guardados exitosamente.');
      } else {
        print("Error del servidor: ${response.body}");
        showSnackBar(context, 'Error al guardar los datos: ${response.body}');
      }
    } catch (e) {
      showSnackBar(context, 'Error de red. No se pudo enviar: $e');
      print('Error al enviar datos: $e');
    }
  }

  Future<http.Response> sendStudyData(Map<String, dynamic> studyData) async {
    final url = Uri.parse('http://52.72.86.85:5001/api/save');
    return await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(studyData),
    );
  }

  void showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF167BCE),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  String formatFullTime(int seconds) {
    int hours = seconds ~/ 3600;
    int minutes = (seconds % 3600) ~/ 60;
    int remainingSeconds = seconds % 60;
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Color(0xFF167BCE),
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        centerTitle: true,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(
              Icons.timer_rounded,
              color: Color(0xFF167BCE),
            ),
            SizedBox(width: 8.0),
            Text(
              'Tiempo de estudio',
              style: TextStyle(
                color: Color(0xFF167BCE),
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ],
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularPercentIndicator(
              radius: 180.0,
              lineWidth: 15.0,
              percent: 1.0,
              center: Text(
                formatFullTime(secondsElapsed),
                style: const TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 37, 37, 37),
                ),
              ),
              progressColor: const Color.fromARGB(255, 22, 123, 206),
              backgroundColor: const Color.fromARGB(255, 255, 255, 255),
              circularStrokeCap: CircularStrokeCap.round,
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: isRunning ? stopTimer : startTimer,
              style: ElevatedButton.styleFrom(
                backgroundColor: isRunning ? Colors.red : const Color.fromARGB(255, 22, 123, 206),
                padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                isRunning ? 'Detener' : 'Iniciar',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 40),
            Column(
              children: [
                const Text(
                  'Tiempo total de estudio',
                  style: TextStyle(
                    fontSize: 18,
                    color: Color.fromARGB(255, 22, 123, 206),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  formatFullTime(totalTimeStudied),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 37, 37, 37),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
