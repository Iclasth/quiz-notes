import '../models/card_estudo.dart';
import '../services/api_service.dart';

class RevisaoController {
  final ApiService _apiService = ApiService();
  List<CardEstudo> cards = [];

  int indiceAtual = 0;

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
        indiceAtual = 0;
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
        }
      } catch (e) {
        // Ignora erro
      }
    }
  }

  void acertou() {
    final card = cardAtual;
    _submeterRevisao(card, 4);
    card.acertos++;
    card.intervalo *= 2;
    proximoCard();
  }

  void errou() {
    final card = cardAtual;
    _submeterRevisao(card, 1);
    card.erros++;
    card.intervalo = 1;
    proximoCard();
  }

  void proximoCard() {
    if (indiceAtual < cards.length - 1) {
      indiceAtual++;
    } else {
      indiceAtual = 0;
    }
  }
}
