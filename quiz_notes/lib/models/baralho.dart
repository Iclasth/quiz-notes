class Baralho {
  String id;
  String nome;
  String descricao;

  Baralho({
    required this.id,
    required this.nome,
    required this.descricao,
  });

  factory Baralho.fromJson(Map<String, dynamic> json) {
    return Baralho(
      id: json['id_baralho']?.toString() ?? '',
      nome: json['nome'] ?? '',
      descricao: json['descricao'] ?? '',
    );
  }
}