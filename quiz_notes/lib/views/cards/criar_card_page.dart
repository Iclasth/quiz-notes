import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class CriarCardPage extends StatefulWidget {
  final String deckId;
  const CriarCardPage({super.key, required this.deckId});

  @override
  State<CriarCardPage> createState() => _CriarCardPageState();
}

class _CriarCardPageState extends State<CriarCardPage> {
  final TextEditingController perguntaController = TextEditingController();
  final TextEditingController respostaController = TextEditingController();
  final ApiService _apiService = ApiService();

  void salvarCard() async {
    if (perguntaController.text.isEmpty || respostaController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Preencha todos os campos')));
      return;
    }

    try {
      final response = await _apiService.dio.post(
        '/decks/${widget.deckId}/cards',
        data: {
          'frente': perguntaController.text,
          'verso': respostaController.text,
        },
      );

      if (response.statusCode == 201) {
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Card criado com sucesso')));
        Navigator.pop(context);
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Erro ao criar card')));
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Erro ao conectar com a API')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Novo Card'), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 20),
            TextField(
              controller: perguntaController,
              maxLines: 4,
              decoration: InputDecoration(
                labelText: 'Pergunta',
                alignLabelWithHint: true,
                prefixIcon: const Icon(Icons.help),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: respostaController,
              maxLines: 5,
              decoration: InputDecoration(
                labelText: 'Resposta',
                alignLabelWithHint: true,
                prefixIcon: const Icon(Icons.lightbulb),
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
                onPressed: salvarCard,
                icon: const Icon(Icons.save),
                label: const Text(
                  'Salvar Card',
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
