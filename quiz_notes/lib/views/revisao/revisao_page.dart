import 'package:flutter/material.dart';
import '../../controllers/revisao_controller.dart';

class RevisaoPage extends StatefulWidget {
  const RevisaoPage({super.key});

  @override
  State<RevisaoPage> createState() => _RevisaoPageState();
}

class _RevisaoPageState extends State<RevisaoPage> {
  final RevisaoController controller = RevisaoController();

  bool mostrarResposta = false;

  void mostrarRespostaCard() {
    setState(() {
      mostrarResposta = true;
    });
  }

  void marcarAcerto() {
    setState(() {
      controller.acertou();
      mostrarResposta = false;
    });
  }

  void marcarErro() {
    setState(() {
      controller.errou();
      mostrarResposta = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final cardAtual = controller.cardAtual;

    return Scaffold(
      appBar: AppBar(title: const Text('Revisão Espaçada'), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              'Card de Revisão',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 24),

            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const Text(
                      'Pergunta:',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 12),

                    Text(
                      cardAtual.pergunta,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 18),
                    ),

                    const SizedBox(height: 20),

                    if (mostrarResposta) ...[
                      const Text(
                        'Resposta:',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 12),

                      Text(
                        cardAtual.resposta,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 18),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: mostrarRespostaCard,
              child: const Text('Mostrar resposta'),
            ),

            const SizedBox(height: 20),

            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: marcarErro,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    child: const Text('Errei'),
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: ElevatedButton(
                    onPressed: marcarAcerto,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                    child: const Text('Acertei'),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            Text('Acertos: ${cardAtual.acertos}'),
            Text('Erros: ${cardAtual.erros}'),
            Text('Intervalo: ${cardAtual.intervalo} dia(s)'),
          ],
        ),
      ),
    );
  }
}
