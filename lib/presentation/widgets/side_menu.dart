import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SideMenu extends StatelessWidget {
  const SideMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: const BoxDecoration(
              color: Colors.blue,
            ),
            child: Image.asset(
              'assets/images/smartkorb-image-splash.png',
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Startseite'),
            onTap: () {
              context.go('/');
            },
          ),
          ListTile(
            leading: const Icon(Icons.calendar_today),
            title: const Text('Kalender'),
            onTap: () {
              context.go('/calendar');
            },
          ),
          ListTile(
            leading: const Icon(Icons.list),
            title: const Text('Aufstellung'),
            onTap: () {
              context.go('/setup');
            },
          ),
          ListTile(
            leading: const Icon(Icons.beach_access),
            title: const Text('Strandkörbe'),
            onTap: () {
              context.go('/beachchairs');
            },
          ),
          ListTile(
            leading: const Icon(Icons.attach_money),
            title: const Text('Preise'),
            onTap: () {
              context.go('/prices');
            },
          ),
        ],
      ),
    );
  }
}
