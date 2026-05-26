import 'package:flutter/foundation.dart';
import '../models/card_estudo.dart';
import '../services/api_service.dart';

class RevisaoController extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  List<CardEstudo> cards = [];

  int indiceAtual = 0;

  // Variáveis de estado da sessão
  DateTime? startTime;
  int totalCardsSessao = 0;
  int totalAcertosSessao = 0;
  int totalErrosSessao = 0;
  bool sessaoConcluida = false;

  CardEstudo get cardAtual {
    if (cards.isEmpty) return CardEstudo(pergunta: 'Sem cards', resposta: '', baralhoId: '');
    return cards[indiceAtual];
  }

  Future<void> carregarRevisao(String deckId) async {
    try {
      final response = await _apiService.dio.get('/decks/$deckId/revisao');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        cards = data.map((item) => CardEstudo.fromJson(item)).toList();
        totalCardsSessao = cards.length;
        startTime = DateTime.now();
        sessaoConcluida = false;
        totalAcertosSessao = 0;
        totalErrosSessao = 0;
        indiceAtual = 0;
        notifyListeners();
      }
    } catch (e) {
      // Ignora erro
    }
  }

  Future<void> _submeterRevisao(CardEstudo card, int qualidade) async {
    if (card.id != null) {
      try {
        final response = await _apiService.dio.post('/cards/${card.id}/revisao', data: {'qualidade': qualidade});
        if (response.statusCode == 200 && response.data != null) {
          final updated = CardEstudo.fromJson(response.data);
          card.acertos = updated.acertos;
          card.erros = updated.erros;
          card.intervalo = updated.intervalo;
          notifyListeners();
        }
      } catch (e) {
        // Ignora erro
      }
    }
  }

  void acertou() {
    if (cards.isEmpty) return;

    final card = cardAtual;
    _submeterRevisao(card, 4);

    // Rastreamento da sessão
    totalAcertosSessao++;

    // Simulação local realista de SM-2
    if (card.acertos == 0) {
      card.intervalo = 1;
    } else if (card.acertos == 1) {
      card.intervalo = 6;
    } else {
      card.intervalo = (card.intervalo * 2.5).round();
    }
    card.acertos++;

    // Remove da fila da sessão ativa
    cards.removeAt(indiceAtual);

    if (cards.isEmpty) {
      sessaoConcluida = true;
    } else {
      if (indiceAtual >= cards.length) {
        indiceAtual = 0;
      }
    }

    notifyListeners();
  }

  void errou() {
    if (cards.isEmpty) return;

    final card = cardAtual;
    _submeterRevisao(card, 1);

    // Rastreamento da sessão
    totalErrosSessao++;

    // Simulação local realista de SM-2
    card.acertos = 0;
    card.intervalo = 1;
    card.erros++;

    // Remove da fila da sessão ativa
    cards.removeAt(indiceAtual);

    if (cards.isEmpty) {
      sessaoConcluida = true;
    } else {
      if (indiceAtual >= cards.length) {
        indiceAtual = 0;
      }
    }

    notifyListeners();
  }
}
