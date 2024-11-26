import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; 
import '../services/auth_service.dart';
import '../utils/helpers.dart';
import '../components/my_textfield.dart';
import '../components/my_button.dart';

class RegisterUserScreen extends StatefulWidget {
  const RegisterUserScreen({super.key});

  @override
  State<RegisterUserScreen> createState() => _RegisterUserScreenState();
}

class _RegisterUserScreenState extends State<RegisterUserScreen> {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  bool isLoading = false;
  String? contactId;

  @override
  void initState() {
    super.initState();
    _loadContactId();
  }

  Future<void> _loadContactId() async {
    final prefs = await SharedPreferences.getInstance();
    final loadedContactId = prefs.getString('contact_id');
    if (loadedContactId == null || loadedContactId.isEmpty) {
      Helpers.showErrorDialog(
        context,
        'No se encontró el Contact ID. Vuelve a intentar el proceso desde el inicio.',
      );
    }
    setState(() {
      contactId = loadedContactId;
    });
  }

  void registerUser() async {
    if (contactId == null) {
      Helpers.showErrorDialog(
        context,
        'Error: No se encontró el Contact ID. Vuelve a intentar el proceso desde el inicio.',
      );
      return;
    }

    if (usernameController.text.isEmpty || passwordController.text.isEmpty) {
      Helpers.showErrorDialog(
        context,
        'Todos los campos son obligatorios.',
      );
      return;
    }

    if (passwordController.text.length < 6) {
      Helpers.showErrorDialog(
        context,
        'La contraseña debe tener al menos 6 caracteres.',
      );
      return;
    }

    setState(() => isLoading = true);

    final result = await AuthService.register(
      usernameController.text.trim(),
      passwordController.text.trim(),
      contactId!,
    );
    if (result == null || result.isEmpty || result.containsKey('error')) {
        Helpers.showErrorDialog(
          context,
          result?['message'] ?? 'El servidor no devolvió datos. Por favor, inténtalo más tarde.',
        );
      } else { 

        Helpers.showSuccessDialog(
          context,
          'Registro exitoso',
          'El usuario fue registrado exitosamente.',
          '/Login',
        );
      }

    setState(() => isLoading = false);

    print('Resultado recibido en RegisterUserScreen: $result');

    if (result == null) {
      Helpers.showErrorDialog(
        context,
        'Error al conectar con el servidor. Inténtalo más tarde.',
      );
    } else if (result.containsKey('error')) {
      Helpers.showErrorDialog(
        context,
        result['message'] ?? 'Error desconocido: ${result['error']}',
      );
    } else {

      Helpers.showSuccessDialog(
        context,
        'Registro exitoso',
        'El usuario fue registrado exitosamente.',
        '/Login',
      );
    }
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
        title: const Text(
          'Registro de usuario',
          style: TextStyle(
            color: Color(0xFF167BCE),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                '¡Ya casi eres parte de OPTIME!',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 22, 123, 206),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 50),
              MyTextField(
                controller: usernameController,
                hintText: 'Nombre de usuario',
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
              isLoading
                  ? const CircularProgressIndicator()
                  : MyButton(
                      onTap: registerUser,
                      buttonText: 'Registrar',
                      width: 300,
                      height: 50.0,
                      borderRadius: 20.0,
                      color: Color(0xFF167BCE),
                      textColor: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      borderSide: BorderSide(
                        color: Colors.black,
                        width: 0.5,
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
