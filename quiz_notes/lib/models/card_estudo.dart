class CardEstudo {
  String pergunta;
  String resposta;
  int acertos;
  int erros;
  int intervalo;

  CardEstudo({
    required this.pergunta,
    required this.resposta,
    this.acertos = 0,
    this.erros = 0,
    this.intervalo = 1,
  });
}
