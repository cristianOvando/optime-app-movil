import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class MyBottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onItemTapped;

  const MyBottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(0),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 255, 255, 255),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20), 
          topRight: Radius.circular(20),
        ),
        border: Border.all(
          color: const Color.fromARGB(255, 210, 210, 210), 
          width: 1, 
        ),
      ),
      child: BottomNavigationBar(
        currentIndex: selectedIndex,
        onTap: onItemTapped,
        backgroundColor: Colors.transparent, 
        items: [
          BottomNavigationBarItem(
            icon: _buildIcon(Icons.schedule, 0),
            label: 'Horario',
          ),
          BottomNavigationBarItem(
            icon: _buildIcon(Icons.forum, 1),
            label: 'Foro',
          ),
          BottomNavigationBarItem(
             icon: _buildIcon(FontAwesomeIcons.robot, 2), 
             label: 'ChatBot',
          ),
          BottomNavigationBarItem(
            icon: _buildIcon(Icons.calendar_today, 3),
            label: 'Calendario',
          ),
        ],
        selectedItemColor: const Color.fromARGB(255, 22, 123, 206),
        unselectedItemColor: const Color.fromARGB(255, 24, 24, 24),
        selectedLabelStyle: const TextStyle(fontSize: 14),
        unselectedLabelStyle: const TextStyle(fontSize: 12),
        type: BottomNavigationBarType.fixed,
        elevation: 0, 
      ),
    );
  }

  Widget _buildIcon(IconData icon, int index) {
    final isSelected = selectedIndex == index;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      padding: EdgeInsets.all(isSelected ? 1.0 : 0.0),
      child: Icon(
        icon,
        size: isSelected ? 34 : 28,
        color: isSelected
            ? const Color.fromARGB(255, 22, 123, 206)
            : const Color.fromARGB(255, 126, 126, 126),
      ),
    );
  }
}
