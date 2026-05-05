import '../models/card_estudo.dart';

class RevisaoController {
  List<CardEstudo> cards = [
    CardEstudo(
      pergunta: 'O que é Flutter?',
      resposta: 'Flutter é um framework para criar aplicativos multiplataforma.',
      baralhoId: 'flutter_basico',
    ),
    CardEstudo(
      pergunta: 'O que é Dart?',
      resposta: 'Dart é a linguagem de programação usada no Flutter.',
      baralhoId: 'flutter_basico',
    ),
    CardEstudo(
      pergunta: 'O que é MVC?',
      resposta: 'MVC é uma arquitetura que separa Model, View e Controller.',
      baralhoId: 'flutter_basico',
    ),
  ];

  int indiceAtual = 0;

  CardEstudo get cardAtual {
    return cards[indiceAtual];
  }

  void acertou() {
    cardAtual.acertos++;
    cardAtual.intervalo *= 2;
    proximoCard();
  }

  void errou() {
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
