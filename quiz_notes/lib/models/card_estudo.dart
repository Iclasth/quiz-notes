class CardEstudo {
  String pergunta;
  String resposta;
  String baralhoId;
  String? imagemUrl;
  int acertos;
  int erros;
  int intervalo;

  CardEstudo({
    required this.pergunta,
    required this.resposta,
    required this.baralhoId,
    this.imagemUrl,
    this.acertos = 0,
    this.erros = 0,
    this.intervalo = 1,
  });
}