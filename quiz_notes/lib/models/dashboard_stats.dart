class DashboardStats {
  final int totalRevisoes;
  final int totalAcertos;
  final int totalErros;
  final double taxaAcerto;
  final int sequenciaDias;
  final List<double> dadosGrafico;
  final int totalBaralhos;
  final int totalCards;

  const DashboardStats({
    required this.totalRevisoes,
    required this.totalAcertos,
    required this.totalErros,
    required this.taxaAcerto,
    required this.sequenciaDias,
    required this.dadosGrafico,
    required this.totalBaralhos,
    required this.totalCards,
  });

  factory DashboardStats.fromJson(Map<String, dynamic> json) {
    return DashboardStats(
      totalRevisoes: json['total_revisoes'] ?? 0,
      totalAcertos: json['total_acertos'] ?? 0,
      totalErros: json['total_erros'] ?? 0,
      taxaAcerto: (json['taxa_acerto'] ?? 0.0).toDouble(),
      sequenciaDias: json['sequencia_dias'] ?? 0,
      dadosGrafico: List<double>.from(
        (json['dados_grafico'] as List?)?.map((e) => (e ?? 0.0).toDouble()) ?? [],
      ),
      totalBaralhos: json['total_baralhos'] ?? 0,
      totalCards: json['total_cards'] ?? 0,
    );
  }
}
