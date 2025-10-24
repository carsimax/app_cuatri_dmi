class ApiConstants {
  // Base URLs para diferentes entornos
  static const String baseUrlAndroidEmulator = 'http://10.0.2.2:3000';
  static const String baseUrlIosSimulator = 'http://localhost:3000';
  static const String baseUrlProduction = 'https://api.example.com';
  
  // URL base actual (cambiar según el entorno)
  static const String baseUrl = baseUrlAndroidEmulator;
  
  // Endpoints de autenticación
  static const String registerEndpoint = '/api/auth/register';
  static const String loginEndpoint = '/api/auth/login';
  static const String profileEndpoint = '/api/auth/profile';
  static const String validateEndpoint = '/api/auth/validate';
  static const String logoutEndpoint = '/api/auth/logout';
  
  // Timeouts
  static const Duration connectTimeout = Duration(seconds: 5);
  static const Duration receiveTimeout = Duration(seconds: 3);
}

class StorageKeys {
  static const String authToken = 'auth_token';
  static const String userData = 'user_data';
  static const String isFirstLaunch = 'is_first_launch';
}

class AppConstants {
  static const String appName = 'App Cuatri';
  static const String appVersion = '1.0.0';
  
  // Mensajes de error comunes
  static const String networkError = 'Error de conexión. Verifica tu internet.';
  static const String serverError = 'Error del servidor. Intenta más tarde.';
  static const String unknownError = 'Error inesperado. Intenta nuevamente.';
  
  // Validaciones
  static const int minPasswordLength = 6;
  static const int maxNameLength = 50;
  static const int minNameLength = 2;
}