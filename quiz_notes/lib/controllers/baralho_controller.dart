import '../models/baralho.dart';
import '../services/api_service.dart';

class BaralhoController {
  final ApiService _apiService = ApiService();
  List<Baralho> baralhos = [];
  bool isLoading = false;

  Future<void> carregarBaralhos() async {
    isLoading = true;
    try {
      final userId = await _apiService.getUserId();
      if (userId != null) {
        final response = await _apiService.dio.get('/users/$userId/decks');
        if (response.statusCode == 200) {
          final List<dynamic> data = response.data;
          baralhos = data.map((item) => Baralho.fromJson(item)).toList();
        }
      }
    } catch (e) {
      // Ignora erro
    } finally {
      isLoading = false;
    }
  }

  Future<bool> criarBaralho(String nome, String descricao) async {
    try {
      final userId = await _apiService.getUserId();
      if (userId != null) {
        final response = await _apiService.dio.post(
          '/users/$userId/decks',
          data: {
            'nome': nome,
            'descricao': descricao,
          },
        );
        if (response.statusCode == 201) {
          return true;
        }
      }
    } catch (e) {
      // Falha ao criar
    }
    return false;
  }
}
