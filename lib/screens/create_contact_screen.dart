import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/contact_service.dart';
import '../utils/helpers.dart';
import '../components/my_textfield.dart';
import '../components/my_button.dart';

class CreateContactScreen extends StatefulWidget {
  const CreateContactScreen({super.key});

  @override
  State<CreateContactScreen> createState() => _CreateContactScreenState();
}

class _CreateContactScreenState extends State<CreateContactScreen> {
  final emailController = TextEditingController();
  final nameController = TextEditingController();
  final lastNameController = TextEditingController();
  final phoneController = TextEditingController();
  bool isLoading = false;

  void createContact() async {
    if (emailController.text.isEmpty ||
        nameController.text.isEmpty ||
        lastNameController.text.isEmpty ||
        phoneController.text.isEmpty) {
      Helpers.showErrorDialog(
        context,
        'Favor de llenar todos los campos',
      );
      return;
    }

    if (!RegExp(r'^[\w\.\-]+@([\w\-]+\.)?upchiapas\.edu\.mx$')
        .hasMatch(emailController.text.trim())) {
      Helpers.showErrorDialog(
        context,
        'Solo se permiten correo con terminación @upchiapas.edu.mx.',
      );
      return;
    }

    setState(() => isLoading = true);

    final result = await ContactService.createContact(
      emailController.text.trim(),
      nameController.text.trim(),
      lastNameController.text.trim(),
      phoneController.text.trim(),
    );

    setState(() => isLoading = false);

    if (result != null) {
      print('Resultado completo: $result');

      if (result.containsKey('error')) {
        Helpers.showErrorDialog(
          context,
          result['message'] ?? 'Error desconocido',
        );
      } else if (result.containsKey('contact_id')) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('contact_id', result['contact_id'].toString());

        Helpers.showSuccessDialog(
          context,
          'Contacto creado',
          result['message'] ?? 'El contacto fue creado exitosamente.',
          '/Validate-code',
        );
      } else {
        Helpers.showErrorDialog(
          context,
          'Respuesta inesperada del servidor.',
        );
      }
    } else {
      Helpers.showErrorDialog(
        context,
        'No se pudo conectar con el servidor. Por favor, inténtalo más tarde.',
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
          'Crear Contacto',
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
              MyTextField(
                controller: emailController,
                hintText: 'Correo Electrónico',
                obscureText: false,
                prefixIcon: const Icon(Icons.email),
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
                controller: nameController,
                hintText: 'Nombre',
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
                controller: lastNameController,
                hintText: 'Apellido',
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
                controller: phoneController,
                hintText: 'Teléfono',
                obscureText: false,
                prefixIcon: const Icon(Icons.phone),
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
              const SizedBox(height: 60),
              isLoading
                  ? const CircularProgressIndicator()
                  : MyButton(
                      onTap: createContact,
                      buttonText: 'Siguiente',
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
