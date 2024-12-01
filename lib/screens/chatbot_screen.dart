import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ChatbotPage extends StatefulWidget {
  const ChatbotPage({super.key});

  @override
  _ChatbotPageState createState() => _ChatbotPageState();
}

class _ChatbotPageState extends State<ChatbotPage> {
  final String apiUrl = 'https://api.openai.com/v1/chat/completions';
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> _messages = [];
  final List<Map<String, String>> _history = [];

  Future<void> sendMessage(String message) async {
    final String? apiKey = dotenv.env['APIKEY'];
    if (apiKey == null || apiKey.isEmpty) {
      setState(() {
        _messages.add({
          "sender": "bot",
          "message": "Error: No se encontró la clave API. Verifica tu archivo de configuración."
        });
      });
      return;
    }

    try {
      setState(() {
        _messages.add({"sender": "user", "message": message});
        _history.add({"sender": "user", "message": message});
      });

      final apiResponse = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          'Authorization': 'Bearer $apiKey',
        },
        body: json.encode({
          "model": "gpt-3.5-turbo",
          "messages": [
           {
             "role": "system",
             "content": "Eres un asistente para una app móvil llamada Optime.\n"
                 "Responde exclusivamente preguntas académicas relacionadas con la Universidad Politécnica de Chiapas.\n\n"
                 "- Si te saludan\n"
                 "- Responde dando la bienvenido y diciendo que eres un asistente de la aplicación Optime.\n"
                 "Puedes responder sobre:\n"
                 "- Materias disponibles en las carreras:\n"
                 "  - Ingeniería en Software:\n"
                 "    - Inglés\n"
                 "    - Química básica\n"
                 "    - Álgebra lineal\n"
                 "    - Fundamentos de computación\n"
                 "    - Algoritmos\n"
                 "    - Matemáticas discretas\n"
                 "    - Expresión oral y escrita I\n"
                 "    - Y más, consulta el horario completo.\n"
                 "  - Ingeniería Biomédica:\n"
                 "    - Inglés\n"
                 "    - Desarrollo humano y valores\n"
                 "    - Fundamentos matemáticos\n"
                 "    - Física\n"
                 "    - Introducción a la ingeniería biomédica\n"
                 "    - Química aplicada a la ingeniería\n"
                 "    - Comunicación y habilidades digitales\n"
                 "    - Y más, consulta el horario completo.\n\n"
                 "También puedes preguntar sobre:\n"
                 "- Horarios\n"
                 "- Profesores\n"
                 "- Cualquier tema académico relacionado con la universidad.\n\n"
                 "Las carreras disponibles en la universidad son:\n"
                 "- Ingeniería en Software\n"
                 "- Ingeniería Biomédica\n"
                 "- Ingeniería Petrolera\n"
                 "- Ingeniería en Nanotecnología\n"
                 "- Ingeniería Agroindustrial\n"
                 "- Ingeniería en Energías Renovables\n"
                 "- Licenciatura en Administración y Gestión Empresarial\n"
                 "- Ingeniería en Tecnología Ambiental\n\n"
                 "Si la pregunta no está relacionada con estos temas, responde:\n"
                 "'Lo siento, solo puedo responder preguntas académicas relacionadas con la Universidad Politécnica de Chiapas.'"
           },
            ..._history.map((msg) => {
                  "role": msg["sender"] == "user" ? "user" : "assistant",
                  "content": msg["message"],
                }),
            {"role": "user", "content": message},
          ],
          "max_tokens": 200,
        }),
      );

      if (apiResponse.statusCode == 200) {
        final data = json.decode(utf8.decode(apiResponse.bodyBytes));
        String botMessage =
            data["choices"]?[0]["message"]?["content"] ?? 'No hubo respuesta';

        setState(() {
          _messages.add({"sender": "bot", "message": botMessage});
          _history.add({"sender": "bot", "message": botMessage});
        });
      } else {
        setState(() {
          _messages.add({
            "sender": "bot",
            "message": "Error: ${apiResponse.statusCode} - ${apiResponse.body}"
          });
        });
      }

      _controller.clear();
    } catch (e) {
      setState(() {
        _messages.add({
          "sender": "bot",
          "message": "Error: No hay conexión a Internet."
        });
      });
    }
  }

  void _clearChat() {
    setState(() {
      _messages.clear();
      _history.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
     appBar: AppBar(
        automaticallyImplyLeading: false, 
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            color: const Color.fromARGB(255, 202, 12, 12),
            onPressed: _clearChat,
          ),
        ],
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        elevation: 0,
      ),
      body: Container(
        color: const Color.fromARGB(255, 255, 255, 255),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(10.0),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final message = _messages[index];
                  final isUserMessage = message['sender'] == 'user';
                  return Align(
                    alignment: isUserMessage
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: Row(
                      mainAxisAlignment: isUserMessage
                          ? MainAxisAlignment.end
                          : MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (!isUserMessage)
                          const Padding(
                            padding: EdgeInsets.only(right: 8.0),
                            child: CircleAvatar(
                              backgroundColor: Color(0xFF167BCE),
                              child: Icon(Icons.smart_toy, color: Colors.white),
                            ),
                          ),
                        Flexible(
                          child: Container(
                            margin: const EdgeInsets.symmetric(vertical: 5.0),
                            padding: const EdgeInsets.all(12.0),
                            decoration: BoxDecoration(
                              color: isUserMessage
                                  ? const Color(0xFF167BCE)
                                  : const Color(0xFFB5CEE3),
                              borderRadius: BorderRadius.circular(15.0),
                            ),
                            child: Text(
                              message['message']!,
                              style: TextStyle(
                                color: isUserMessage
                                    ? Colors.white
                                    : Colors.black87,
                              ),
                              softWrap: true,
                              overflow: TextOverflow.clip,
                            ),
                          ),
                        ),
                        if (isUserMessage)
                          const Padding(
                            padding: EdgeInsets.only(left: 8.0),
                            child: CircleAvatar(
                              backgroundColor: Color(0xFFB5CEE3),
                              child: Icon(Icons.person, color: Colors.black),
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Container(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12.0),
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 233, 233, 233),
                        borderRadius: BorderRadius.circular(15.0),
                        border: Border.all(
                          color: const Color.fromARGB(255, 240, 240, 240),
                          width: 1,
                        ),
                      ),
                      child: TextField(
                        controller: _controller,
                        decoration: const InputDecoration(
                          hintText: 'Escribe un mensaje...',
                          border: InputBorder.none,
                        ),
                        style: const TextStyle(fontSize: 16.0),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8.0),
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF167BCE),
                      borderRadius: BorderRadius.circular(50.0),
                      border: Border.all(
                        color: const Color(0xFF167BCE),
                        width: 1.5,
                      ),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.send, color: Colors.white),
                      onPressed: () {
                        sendMessage(_controller.text);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
