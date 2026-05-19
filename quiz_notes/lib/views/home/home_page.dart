import 'package:flutter/material.dart';
import '../auth/login_page.dart';
import '../baralhos/baralhos_page.dart';
import '../desempenho/desempenho_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key, required this.title});

  final String title;

  void abrirBaralhos(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => BaralhosPage()),
    );
  }

  void abrirDesempenho(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const DesempenhoPage()),
    );
  }

  void sair(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz Notes'),
        centerTitle: true,

        actions: [
          IconButton(
            onPressed: () => sair(context),
            icon: const Icon(Icons.logout),
            tooltip: 'Sair',
          ),
        ],
      ),

      body: SingleChildScrollView(
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
                    value: '24',
                    icon: Icons.style,
                    color: Colors.deepPurple,
                  ),
                ),

                const SizedBox(width: 16),

                Expanded(
                  child: _buildInfoCard(
                    title: 'Acerto',
                    value: '82%',
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
                    value: '7 dias',
                    icon: Icons.local_fire_department,
                    color: Colors.orange,
                  ),
                ),

                const SizedBox(width: 16),

                Expanded(
                  child: _buildInfoCard(
                    title: 'Baralhos',
                    value: '3',
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
                onPressed: () => abrirBaralhos(context),

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
                onPressed: () => abrirDesempenho(context),

                icon: const Icon(Icons.bar_chart),

                label: const Text('Desempenho', style: TextStyle(fontSize: 18)),
              ),
            ),
          ],
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
