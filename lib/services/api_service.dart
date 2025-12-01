import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';

class ApiService {
  static const String _baseUrl = 'http://localhost:8080/api';
  static const String _tokenKey = 'jwt_token';
  static const String _userKey = 'user_email';

  late Dio _dio;
  final _secureStorage = const FlutterSecureStorage();

  ApiService() {
    _dio = Dio(
      BaseOptions(
        baseUrl: _baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        contentType: Headers.jsonContentType,
      ),
    );

    // Adiciona interceptor para JWT
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await getToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          
          // Debug: registra requisição
          print('🔗 [INTERCEPTOR] ${options.method.toUpperCase()} ${options.path}');
          if (options.queryParameters.isNotEmpty) {
            print('❓ [INTERCEPTOR] QueryParams: ${options.queryParameters}');
          }
          if (options.data != null) {
            print('📤 [INTERCEPTOR] Body: ${options.data}');
          }
          
          return handler.next(options);
        },
        onError: (error, handler) {
          // Trata erros de autenticação
          if (error.response?.statusCode == 401) {
            print('⚠️  [INTERCEPTOR] Token expirado (401)');
            _clearAuth();
          }
          return handler.next(error);
        },
      ),
    );
  }

  // --- AUTENTICAÇÃO ---

  /// Registra um novo usuário
  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        '/auth/register',
        data: {
          'name': name,
          'email': email,
          'password': password,
        },
      );
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Faz login e armazena o token JWT
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        '/auth/login',
        data: {
          'email': email,
          'password': password,
        },
      );

      final token = response.data['token'];
      if (token != null) {
        await _secureStorage.write(key: _tokenKey, value: token);
        await _secureStorage.write(key: _userKey, value: email);
      }

      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Faz logout e limpa o token
  Future<void> logout() async {
    await _clearAuth();
  }

  /// Obtém o token armazenado
  Future<String?> getToken() async {
    return await _secureStorage.read(key: _tokenKey);
  }

  /// Obtém o email do usuário logado
  Future<String?> getUserEmail() async {
    return await _secureStorage.read(key: _userKey);
  }

  /// Verifica se o usuário está autenticado
  Future<bool> isAuthenticated() async {
    final token = await getToken();
    return token != null && _isTokenValid(token);
  }

  // --- RECEITAS ---

  /// Gera receita usando IA
  /// O token JWT é enviado automaticamente no header Authorization
  /// pelo interceptador (pego do FlutterSecureStorage)
  /// 
  /// Modelos suportados:
  /// - 'gpt' para OpenAI/ChatGPT
  /// - 'gemini' para Google Gemini
  Future<Map<String, dynamic>> generateRecipe({
    required List<String> ingredients,
    required String aiModel, // 'gpt', 'gemini'
  }) async {
    try {
      // Debug: registra a requisição
      final url = '/recipes/generate?aiModel=$aiModel';
      print('🚀 [API] Gerando receita com modelo: $aiModel');
      print('📍 [API] URL: $_baseUrl$url');
      print('📦 [API] Ingredientes: $ingredients');
      
      final response = await _dio.post(
        '/recipes/generate',
        queryParameters: {'aiModel': aiModel},
        data: {'ingredients': ingredients},
      );
      
      print('✅ [API] Resposta recebida com sucesso');
      return response.data;
    } on DioException catch (e) {
      print('❌ [API] Erro na geração: ${e.message}');
      throw _handleError(e);
    }
  }

  // --- UTILITÁRIOS ---

  /// Valida se o token ainda é válido
  bool _isTokenValid(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return false;

      // Decodifica o payload
      final payload = _decodeBase64(parts[1]);
      final decoded = jsonDecode(payload);

      // Verifica se expirou
      final exp = decoded['exp'] as int?;
      if (exp == null) return false;

      final expiryDate = DateTime.fromMillisecondsSinceEpoch(exp * 1000);
      return expiryDate.isAfter(DateTime.now());
    } catch (e) {
      return false;
    }
  }

  /// Decodifica base64 com padding
  String _decodeBase64(String str) {
    String output = str.replaceAll('-', '+').replaceAll('_', '/');
    switch (output.length % 4) {
      case 0:
        break;
      case 2:
        output += '==';
        break;
      case 3:
        output += '=';
        break;
      default:
        throw Exception('Illegal base64url string!');
    }
    return utf8.decode(base64Url.decode(output));
  }

  /// Limpa dados de autenticação
  Future<void> _clearAuth() async {
    await _secureStorage.delete(key: _tokenKey);
    await _secureStorage.delete(key: _userKey);
  }

  /// Trata erros do Dio
  String _handleError(DioException error) {
    if (error.response != null) {
      final message = error.response?.data['message'] ?? 
                     error.response?.data['error'] ??
                     'Erro na requisição';
      return message.toString();
    } else if (error.type == DioExceptionType.connectionTimeout) {
      return 'Tempo de conexão expirado';
    } else if (error.type == DioExceptionType.receiveTimeout) {
      return 'Tempo de resposta expirado';
    } else if (error.type == DioExceptionType.unknown) {
      return 'Erro de conexão: verifique se o backend está rodando em localhost:8080';
    }
    return 'Erro desconhecido: ${error.message}';
  }
}

// Instância singleton
final apiService = ApiService();
