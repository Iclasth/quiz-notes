import '../models/card_estudo.dart';
import '../services/api_service.dart';

class RevisaoController {
  final ApiService _apiService = ApiService();
  List<CardEstudo> cards = [
    CardEstudo(
      pergunta: 'O que é Flutter?',
      resposta:
          'Flutter é um framework para criar aplicativos multiplataforma.',
      baralhoId: 'flutter_basico',
    ),
    CardEstudo(
      pergunta: 'O que é Dart?',
      resposta: 'Dart é a linguagem de programação usada no Flutter.',
      baralhoId: 'flutter_basico',
    ),
    CardEstudo(
      pergunta: 'O que é MVC?',
      resposta: 'MVC separa o sistema em Model, View e Controller.',
      baralhoId: 'flutter_basico',
    ),
  ];

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
        if (data.isNotEmpty) {
          cards = data.map((item) => CardEstudo(
            id: item['id_card']?.toString(),
            pergunta: item['frente'] ?? '',
            resposta: item['verso'] ?? '',
            baralhoId: item['id_baralho']?.toString() ?? deckId,
          )).toList();
          indiceAtual = 0;
        }
      }
    } catch (e) {
      // Fallback para mock mantido visualmente
    }
  }

  Future<void> _submeterRevisao(int qualidade) async {
    final card = cardAtual;
    if (card.id != null) {
      try {
        await _apiService.dio.post('/cards/${card.id}/revisao', data: {'qualidade': qualidade});
      } catch (e) {
        // Ignora erro em background
      }
    }
  }

  void acertou() {
    _submeterRevisao(4);
    cardAtual.acertos++;
    cardAtual.intervalo *= 2;
    proximoCard();
  }

  void errou() {
    _submeterRevisao(1);
    cardAtual.erros++;
    cardAtual.intervalo = 1;
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
