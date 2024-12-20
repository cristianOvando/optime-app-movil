import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart'; 
import 'package:flutter_dotenv/flutter_dotenv.dart'; 
import 'package:optime/screens/login_screen.dart'; 
import 'package:optime/screens/create_contact_screen.dart';
import 'package:optime/screens/home_screen.dart';
import 'package:optime/screens/register_user_screen.dart.dart';
import 'package:optime/screens/validate_code_screen.dart';
import 'package:optime/screens/timer_screen.dart';
import 'package:optime/screens/statistics_screen.dart';
import 'package:optime/screens/settings_screen.dart';
import 'package:optime/screens/schedule_screen.dart';
import 'package:optime/screens/forum_screen.dart';
import 'package:optime/screens/chatbot_screen.dart';
import 'package:optime/screens/calendar_screen.dart';

Map<String, dynamic> config = {};

Future<void> loadConfig() async {
  await dotenv.load(fileName: 'lib/assets/.env');
  runApp(const MyApp());
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp();
    print("Firebase inicializado correctamente.");
  } catch (e) {
    print("Error al inicializar Firebase: $e");
  }

  try {
    await dotenv.load(fileName: 'lib/assets/.env');
    print("Variables de entorno cargadas correctamente.");
  } catch (e) {
    print("Error al cargar dotenv: $e");
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OPTIME',
      debugShowCheckedModeBanner: false,
      initialRoute: '/Login',
      routes: {
        '/Login': (context) => const LoginScreen(),
        '/Create-contact': (context) => const CreateContactScreen(),
        '/Validate-code': (context) => const ValidateCodeScreen(),
        '/Register-user': (context) => const RegisterUserScreen(),
        '/Home': (context) => const HomeScreen(),
        '/Timer': (context) => const TimerScreen(),
        '/Statistics': (context) => StatisticsScreen(),
        '/Settings': (context) => const SettingsScreen(),
        '/Schedule': (context) => const ScheduleScreen(),
        '/Forum': (context) => const ForumScreen(),
        '/Chatbot': (context) => const ChatbotPage(),
        '/Calendar': (context) => const CalendarScreen(),
      },
    );
  }
}
