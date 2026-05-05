import 'package:flutter/material.dart';
import '../revisao/revisao_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.title});

  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  void abrirRevisao() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const RevisaoPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            _buildTitle(),
            const SizedBox(height: 30),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: ElevatedButton(
                onPressed: abrirRevisao,
                child: const Text('Iniciar revisão'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTitle() => const Text(
        'Quiz Notes',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
        ),
      );
}