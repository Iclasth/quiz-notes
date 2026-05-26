import 'package:flutter/material.dart';
import '../../controllers/revisao_controller.dart';
import '../../models/card_estudo.dart';

class RevisaoPage extends StatefulWidget {
  final String deckId;
  const RevisaoPage({super.key, required this.deckId});

  @override
  State<RevisaoPage> createState() => _RevisaoPageState();
}

class _RevisaoPageState extends State<RevisaoPage> {
  final RevisaoController controller = RevisaoController();

  bool mostrarResposta = false;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    controller.addListener(_onControllerChanged);
    _carregarRevisao();
  }

  @override
  void dispose() {
    controller.removeListener(_onControllerChanged);
    controller.dispose();
    super.dispose();
  }

  void _onControllerChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _carregarRevisao() async {
    setState(() {
      isLoading = true;
    });
    await controller.carregarRevisao(widget.deckId);
    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

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

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.toString().padLeft(2, '0');
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return "$minutes:$seconds";
  }

  @override
  Widget build(BuildContext context) {
    final cardAtual = controller.cardAtual;

    return Scaffold(
      appBar: AppBar(title: const Text('Revisão'), centerTitle: true),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : controller.sessaoConcluida
              ? _buildCelebracao()
              : controller.cards.isEmpty
                  ? _buildEmptyState()
                  : _buildRevisaoFlow(cardAtual),
    );
  }

  Widget _buildCelebracao() {
    final duracao = DateTime.now().difference(controller.startTime ?? DateTime.now());
    final taxaAcerto = controller.totalCardsSessao > 0
        ? (controller.totalAcertosSessao / controller.totalCardsSessao * 100).toStringAsFixed(0)
        : '0';

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.emoji_events_rounded,
              size: 90,
              color: Colors.orange,
            ),
            const SizedBox(height: 24),
            const Text(
              'Parabéns! 🎉',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Você concluiu a revisão do dia!',
              style: TextStyle(color: Colors.grey, fontSize: 18),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0xFF2C2C2C)),
              ),
              child: Column(
                children: [
                  const Text(
                    'Resumo da Sessão',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildMetricItem(
                        icon: Icons.style,
                        color: Colors.blue,
                        value: '${controller.totalCardsSessao}',
                        label: 'Cards',
                      ),
                      _buildMetricItem(
                        icon: Icons.check_circle,
                        color: Colors.green,
                        value: '$taxaAcerto%',
                        label: 'Acertos',
                      ),
                      _buildMetricItem(
                        icon: Icons.timer,
                        color: Colors.orange,
                        value: _formatDuration(duracao),
                        label: 'Tempo',
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            const Icon(Icons.calendar_month, color: Colors.grey, size: 28),
            const SizedBox(height: 8),
            const Text(
              'Próxima revisão agendada para amanhã.',
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
            const Text(
              'Volte amanhã para novos cards!',
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back),
                label: const Text(
                  'Voltar para o Baralho',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricItem({
    required IconData icon,
    required Color color,
    required String value,
    required String label,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(color: Colors.grey, fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.check_circle_outline,
            size: 72,
            color: Colors.green,
          ),
          const SizedBox(height: 16),
          const Text(
            'Tudo limpo por hoje!',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Nenhum card pendente de revisão.',
            style: TextStyle(color: Colors.grey, fontSize: 16),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Voltar'),
          ),
        ],
      ),
    );
  }

  Widget _buildRevisaoFlow(CardEstudo cardAtual) {
    return Padding(
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
