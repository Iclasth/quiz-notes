import 'package:flutter/material.dart';

import '../../controllers/baralho_controller.dart';
import '../../models/baralho.dart';
import '../cards/cards_page.dart';
import 'criar_baralho_page.dart';

class BaralhosPage extends StatefulWidget {
  const BaralhosPage({super.key});

  @override
  State<BaralhosPage> createState() => _BaralhosPageState();
}

class _BaralhosPageState extends State<BaralhosPage> {
  final BaralhoController controller = BaralhoController();

  @override
  void initState() {
    super.initState();
    _carregarDados();
  }

  Future<void> _carregarDados() async {
    setState(() {
      controller.isLoading = true;
    });
    await controller.carregarBaralhos();
    if (mounted) {
      setState(() {
        controller.isLoading = false;
      });
    }
  }

  void abrirCards(BuildContext context, Baralho baralho) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CardsPage(baralho: baralho)),
    ).then((_) => _carregarDados());
  }

  void criarBaralho(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CriarBaralhoPage(controller: controller)),
    ).then((_) => _carregarDados());
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

        child: controller.isLoading
            ? const Center(child: CircularProgressIndicator())
            : controller.baralhos.isEmpty
                ? const Center(
                    child: Text(
                      'Nenhum baralho criado ainda.',
                      style: TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                  )
                : ListView.builder(
                    itemCount: controller.baralhos.length,

                    itemBuilder: (context, index) {
                      final baralho = controller.baralhos[index];

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
                              color: Colors.deepPurple.withValues(alpha: 0.2),
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

                          subtitle: baralho.descricao.isNotEmpty
                              ? Padding(
                                  padding: const EdgeInsets.only(top: 10),

                                  child: Text(
                                    baralho.descricao,

                                    style: const TextStyle(color: Colors.grey),
                                  ),
                                )
                              : null,

                          trailing: const Icon(Icons.arrow_forward_ios),

                          onTap: () {
                            abrirCards(context, baralho);
                          },
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}
