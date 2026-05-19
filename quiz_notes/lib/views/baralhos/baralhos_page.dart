import 'package:flutter/material.dart';

import '../../models/baralho.dart';
import '../cards/cards_page.dart';
import 'criar_baralho_page.dart';

class BaralhosPage extends StatelessWidget {
  BaralhosPage({super.key});

  final List<Baralho> baralhos = [
    Baralho(
      id: 'flutter_basico',
      nome: 'Flutter Básico',
      descricao: 'Cards sobre Flutter, Dart e MVC.',
    ),

    Baralho(
      id: 'node_backend',
      nome: 'Node.js Backend',
      descricao: 'API REST, Express e TypeORM.',
    ),

    Baralho(
      id: 'supabase',
      nome: 'Supabase',
      descricao: 'Banco de dados e Storage.',
    ),
  ];

  void abrirCards(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CardsPage()),
    );
  }

  void criarBaralho(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CriarBaralhoPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Meus Baralhos'), centerTitle: true),

      floatingActionButton: FloatingActionButton(
        onPressed: () => criarBaralho(context),
        child: const Icon(Icons.add),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),

        child: ListView.builder(
          itemCount: baralhos.length,

          itemBuilder: (context, index) {
            final baralho = baralhos[index];

            return Container(
              margin: const EdgeInsets.only(bottom: 16),

              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E),
                borderRadius: BorderRadius.circular(20),
              ),

              child: ListTile(
                contentPadding: const EdgeInsets.all(20),

                leading: Container(
                  padding: const EdgeInsets.all(14),

                  decoration: BoxDecoration(
                    color: Colors.deepPurple.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(14),
                  ),

                  child: const Icon(
                    Icons.layers,
                    color: Colors.deepPurple,
                    size: 32,
                  ),
                ),

                title: Text(
                  baralho.nome,

                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 10),

                  child: Text(
                    baralho.descricao,

                    style: const TextStyle(color: Colors.grey),
                  ),
                ),

                trailing: const Icon(Icons.arrow_forward_ios),

                onTap: () {
                  abrirCards(context);
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
