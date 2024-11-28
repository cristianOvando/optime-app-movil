import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ClassroomScreen extends StatelessWidget {
  final GoogleSignInAccount googleUser;

  ClassroomScreen({required this.googleUser});

  Future<List<String>> getClassroomCourses(GoogleSignInAccount googleUser) async {
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
        List<String> courseNames = [];
        for (var course in data['courses']) {
          courseNames.add(course['name']); 
        }
        return courseNames; 
      } else if (response.statusCode == 403) {
        print('Error 403: Permisos insuficientes. Intenta renovar el token de acceso.');
        throw Exception('Acceso denegado, error 403 al obtener los cursos.');
      } else {
        throw Exception('Error al obtener los cursos: ${response.statusCode}');
      }
    } catch (e) {
      print('Error al obtener cursos de Classroom: $e');
      throw Exception('Error al obtener los cursos de Classroom');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<String>>(
        future: getClassroomCourses(googleUser),  
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error al cargar los cursos: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No hay cursos disponibles.'));
          } else {
            return RefreshIndicator(
              onRefresh: () async {
               
                getClassroomCourses(googleUser);
              },
              child: ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(snapshot.data![index]),
                  );
                },
              ),
            );
          }
        },
      ),
    );
  }
}