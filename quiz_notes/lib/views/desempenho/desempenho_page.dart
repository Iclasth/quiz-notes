import 'package:flutter/material.dart';

class DesempenhoPage extends StatelessWidget {
  const DesempenhoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Desempenho'),
        centerTitle: true,
      ),
      body: const Padding(
        padding: EdgeInsets.all(20),
        child: Center(
          child: Text(
            'Área de estatísticas do usuário.\n\nAqui serão exibidos acertos, erros, cards revisados e gráficos.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18),
          ),
        ),
      ),
    );
  }
}