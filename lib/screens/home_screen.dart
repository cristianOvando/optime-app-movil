import 'package:flutter/material.dart';
import 'package:dart_amqp/dart_amqp.dart';
import 'package:optime/screens/schedule_screen.dart';
import '../components/my_app_bar.dart';
import '../components/my_bottom_nav_bar.dart';
import '../screens/calendar_screen.dart';
import '../screens/forum_screen.dart';
import '../screens/chatbot_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  late final List<Widget> _screens;
  List<String> _messages = [];
  late Client client;

  @override
  void initState() {
    super.initState();
    _screens = [
      const ScheduleScreen(),
      const ForumScreen(),
      const ChatbotPage(),
      const CalendarScreen(),
    ];
    _connectToRabbitMQ();
  }

  @override
  void dispose() {
    client.close(); 
    super.dispose();
  }

  void _connectToRabbitMQ() {
    final connectionSettings = ConnectionSettings(
      host: '52.72.86.85',
      authProvider: PlainAuthenticator('optimeroot', 'optimeroot'),
    );

    client = Client(settings: connectionSettings);

    client
        .channel()
        .then((Channel channel) async {
      final exchange = await channel.exchange('messages_exchange', ExchangeType.FANOUT, durable: true);

      final queue = await channel.queue('', exclusive: true);

      await queue.bind(exchange, '');

      Consumer consumer = await queue.consume();
      consumer.listen((AmqpMessage message) {
        setState(() {
          _messages.add(String.fromCharCodes(message.payload ?? []));
        });
      });
    }).catchError((error) {
      debugPrint('Error al conectar a RabbitMQ: $error');
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const MyAppBar(),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          _buildRabbitMQView(),
          ..._screens.sublist(1),
        ],
      ),
      bottomNavigationBar: MyBottomNavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }

  Widget _buildRabbitMQView() {
    return ListView.builder(
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(_messages[index]),
        );
      },
    );
  }
}