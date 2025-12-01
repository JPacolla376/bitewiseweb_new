/// Configuração central do aplicativo BiteWise
/// 
/// Este arquivo centraliza todas as configurações do app,
/// facilitando mudanças em desenvolvimento, teste e produção.

class AppConfig {
  // --- URLs da API ---
  
  /// URL base do backend
  /// 
  /// Desenvolvimento: http://localhost:8080
  /// Produção: https://api.bitewise.com
  static const String apiBaseUrl = 'http://localhost:8080/api';

  /// Timeout para conexões (em segundos)
  static const int connectionTimeout = 30;
  
  /// Timeout para respostas (em segundos)
  static const int receiveTimeout = 30;

  // --- Endpoints ---
  
  static const String authRegister = '/auth/register';
  static const String authLogin = '/auth/login';
  static const String recipesGenerate = '/recipes/generate';

  // --- Storage seguro ---
  
  /// Chave para armazenar JWT token
  static const String tokenStorageKey = 'jwt_token';
  
  /// Chave para armazenar email do usuário
  static const String userEmailStorageKey = 'user_email';

  // --- Modelos de IA ---
  
  static const Map<String, String> aiModels = {
    'ChatGPT': 'gpt',
    'Gemini': 'gemini',
  };

  // --- Validação ---
  
  /// Padrão de validação de email
  static final emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'
  );
  
  /// Comprimento mínimo de senha
  static const int minPasswordLength = 6;

  // --- Duração de tokens ---
  
  /// Tempo padrão de expiração de token em minutos
  /// (este é apenas um referência, o backend define a expiração real)
  static const int tokenExpirationMinutes = 60;

  // --- Métodos auxiliares ---
  
  /// Obtém a URL completa de um endpoint
  static String getEndpointUrl(String endpoint) => '$apiBaseUrl$endpoint';
  
  /// Valida email
  static bool isValidEmail(String email) => emailRegex.hasMatch(email);
  
  /// Valida senha
  static bool isValidPassword(String password) => password.length >= minPasswordLength;
}
