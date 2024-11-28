import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AuthServiceGoogle {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: <String>[
      'https://www.googleapis.com/auth/classroom.courses.readonly',
      'https://www.googleapis.com/auth/classroom.coursework.me',
      'https://www.googleapis.com/auth/classroom.student-submissions.me.readonly',
      'https://www.googleapis.com/auth/calendar.readonly', 
      'https://www.googleapis.com/auth/calendar', 
    ],
  );

  Future<User?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        throw Exception('El usuario canceló el inicio de sesión');
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      print("Usuario autenticado correctamente: ${userCredential.user?.displayName}");
      return userCredential.user;
    } catch (e) {
      print('Error al iniciar sesión con Google: $e');
      if (e is FirebaseAuthException) {
        if (e.code == 'account-exists-with-different-credential') {
          print('La cuenta ya existe con diferentes credenciales');
        }
      }
      return null;
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
    await _googleSignIn.signOut();
    print('Usuario desconectado');
  }

  Future<void> getCalendarEvents(GoogleSignInAccount googleUser) async {
    try {
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final String accessToken = googleAuth.accessToken!;

      final response = await http.get(
        Uri.parse('https://www.googleapis.com/calendar/v3/calendars/primary/events'),
        headers: {
          'Authorization': 'Bearer $accessToken',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('Eventos de Google Calendar: $data');
      } else {
        print('Error al obtener eventos: ${response.statusCode}');
      }
    } catch (e) {
      print('Error al obtener eventos de Calendar: $e');
    }
  }

  Future<void> getClassroomCourses(GoogleSignInAccount googleUser) async {
    try {
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final String accessToken = googleAuth.accessToken!;

      final response = await http.get(
        Uri.parse('https://classroom.googleapis.com/v1/courses'),
        headers: {
          'Authorization': 'Bearer $accessToken',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('Cursos de Classroom: $data');
        
      } else {
        print('Error al obtener cursos: ${response.statusCode}');
      }
    } catch (e) {
      print('Error al obtener cursos de Classroom: $e');
    }
  }
}
