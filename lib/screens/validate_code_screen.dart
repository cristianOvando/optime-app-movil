import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/contact_validate.dart';
import '../utils/helpers.dart';
import '../components/my_textfield.dart';
import '../components/my_button.dart';
import 'package:flutter/services.dart';

class ValidateCodeScreen extends StatefulWidget {
  const ValidateCodeScreen({super.key});

  @override
  State<ValidateCodeScreen> createState() => _ValidateCodeScreenState();
}

class _ValidateCodeScreenState extends State<ValidateCodeScreen> {
  final codeController = TextEditingController();
  bool isLoading = false;
  String? contactId;

  @override
  void initState() {
    super.initState();
    _loadContactId();
  }

  Future<void> _loadContactId() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      contactId = prefs.getString('contact_id');
    });
  }

  void validateCode() async {
    if (codeController.text.isEmpty) {
      Helpers.showErrorDialog(context, 'Por favor, ingresa el código.');
      return;
    }

    if (contactId == null) {
      Helpers.showErrorDialog(context, 'Error: Contacto no encontrado.');
      return;
    }

    setState(() => isLoading = true);

    final response = await ContactValidateService.validateContact(
      contactId!,
      codeController.text.trim(),
    );

    setState(() => isLoading = false);

    if (response != null && response['error'] == null) {
      _showSuccessDialog('Código válido', 'El código fue verificado correctamente.', '/Register-user');
    } else {
      Helpers.showErrorDialog(
        context,
        response?['message'] ?? 'Error al validar el código. Inténtalo de nuevo.',
      );
    }
  }

  void _showSuccessDialog(String title, String content, String nextRoute) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.blue, size: 30),
              const SizedBox(width: 10),
              Text(title, style: const TextStyle(color: Colors.blue)),
            ],
          ),
          content: Text(content),
          actions: [
            MyButton(
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, nextRoute);
              },
              buttonText: 'Aceptar',
              width: double.infinity,
              borderRadius: 8.0,
            ),
          ],
        );
      },
    );
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
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              const Icon(
                Icons.lock,
                size: 80,
              ),
              const Text(
                'Código de verificación',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 60),
              MyTextField(
                controller: codeController,
                hintText: 'Ingresa el código recibido',
                obscureText: false,
                prefixIcon: const Icon(Icons.numbers),
                width: 400,
                height: 70,
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
                keyboardType: TextInputType.number, 
                inputFormatters: [FilteringTextInputFormatter.digitsOnly], 
              ),
              const SizedBox(height: 10),
              isLoading
                  ? const CircularProgressIndicator()
                  : MyButton(
                      onTap: validateCode,
                      buttonText: 'Validar Código',
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
