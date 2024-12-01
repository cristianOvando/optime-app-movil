import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:optime/screens/classroom_screen.dart';
import 'package:optime/screens/login_screen.dart';
import 'package:optime/screens/create_contact_screen.dart';
import 'package:optime/screens/home_screen.dart';
import 'package:optime/screens/myschedule_screen.dart';
import 'package:optime/screens/register_user_screen.dart.dart';
import 'package:optime/screens/validate_code_screen.dart';
import 'package:optime/screens/timer_screen.dart';
import 'package:optime/screens/statistics_screen.dart';
import 'package:optime/screens/settings_screen.dart';
import 'package:optime/screens/forum_screen.dart';
import 'package:optime/screens/chatbot_screen.dart';
import 'package:google_sign_in/google_sign_in.dart';

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

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  GoogleSignInAccount? _googleUser;

  @override
  void initState() {
    super.initState();
    _checkGoogleSignIn();
  }

  Future<void> _checkGoogleSignIn() async {
    final GoogleSignIn googleSignIn = GoogleSignIn(
      scopes: <String>[
        'https://www.googleapis.com/auth/classroom.courses.readonly',
        'https://www.googleapis.com/auth/classroom.coursework.me',
        'https://www.googleapis.com/auth/classroom.student-submissions.me.readonly',
        'https://www.googleapis.com/auth/calendar.readonly',
      ],
    );

    GoogleSignInAccount? googleUser = await googleSignIn.signInSilently();
    if (googleUser == null) {
      googleUser = await googleSignIn.signIn();
    }

    if (googleUser != null) {
      setState(() {
        _googleUser = googleUser;
      });
    } else {
      setState(() {
        _googleUser = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OPTIME',
      debugShowCheckedModeBanner: false,
      initialRoute: _googleUser == null ? '/Login' : '/Home',
      routes: {
        '/Login': (context) => const LoginScreen(),
        '/Create-contact': (context) => const CreateContactScreen(),
        '/Validate-code': (context) => const ValidateCodeScreen(),
        '/Register-user': (context) => const RegisterUserScreen(),
        '/Home': (context) => _googleUser != null
            ? HomeScreen(googleUser: _googleUser!)
            : const LoginScreen(),
        '/Timer': (context) => const TimerScreen(),
        '/Statistics': (context) => StatisticsScreen(),
        '/Settings': (context) => const SettingsScreen(),
        '/Schedule': (context) => const CalendarScreen(),
        '/Forum': (context) => const ForumScreen(),
        '/Chatbot': (context) => const ChatbotPage(),
        '/Classroom': (context) => _googleUser != null
            ? ClassroomScreen(googleUser: _googleUser!)
            : const LoginScreen(),
      },
    );
  }
}