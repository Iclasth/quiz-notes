import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: 'http://localhost:3000/api',
    connectTimeout: const Duration(seconds: 5),
    receiveTimeout: const Duration(seconds: 3),
  ));

  static const String _userIdKey = 'user_id';

  Future<void> saveUserId(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userIdKey, userId);
  }

  Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userIdKey);
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userIdKey);
  }

  Future<Map<String, dynamic>?> login(String email, String senha) async {
    try {
      final response = await _dio.post('/login', data: {
        'email': email,
        'senha': senha,
      });

      if (response.statusCode == 200 && response.data != null) {
        final userId = response.data['id_usuario'];
        if (userId != null) {
          await saveUserId(userId.toString());
        }
        return response.data;
      }
    } catch (e) {
      throw Exception('Erro ao fazer login');
    }
    return null;
  }

  Future<Map<String, dynamic>?> cadastrar(String nome, String email, String senha) async {
    try {
      final response = await _dio.post('/users', data: {
        'nome': nome,
        'email': email,
        'senha': senha,
      });

      if (response.statusCode == 201) {
        return response.data;
      }
    } catch (e) {
      throw Exception('Erro ao cadastrar');
    }
    return null;
  }

  Dio get dio => _dio;
}
