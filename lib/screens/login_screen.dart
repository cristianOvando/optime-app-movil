  import 'package:flutter/material.dart';
  import '../services/auth_service.dart';       
  import '../services/auth_service_google.dart'; 
  import '../utils/helpers.dart';
  import '../components/my_textfield.dart';
  import '../components/my_button.dart';
  import 'package:shared_preferences/shared_preferences.dart';
  import 'package:firebase_auth/firebase_auth.dart'; 
  import 'package:bcrypt/bcrypt.dart';


  const List<String> SCOPES = [
    'https://www.googleapis.com/auth/classroom.courses.readonly',
    'https://www.googleapis.com/auth/classroom.coursework.me',
    'https://www.googleapis.com/auth/classroom.student-submissions.me.readonly'
  ];

  class LoginScreen extends StatefulWidget {
    const LoginScreen({super.key});

    @override
    State<LoginScreen> createState() => _LoginScreenState();
  }

  class _LoginScreenState extends State<LoginScreen> {
    final usernameController = TextEditingController();
    final passwordController = TextEditingController();
    bool isLoading = false;
    bool showForgotPassword = false; 
    final AuthServiceGoogle _authServiceGoogle = AuthServiceGoogle(); 

void signIn() async {
  if (usernameController.text.isEmpty || passwordController.text.isEmpty) {
    Helpers.showErrorDialog(context, 'Por favor, llena todos los campos.');
    return;
  }

  setState(() => isLoading = true);

  try {
   
    final hashedPassword = BCrypt.hashpw(passwordController.text, BCrypt.gensalt());
    final result = await AuthService.login(
      usernameController.text,
      hashedPassword,
    );
    
    setState(() => isLoading = false);

    if (result != null && result['access_token'] != null) {
      print('Inicio de sesión exitoso: $result');
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('access_token', result['access_token']);
      await prefs.setString('token_type', result['token_type']);
      await prefs.setInt('user_id', result['user_id']);
      
      Helpers.showSuccessDialog(
        context,
        'Éxito',
        'Inicio de sesión exitoso.',
        '/Home',  
      );
    } else {
      print('Error en inicio de sesión: $result');
      Helpers.showErrorDialog(
        context,
        result != null && result.containsKey('message') && result['message'] != null
            ? result['message']
            : 'Error desconocido: ${result?['error'] ?? 'Sin detalles del error'}',
      );
    }
  } catch (e) {
    setState(() => isLoading = false);
    print('Error durante el inicio de sesión: $e');
    Helpers.showErrorDialog(context, 'Ocurrió un error inesperado. Inténtalo de nuevo.');
  }
}


Future<User?> signInWithGoogle() async {
  try {
    final User? user = await _authServiceGoogle.signInWithGoogle();
    if (user != null) {
      return user;
    } else {
      throw Exception('Error al iniciar sesión con Google');
    }
  } catch (e) {
    print('Error al iniciar sesión con Google: $e');
    return null;
  }
}

    @override
    Widget build(BuildContext context) {
      return Scaffold(
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  'OPTIME',
                  style: TextStyle(
                    fontSize: 34, 
                    fontWeight: FontWeight.w900, 
                    color: Color.fromARGB(255, 22, 123, 206),
                    fontFamily: 'Roboto', 
                    letterSpacing: 3.0, 
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 5),
                const Text(
                  'Bienvenido',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black54,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 80),
                MyTextField(
                  controller: usernameController,
                  hintText: 'Username',
                  obscureText: false,
                  prefixIcon: const Icon(Icons.person),
                  width: 400,
                  height: 60,
                  borderRadius: 15.0,
                  hintTextStyle: TextStyle(
                    color: Colors.grey,
                    fontSize: 16,
                  ),
                  textStyle: TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                  ),
                  enabledBorderSide: BorderSide(
                    color: const Color.fromARGB(255, 181, 206, 227),
                    width: 0.5,
                  ),
                  focusedBorderSide: BorderSide(
                    color: const Color.fromARGB(255, 75, 151, 213),
                    width: 1.5,
                  ),
                  fillColor: Colors.white,
                ),
                const SizedBox(height: 20),
                MyTextField(
                  controller: passwordController,
                  hintText: 'Contraseña',
                  obscureText: true,
                  toggleVisibility: true,
                  prefixIcon: const Icon(Icons.lock),
                  width: 400,
                  height: 60,
                  borderRadius: 15.0,
                  hintTextStyle: TextStyle(
                    color: Colors.grey,
                    fontSize: 16,
                  ),
                  textStyle: TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                  ),
                  enabledBorderSide: BorderSide(
                    color: const Color.fromARGB(255, 181, 206, 227),
                    width: 0.5,
                  ),
                  focusedBorderSide: BorderSide(
                    color: const Color.fromARGB(255, 75, 151, 213),
                    width: 1.5,
                  ),
                  fillColor: Colors.white,
                ),
                const SizedBox(height: 70),
                isLoading
                    ? const CircularProgressIndicator()
                    : MyButton(
                        onTap: isLoading ? null : signIn, 
                        buttonText: isLoading ? 'Cargando...' : 'Iniciar sesión',
                        width: 300,
                        height: 50.0,
                        borderRadius: 20.0,
                        color: Color(0xFF167BCE),
                        textColor: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        borderSide: BorderSide(
                          color: Colors.black,
                          width: 0.5,
                        ),
                    ),
                const SizedBox(height: 60),
                Row(
                  children: const [
                    Expanded(child: Divider(color: Colors.grey)),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text('O continuar con'),
                    ),
                    Expanded(child: Divider(color: Colors.grey)),
                  ],
                ),
                const SizedBox(height: 30),
                GestureDetector(
                  onTap: () async {
                    final user = await signInWithGoogle();
                    if (user != null) {
                      Helpers.showSuccessDialog(context, 'Bienvenido', 'Inicio de sesión exitoso.', '/Home');
                    } else {
                      Helpers.showErrorDialog(context, 'Error al iniciar sesión con Google.');
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(12.0),
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color.fromARGB(255, 254, 254, 254)),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Image.asset(
                      'lib/assets/images/googleicon.png', 
                      height: 40,
                      width: 40,
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      '¿No tienes cuenta?',
                      style: TextStyle(fontSize: 14),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, '/Create-contact');
                      },
                      child: const Text(
                        ' Registrate',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.blue,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    }
  }