import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../utils/helpers.dart';
import '../components/my_textfield.dart';
import '../components/my_button.dart';

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

  void signIn() async {
  if (usernameController.text.isEmpty || passwordController.text.isEmpty) {
    Helpers.showErrorDialog(context, 'Por favor, llena todos los campos.');
    return;
  }

  setState(() => isLoading = true);

  final result = await AuthService.login(
    usernameController.text,
    passwordController.text,
  );

  setState(() => isLoading = false);

  if (result != null && result['access_token'] != null) {
    print('Inicio de sesión exitoso: $result');
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
                  fontSize: 36, 
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
              const SizedBox(height: 20),
              Align(
                alignment: Alignment.centerRight,
                child: showForgotPassword
                    ? Padding(
                        padding: const EdgeInsets.only(right: 30.0),
                        child: GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(context, '/Forgot-password');
                          },
                          child: const Text(
                            '¿Olvidaste tu contraseña?',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.blue,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      )
                    : const SizedBox.shrink(), 
              ),
              const SizedBox(height: 50),
              isLoading
                  ? const CircularProgressIndicator()
                  : MyButton(
                      onTap: isLoading ? null : signIn, 
                      buttonText: isLoading ? 'Cargando...' : 'Iniciar sesión',
                      width: 300,
                      height: 50.0,
                      borderRadius: 20.0,
                      color: Colors.blue,
                      textColor: Colors.white,
                      fontSize: 18,
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
                onTap: () {
                
                },
                child: Container(
                  padding: const EdgeInsets.all(12.0),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Image.asset(
                    'lib/assets/images/googleicon.png', 
                    height: 40,
                    width: 40,
                  ),
                ),
              ),
              const SizedBox(height: 30),
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
