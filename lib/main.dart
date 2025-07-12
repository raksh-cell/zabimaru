import 'package:flutter/material.dart';
import 'package:zabimaru/screens/start_screen.dart';

void main() {
  runApp(const ZabimaruApp());
}

class ZabimaruApp extends StatelessWidget {
  const ZabimaruApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: StartScreen(),
    );
  }
}
