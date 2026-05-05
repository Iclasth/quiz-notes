import 'package:flutter/material.dart';
import '../../models/baralho.dart';
import '../revisao/revisao_page.dart';

class BaralhosPage extends StatelessWidget {
  BaralhosPage({super.key});

  final List<Baralho> baralhos = [
    Baralho(
      id: 'flutter_basico',
      nome: 'Flutter Básico',
      descricao: 'Cards iniciais sobre Flutter, Dart e MVC.',
    ),
  ];

  void abrirRevisao(BuildContext context, Baralho baralho) {
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
      appBar: AppBar(
        title: const Text('Baralhos'),
        centerTitle: true,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: baralhos.length,
        itemBuilder: (context, index) {
          final baralho = baralhos[index];

          return Card(
            elevation: 3,
            child: ListTile(
              title: Text(baralho.nome),
              subtitle: Text(baralho.descricao),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                abrirRevisao(context, baralho);
              },
            ),
          );
        },
      ),
    );
  }
}