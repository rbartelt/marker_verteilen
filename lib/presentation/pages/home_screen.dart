import 'package:flutter/material.dart';
import '../widgets/side_menu.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Screen'),
      ),
      body: const Row(
        children: [
          // Permanentes Seitenmenü
          SideMenu(),
          // Hauptinhalt
          Expanded(
            child: Center(
              child: Text(
                'Smartkorb',
                style: TextStyle(fontSize: 24),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
