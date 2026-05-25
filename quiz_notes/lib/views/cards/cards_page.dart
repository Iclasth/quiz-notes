import 'package:flutter/material.dart';
import '../../models/baralho.dart';
import '../../models/card_estudo.dart';
import '../../services/api_service.dart';
import '../revisao/revisao_page.dart';
import 'criar_card_page.dart';

class CardsPage extends StatefulWidget {
  final Baralho baralho;
  const CardsPage({super.key, required this.baralho});

  @override
  State<CardsPage> createState() => _CardsPageState();
}

class _CardsPageState extends State<CardsPage> {
  final ApiService _apiService = ApiService();
  List<CardEstudo> cards = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _carregarCards();
  }

  Future<void> _carregarCards() async {
    setState(() {
      isLoading = true;
    });
    try {
      final response = await _apiService.dio.get('/decks/${widget.baralho.id}/cards');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        if (mounted) {
          setState(() {
            cards = data.map((item) => CardEstudo.fromJson(item)).toList();
          });
        }
      }
    } catch (e) {
      // Ignora erro
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  void abrirCriarCard() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CriarCardPage(deckId: widget.baralho.id)),
    ).then((_) => _carregarCards());
  }

  void revisarBaralho() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => RevisaoPage(deckId: widget.baralho.id)),
    ).then((_) => _carregarCards());
  }

  void editarCard(CardEstudo card) {
    final perguntaController = TextEditingController(text: card.pergunta);
    final respostaController = TextEditingController(text: card.resposta);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Editar card'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: perguntaController,
                decoration: const InputDecoration(labelText: 'Pergunta'),
              ),

              const SizedBox(height: 12),

              TextField(
                controller: respostaController,
                decoration: const InputDecoration(labelText: 'Resposta'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),

            TextButton(
              onPressed: () {
                setState(() {
                  card.pergunta = perguntaController.text;
                  card.resposta = respostaController.text;
                });

                Navigator.pop(context);

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Card atualizado')),
                );
              },
              child: const Text('Salvar'),
            ),
          ],
        );
      },
    );
  }

  void excluirCard(int index) {
    setState(() {
      cards.removeAt(index);
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Card excluído')));
  }

  void confirmarExclusao(int index) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Excluir card'),
          content: const Text('Tem certeza que deseja excluir este card?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),

            TextButton(
              onPressed: () {
                Navigator.pop(context);
                excluirCard(index);
              },
              child: const Text('Excluir'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cards do Baralho'), centerTitle: true),

      floatingActionButton: FloatingActionButton(
        onPressed: abrirCriarCard,
        child: const Icon(Icons.add),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),

        child: Column(
          children: [
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton.icon(
                onPressed: revisarBaralho,
                icon: const Icon(Icons.play_arrow),
                label: const Text(
                  'Revisar baralho',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),

            const SizedBox(height: 16),

            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : cards.isEmpty
                      ? const Center(
                          child: Text(
                            'Nenhum card cadastrado neste baralho.',
                            style: TextStyle(color: Colors.grey, fontSize: 16),
                          ),
                        )
                      : ListView.builder(
                          itemCount: cards.length,
                          itemBuilder: (context, index) {
                            final card = cards[index];

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
                                    Icons.style,
                                    color: Colors.deepPurple,
                                    size: 30,
                                  ),
                                ),

                                title: Text(
                                  card.pergunta,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),

                                subtitle: Padding(
                                  padding: const EdgeInsets.only(top: 10),
                                  child: Text(
                                    card.resposta,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(color: Colors.grey),
                                  ),
                                ),

                                trailing: PopupMenuButton<String>(
                                  onSelected: (value) {
                                    if (value == 'editar') {
                                      editarCard(card);
                                    }

                                    if (value == 'excluir') {
                                      confirmarExclusao(index);
                                    }
                                  },
                                  itemBuilder: (context) => const [
                                    PopupMenuItem(value: 'editar', child: Text('Editar')),
                                    PopupMenuItem(
                                      value: 'excluir',
                                      child: Text('Excluir'),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
