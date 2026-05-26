class CardEstudo {
  String? id;
  String pergunta;
  String resposta;
  String baralhoId;
  String? imagemUrl;
  int acertos;
  int erros;
  int intervalo;

  CardEstudo({
    this.id,
    required this.pergunta,
    required this.resposta,
    required this.baralhoId,
    this.imagemUrl,
    this.acertos = 0,
    this.erros = 0,
    this.intervalo = 1,
  });

  factory CardEstudo.fromJson(Map<String, dynamic> json) {
    return CardEstudo(
      id: json['id_card']?.toString(),
      pergunta: json['frente'] ?? '',
      resposta: json['verso'] ?? '',
      baralhoId: json['id_baralho']?.toString() ?? '',
      imagemUrl: json['imagem_url']?.toString(),
      acertos: json['acertos'] is int ? json['acertos'] : int.tryParse(json['acertos']?.toString() ?? '') ?? 0,
      erros: json['erros'] is int ? json['erros'] : int.tryParse(json['erros']?.toString() ?? '') ?? 0,
      intervalo: json['intervalo'] is int ? json['intervalo'] : int.tryParse(json['intervalo']?.toString() ?? '') ?? 1,
    );
  }
}