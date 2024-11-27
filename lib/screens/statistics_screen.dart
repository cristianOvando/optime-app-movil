import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart';

class StatisticsScreen extends StatefulWidget {
  @override
  _StatisticsScreenState createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  List<StudyData> studyData = [];
  double nextDayPrediction = 0.0;
  bool isLoading = true;
  late TooltipBehavior _tooltipBehavior;

  @override
  void initState() {
    super.initState();
    _tooltipBehavior = TooltipBehavior(
      enable: true,
      builder: (dynamic data, dynamic point, dynamic series, int pointIndex, int seriesIndex) {
        StudyData studyPoint = data as StudyData;
        String formattedDate = DateFormat('MMM dd, yyyy').format(studyPoint.date);
        return Container(
          padding: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(5.0),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                blurRadius: 4.0,
              )
            ],
          ),
          child: Text(
            'Fecha: $formattedDate\nDuración: ${formatHours(studyPoint.hours)}',
            style: const TextStyle(fontSize: 12, color: Colors.black),
          ),
        );
      },
    );
    fetchStudyData();
  }

  Future<void> fetchStudyData() async {
    const String apiUrl = 'http://52.72.86.85:5001/api/predict';

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"user_id": 2}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        final DateFormat formatter = DateFormat('EEE, dd MMM yyyy HH:mm:ss zzz');

        final List<Map<String, dynamic>> last30Days =
            List<Map<String, dynamic>>.from(data['last_30_days']);
        setState(() {
          studyData = last30Days
              .map((entry) {
                return StudyData(
                  date: formatter.parse(entry['date']),
                  hours: entry['minutes'] / 60.0,
                );
              })
              .toList()
              .cast<StudyData>();

          studyData.sort((a, b) => a.date.compareTo(b.date));

          nextDayPrediction = data['next_day_prediction'];
          isLoading = false;
        });
      } else {
        throw Exception("Error al cargar los datos");
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      showSnackBar('Error de conectividad. No se pudo cargar los datos.');
    }
  }

  String formatPrediction(double minutes) {
    int hours = (minutes / 60).floor();
    int remainingMinutes = (minutes % 60).round();
    return '$hours hora${hours == 1 ? '' : 's'} y $remainingMinutes minuto${remainingMinutes == 1 ? '' : 's'}';
  }

  String formatHours(double hours) {
    int h = hours.floor();
    int m = ((hours - h) * 60).round();
    return '$h h $m min';
  }

  void showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double maxHours = studyData.isEmpty ? 0 : studyData.map((e) => e.hours).reduce((a, b) => a > b ? a : b);
    double minHours = studyData.isEmpty ? 0 : studyData.map((e) => e.hours).reduce((a, b) => a < b ? a : b);
    double maxYAxis = maxHours + 2;

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
          children: [
            Icon(
              Icons.bar_chart_rounded,
              color: Color(0xFF167BCE),
            ),
            const SizedBox(width: 8.0),
            const Text(
              'Estadísticas de estudio',
              style: TextStyle(
                color: Color(0xFF167BCE),
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ],
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 70.0),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Container(
                      padding: const EdgeInsets.all(20.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.2),
                            spreadRadius: 2,
                            blurRadius: 5,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Predicción para mañana:',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color.fromARGB(255, 29, 29, 29),
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8.0),
                          Text(
                            formatPrediction(nextDayPrediction),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF167BCE),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 40.0),
                  SfCartesianChart(
                    zoomPanBehavior: ZoomPanBehavior(
                      enablePinching: true,
                      enablePanning: true,
                    ),
                    tooltipBehavior: _tooltipBehavior,
                    primaryXAxis: DateTimeAxis(
                      intervalType: DateTimeIntervalType.days,
                      dateFormat: DateFormat('MMM dd'),
                      majorGridLines: const MajorGridLines(width: 0),
                      labelStyle: const TextStyle(color: Color(0xFF444444)),
                    ),
                    primaryYAxis: NumericAxis(
                      labelFormat: '{value}h',
                      minimum: 0,
                      maximum: maxYAxis,
                      interval: 1.0,
                      labelStyle: const TextStyle(color: Color(0xFF444444)),
                    ),
                    series: <ChartSeries>[
                      LineSeries<StudyData, DateTime>(
                        dataSource: studyData,
                        xValueMapper: (StudyData data, _) => data.date,
                        yValueMapper: (StudyData data, _) => data.hours,
                        pointColorMapper: (StudyData data, int index) {
                          if (data.hours == maxHours) {
                            return Colors.green;
                          } else if (data.hours == minHours) {
                            return Colors.red;
                          }
                          return Color(0xFF167BCE);
                        },
                        color: Color(0xFF167BCE),
                        markerSettings: MarkerSettings(
                          isVisible: true,
                          shape: DataMarkerType.circle,
                          color: Colors.white,
                          borderWidth: 2,
                          borderColor: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10.0),
                  Container(
                    padding: const EdgeInsets.all(12.0),
                    decoration: BoxDecoration(
                      color: const Color(0xFF167BCE).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: const Text(
                      'Datos recopilados los últimos 30 días.',
                      style: TextStyle(
                        color: Color(0xFF167BCE),
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

class StudyData {
  final DateTime date;
  final double hours;

  StudyData({required this.date, required this.hours});
}
