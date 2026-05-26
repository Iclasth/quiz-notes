import 'package:flutter/material.dart';
import '../../models/dashboard_stats.dart';
import '../../services/api_service.dart';

class DesempenhoPage extends StatefulWidget {
  const DesempenhoPage({super.key});

  @override
  State<DesempenhoPage> createState() => _DesempenhoPageState();
}

class _DesempenhoPageState extends State<DesempenhoPage> {
  bool _isLoading = false;
  DashboardStats? _estatisticas;

  Future<void> _fetchDatabaseStats() async {
    setState(() => _isLoading = true);

    try {
      final apiService = ApiService();
      final userId = await apiService.getUserId();
      if (userId != null) {
        final response = await apiService.dio.get('/users/$userId/stats');
        if (response.statusCode == 200 && response.data != null) {
          setState(() {
            _estatisticas = DashboardStats.fromJson(response.data);
          });
        } else {
          throw Exception("Falha ao carregar dados do servidor");
        }
      } else {
        throw Exception("Usuário não identificado");
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erro ao conectar com o banco: $e")),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchDatabaseStats();
  }

  @override
  Widget build(BuildContext context) {
    final stats = _estatisticas;

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "Estatísticas & Previsão",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _fetchDatabaseStats,
          ),
        ],
      ),
      body: _isLoading || stats == null
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF915BFF)),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  _buildSectionTitle("Hoje"),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A1A1A),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFF262626)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildQuickMetric(
                          Icons.check_circle_rounded,
                          const Color(0xFF2ECC71),
                          "${stats.totalAcertos}",
                          "Acertos",
                        ),
                        Container(
                          width: 1,
                          height: 40,
                          color: const Color(0xFF333333),
                        ),
                        _buildQuickMetric(
                          Icons.cancel_rounded,
                          const Color(0xFFE74C3C),
                          "${stats.totalErros}",
                          "Erros",
                        ),
                        Container(
                          width: 1,
                          height: 40,
                          color: const Color(0xFF333333),
                        ),
                        _buildQuickMetric(
                          Icons.local_fire_department_rounded,
                          const Color(0xFFE67E22),
                          "${stats.sequenciaDias}d",
                          "Fogo",
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),
                  _buildSectionTitle("Previsão de Carga"),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A1A1A),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFF262626)),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          "Histórico e volume de revisões futuras do banco",
                          style: TextStyle(color: Colors.grey, fontSize: 13),
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          height: 150,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: stats.dadosGrafico.map((altura) {
                              return Expanded(
                                child: Container(
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 4,
                                  ),
                                  height: altura * 130,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.bottomCenter,
                                      end: Alignment.topCenter,
                                      colors: [
                                        const Color(
                                          0xFF2ECC71,
                                        ).withValues(alpha: 0.2),
                                        const Color(
                                          0xFF2ECC71,
                                        ).withValues(alpha: 0.85),
                                      ],
                                    ),
                                    borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(4),
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                        Container(height: 1, color: const Color(0xFF333333)),
                        const SizedBox(height: 20),
                        _buildStatRow(
                          "Total revisado:",
                          "${stats.totalRevisoes} cards",
                        ),
                        _buildStatRow(
                          "Taxa de acertos:",
                          "${stats.taxaAcerto}%",
                        ),
                        _buildStatRow(
                          "Aproveitamento geral:",
                          stats.taxaAcerto > 70 ? "Excelente" : "Regular",
                        ),
                      ],
                    ),
                  ),
                   const SizedBox(height: 24),
                ],
              ),
            ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0, left: 4),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildQuickMetric(
    IconData icon,
    Color color,
    String value,
    String label,
  ) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
      ],
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 14)),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}