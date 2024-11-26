import 'package:flutter/material.dart';

class MyAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool hasNotifications;

  const MyAppBar({super.key, this.hasNotifications = false});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      elevation: 0,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          color: Colors.white, 
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
          border: Border.all(
            color: const Color.fromARGB(255, 210, 210, 210), 
            width: 1.0, 
          ),
        ),
        padding: const EdgeInsets.only(left: 8.0, right: 16.0, top: 55.0, bottom: 20.0), 
        child: Stack(
          alignment: Alignment.center,
          children: [
            GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, '/Timer');
              },
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.access_time_filled,
                    color: Color.fromARGB(255, 22, 123, 206),
                    size: 27,
                  ),
                  SizedBox(width: 5),
                  Text(
                    'PTIME',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 23,
                      letterSpacing: 2,
                      color: Color.fromARGB(255, 22, 123, 206),
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              right: 60, 
              child: Stack(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.notifications,
                      color: Color.fromARGB(255, 75, 151, 213),
                    ),
                    onPressed: () {
                      Navigator.pushNamed(context, '/Notifications');
                    },
                  ),
                  if (hasNotifications)
                    Positioned(
                      right: 10,
                      top: 10,
                      child: Container(
                        height: 8,
                        width: 8,
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Positioned(
              right: 0,
              child: PopupMenuButton<int>(
                onSelected: (value) {
                  switch (value) {
                    case 0:
                      Navigator.pushNamed(context, '/Settings');
                      break;
                    case 1:
                      Navigator.pushNamed(context, '/Statistics');
                      break;
                    case 2:
                      Navigator.pushNamed(context, '/Timer');
                      break;
                    case 3:
                      _signOut(context);
                      break;
                  }
                },
                icon: const Icon(
                  Icons.more_vert,
                  color: Color.fromARGB(255, 22, 123, 206),
                ),
                color: const Color.fromARGB(255, 250, 250, 250),
                offset: const Offset(0, 35),
                itemBuilder: (BuildContext context) => <PopupMenuEntry<int>>[
                  const PopupMenuItem<int>(
                    value: 0,
                    child: ListTile(
                      title: Text(
                        'Perfil',
                        style: TextStyle(color: Color.fromARGB(255, 48, 48, 48)),
                      ),
                    ),
                  ),
                  const PopupMenuItem<int>(
                    value: 1,
                    child: ListTile(
                      title: Text(
                        'Horas de estudio',
                        style: TextStyle(color: Color.fromARGB(255, 48, 48, 48)),
                      ),
                    ),
                  ),
                  const PopupMenuItem<int>(
                    value: 2,
                    child: ListTile(
                      title: Text(
                        'Estudio',
                        style: TextStyle(color: Color.fromARGB(255, 48, 48, 48)),
                      ),
                    ),
                  ),
                  const PopupMenuItem<int>(
                    value: 3,
                    child: ListTile(
                      leading: Icon(Icons.exit_to_app, color: Colors.red),
                      title: Text(
                        'Cerrar sesión',
                        style: TextStyle(color: Colors.red),
                      ),
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

  void _signOut(BuildContext context) {
    Navigator.pushNamedAndRemoveUntil(context, '/Login', (route) => false);
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 20);
}
