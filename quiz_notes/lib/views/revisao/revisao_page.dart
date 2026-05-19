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
      appBar: AppBar(title: const Text('Revisão'), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                _buildStatus(
                  titulo: 'Acertos',
                  valor: '${cardAtual.acertos}',
                  cor: Colors.green,
                ),
                _buildStatus(
                  titulo: 'Erros',
                  valor: '${cardAtual.erros}',
                  cor: Colors.red,
                ),
                _buildStatus(
                  titulo: 'Intervalo',
                  valor: '${cardAtual.intervalo}d',
                  cor: Colors.deepPurple,
                ),
              ],
            ),

            const SizedBox(height: 24),

            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E1E),
                  borderRadius: BorderRadius.circular(28),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      const Icon(
                        Icons.style,
                        size: 54,
                        color: Colors.deepPurple,
                      ),

                      const SizedBox(height: 24),

                      const Text(
                        'Pergunta',
                        style: TextStyle(color: Colors.grey, fontSize: 18),
                      ),

                      const SizedBox(height: 14),

                      Text(
                        cardAtual.pergunta,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      if (mostrarResposta) ...[
                        const SizedBox(height: 30),
                        const Divider(),
                        const SizedBox(height: 20),

                        const Text(
                          'Resposta',
                          style: TextStyle(color: Colors.grey, fontSize: 18),
                        ),

                        const SizedBox(height: 14),

                        Text(
                          cardAtual.resposta,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 22),
                        ),

                        if (cardAtual.imagemUrl != null) ...[
                          const SizedBox(height: 20),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Image.network(
                              cardAtual.imagemUrl!,
                              height: 190,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ],
                      ],
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            if (!mostrarResposta)
              SizedBox(
                width: double.infinity,
                height: 58,
                child: ElevatedButton.icon(
                  onPressed: mostrarRespostaCard,
                  icon: const Icon(Icons.visibility),
                  label: const Text(
                    'Mostrar resposta',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ),

            if (mostrarResposta)
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 58,
                      child: ElevatedButton.icon(
                        onPressed: marcarErro,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                        ),
                        icon: const Icon(Icons.close),
                        label: const Text(
                          'Errei',
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 14),

                  Expanded(
                    child: SizedBox(
                      height: 58,
                      child: ElevatedButton.icon(
                        onPressed: marcarAcerto,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                        ),
                        icon: const Icon(Icons.check),
                        label: const Text(
                          'Acertei',
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatus({
    required String titulo,
    required String valor,
    required Color cor,
  }) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          children: [
            Text(
              valor,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: cor,
              ),
            ),
            const SizedBox(height: 6),
            Text(titulo, style: const TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}
