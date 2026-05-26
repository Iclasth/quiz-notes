import 'package:flutter/material.dart';
import '../../controllers/baralho_controller.dart';

class CriarBaralhoPage extends StatefulWidget {
  final BaralhoController controller;
  const CriarBaralhoPage({super.key, required this.controller});

  @override
  State<CriarBaralhoPage> createState() => _CriarBaralhoPageState();
}

class _CriarBaralhoPageState extends State<CriarBaralhoPage> {
  final TextEditingController nomeController = TextEditingController();
  final TextEditingController descricaoController = TextEditingController();

  void salvarBaralho() async {
    if (nomeController.text.isEmpty ||
        descricaoController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Preencha todos os campos'),
        ),
      );
      return;
    }

    final success = await widget.controller.criarBaralho(
      nomeController.text,
      descricaoController.text,
    );

    if (success) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Baralho criado com sucesso'),
        ),
      );
      Navigator.pop(context);
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erro ao criar baralho'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Novo Baralho'),
        centerTitle: true,
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          children: [
            const SizedBox(height: 20),

            TextField(
              controller: nomeController,

              decoration: InputDecoration(
                labelText: 'Nome do baralho',
                prefixIcon: const Icon(Icons.layers),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),

            const SizedBox(height: 20),

            TextField(
              controller: descricaoController,
              maxLines: 4,

              decoration: InputDecoration(
                labelText: 'Descrição',
                alignLabelWithHint: true,
                prefixIcon: const Icon(Icons.description),

                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 55,

              child: ElevatedButton.icon(
                onPressed: salvarBaralho,

                icon: const Icon(Icons.save),

                label: const Text(
                  'Salvar Baralho',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}