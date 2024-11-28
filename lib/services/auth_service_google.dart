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

  // Iniciar sesión con Google
  Future<User?> signInWithGoogle() async {
    try {
      // Iniciar sesión en Google
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        print('El usuario canceló el inicio de sesión');
        return null;
      }

      // Obtener la autenticación de Google
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Crear credenciales para Firebase
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Autenticar en Firebase
      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      print("Usuario autenticado: ${userCredential.user?.displayName}");
      return userCredential.user;
    } catch (e) {
      _handleAuthError(e);
      return null;
    }
  }

  // Cerrar sesión de Google y Firebase
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _auth.signOut();
      print('Usuario desconectado correctamente');
    } catch (e) {
      print('Error al cerrar sesión: $e');
    }
  }

  // Obtener eventos de Google Calendar
  Future<void> getCalendarEvents() async {
    try {
      final GoogleSignInAccount? googleUser = _googleSignIn.currentUser ?? await _googleSignIn.signIn();
      if (googleUser == null) {
        print('No hay usuario autenticado');
        return;
      }

      final accessToken = (await googleUser.authentication).accessToken!;
      final events = await _fetchFromGoogleAPI(
        'https://www.googleapis.com/calendar/v3/calendars/primary/events',
        accessToken,
      );

      print('Eventos de Google Calendar: $events');
    } catch (e) {
      print('Error al obtener eventos de Calendar: $e');
    }
  }

  // Obtener cursos de Google Classroom
  Future<void> getClassroomCourses() async {
    try {
      final GoogleSignInAccount? googleUser = _googleSignIn.currentUser ?? await _googleSignIn.signIn();
      if (googleUser == null) {
        print('No hay usuario autenticado');
        return;
      }

      final accessToken = (await googleUser.authentication).accessToken!;
      final courses = await _fetchFromGoogleAPI(
        'https://classroom.googleapis.com/v1/courses',
        accessToken,
      );

      print('Cursos de Google Classroom: $courses');
    } catch (e) {
      print('Error al obtener cursos de Classroom: $e');
    }
  }

  // Método genérico para hacer solicitudes HTTP a las API de Google
  Future<dynamic> _fetchFromGoogleAPI(String url, String accessToken) async {
    final response = await http.get(
      Uri.parse(url),
      headers: {'Authorization': 'Bearer $accessToken'},
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Error ${response.statusCode}: ${response.body}');
    }
  }

  // Manejo de errores de autenticación
  void _handleAuthError(dynamic e) {
    if (e is FirebaseAuthException) {
      switch (e.code) {
        case 'account-exists-with-different-credential':
          print('La cuenta ya existe con diferentes credenciales');
          break;
        case 'invalid-credential':
          print('Credenciales inválidas');
          break;
        default:
          print('Error de autenticación desconocido: ${e.code}');
      }
    } else {
      print('Error general: $e');
    }
  }
}
