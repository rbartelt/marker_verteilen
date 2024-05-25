import 'package:flutter/material.dart';

class SideMenu extends StatelessWidget {
  const SideMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          const DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.blue,
            ),
            child: Text(
              'Menü',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Startseite'),
            onTap: () {
              Navigator.pushNamed(context, '/home');
            },
          ),
          ListTile(
            leading: const Icon(Icons.calendar_today),
            title: const Text('Kalender'),
            onTap: () {
              Navigator.pushNamed(context, '/calendar');
            },
          ),
          ListTile(
            leading: const Icon(Icons.list),
            title: const Text('Aufstellung'),
            onTap: () {
              Navigator.pushNamed(context, '/setup');
            },
          ),
          ListTile(
            leading: const Icon(Icons.beach_access),
            title: const Text('Strandkörbe'),
            onTap: () {
              Navigator.pushNamed(context, '/beachchairs');
            },
          ),
          ListTile(
            leading: const Icon(Icons.attach_money),
            title: const Text('Preise'),
            onTap: () {
              Navigator.pushNamed(context, '/prices');
            },
          ),
        ],
      ),
    );
  }
}
