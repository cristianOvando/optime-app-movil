import 'package:flutter/material.dart';
import 'package:optime/screens/myschedule_screen.dart';
import 'package:optime/screens/schedule_screen.dart';
import 'package:optime/screens/forum_screen.dart';
import 'package:optime/screens/chatbot_screen.dart';
import '../components/my_app_bar.dart';
import '../components/my_bottom_nav_bar.dart';
import 'package:google_sign_in/google_sign_in.dart';

class HomeScreen extends StatefulWidget {
  final GoogleSignInAccount googleUser; 

  const HomeScreen({super.key, required this.googleUser});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      ScheduleScreen(),
      ForumScreen(),
      ChatbotPage(),
      CalendarScreen(),
    ];
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
          ..._screens.sublist(0),
        ],
      ),
      bottomNavigationBar: MyBottomNavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }
}