import 'package:flutter/material.dart';
import '../auth/login_page.dart';
import '../baralhos/baralhos_page.dart';
import '../desempenho/desempenho_page.dart';
import '../../services/api_service.dart';
import '../../models/dashboard_stats.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.title});

  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ApiService _apiService = ApiService();
  DashboardStats? _stats;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _carregarStats();
  }

  Future<void> _carregarStats() async {
    setState(() => _isLoading = true);
    try {
      final userId = await _apiService.getUserId();
      if (userId != null) {
        final response = await _apiService.dio.get('/users/$userId/stats');
        if (response.statusCode == 200 && response.data != null) {
          setState(() {
            _stats = DashboardStats.fromJson(response.data);
          });
        }
      }
    } catch (e) {
      // Ignora erro
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void abrirBaralhos() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => BaralhosPage()),
    ).then((_) => _carregarStats());
  }

  void abrirDesempenho() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const DesempenhoPage()),
    ).then((_) => _carregarStats());
  }

  void sair() async {
    await _apiService.logout();
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final stats = _stats;
    final totalCards = stats?.totalCards ?? 0;
    final taxaAcerto = stats?.taxaAcerto ?? 0.0;
    final sequencia = stats?.sequenciaDias ?? 0;
    final totalBaralhos = stats?.totalBaralhos ?? 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz Notes'),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: sair,
            icon: const Icon(Icons.logout),
            tooltip: 'Sair',
          ),
        ],
      ),
      body: _isLoading && stats == null
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF915BFF)),
            )
          : RefreshIndicator(
              onRefresh: _carregarStats,
              color: const Color(0xFF915BFF),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Olá, estudante 👋',
                      style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Escolha um baralho para revisar ou gerenciar seus cards.',
                      style: TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                    const SizedBox(height: 30),
                    Row(
                      children: [
                        Expanded(
                          child: _buildInfoCard(
                            title: 'Cards',
                            value: '$totalCards',
                            icon: Icons.style,
                            color: Colors.deepPurple,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildInfoCard(
                            title: 'Acerto',
                            value: '${taxaAcerto.toStringAsFixed(1)}%',
                            icon: Icons.check_circle,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildInfoCard(
                            title: 'Sequência',
                            value: '$sequencia dias',
                            icon: Icons.local_fire_department,
                            color: Colors.orange,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildInfoCard(
                            title: 'Baralhos',
                            value: '$totalBaralhos',
                            icon: Icons.layers,
                            color: Colors.blue,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),
                    SizedBox(
                      width: double.infinity,
                      height: 60,
                      child: ElevatedButton.icon(
                        onPressed: abrirBaralhos,
                        icon: const Icon(Icons.folder),
                        label: const Text(
                          'Ver baralhos',
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 60,
                      child: OutlinedButton.icon(
                        onPressed: abrirDesempenho,
                        icon: const Icon(Icons.bar_chart),
                        label: const Text('Desempenho', style: TextStyle(fontSize: 18)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildInfoCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 36),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
