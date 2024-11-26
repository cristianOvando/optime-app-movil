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
    _tooltipBehavior = TooltipBehavior(enable: true, header: '');
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
      print("Error al obtener los datos: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  String formatPrediction(double minutes) {
    int hours = (minutes / 60).floor();
    int remainingMinutes = (minutes % 60).round();
    return '$hours hora${hours == 1 ? '' : 's'} y $remainingMinutes minuto${remainingMinutes == 1 ? '' : 's'}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
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
            SizedBox(width: 8.0),
            Text(
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
              child: Container(
                color: Color.fromARGB(255, 255, 255, 255), 
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    SizedBox(
                      height: 670, 
                      child: SfCartesianChart(
                        zoomPanBehavior: ZoomPanBehavior(
                          enablePinching: true,
                          enablePanning: true,
                        ),
                        tooltipBehavior: _tooltipBehavior,
                        title: ChartTitle(
                          text: 'Tiempo Estudiado en Horas\n(Últimos 30 Días)',
                          alignment: ChartAlignment.center,
                          textStyle: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Color.fromARGB(255, 28, 28, 28),
                          ),
                        ),
                        
                        primaryXAxis: DateTimeAxis(
                          intervalType: DateTimeIntervalType.days,
                          dateFormat: DateFormat('MMM dd'),
                          majorGridLines: const MajorGridLines(width: 0),
                          labelStyle: TextStyle(color: Color.fromARGB(255, 33, 33, 33)),
                        ),
                        primaryYAxis: NumericAxis(
                          title: AxisTitle(
                            text: 'Horas Estudiadas',
                            textStyle: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color.fromARGB(255, 35, 35, 35),
                            ),
                          ),
                          labelFormat: '{value}h',
                          minimum: 0,
                          interval: 0.5,
                          labelStyle: TextStyle(color: Color.fromARGB(255, 41, 41, 41)),
                        ),
                        series: <ChartSeries>[
                          LineSeries<StudyData, DateTime>(
                            dataSource: studyData,
                            xValueMapper: (StudyData data, _) => data.date,
                            yValueMapper: (StudyData data, _) => data.hours,
                            color: Color.fromARGB(255, 75, 160, 213),
                            dataLabelSettings: DataLabelSettings(
                              isVisible: false,
                            ),
                            markerSettings: MarkerSettings(
                              isVisible: true,
                              shape: DataMarkerType.circle,
                              color: Color(0xFFB5CEE3),
                              borderWidth: 2,
                              borderColor: Color.fromARGB(255, 50, 112, 163),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    Container(
                      padding: const EdgeInsets.all(20.0),
                      decoration: BoxDecoration(
                        color: Color.fromARGB(255, 255, 255, 255),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Predicción estimada para mañana:',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Color.fromARGB(255, 35, 35, 35),
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8.0), 
                          Text(
                            formatPrediction(nextDayPrediction),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF167BCE),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
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
