import '../models/user.dart';
import '../models/auth_response.dart';
import '../utils/constants.dart';
import '../utils/app_error.dart';
import 'api_service.dart';
import 'storage_service.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final ApiService _apiService = ApiService();
  final StorageService _storageService = StorageService();

  /// Inicializa el servicio de autenticación
  void initialize() {
    _apiService.initialize();
  }

  /// Registra un nuevo usuario
  Future<AuthResponse> register({
    required String email,
    required String password,
    required String nombre,
    required String apellido,
  }) async {
    try {
      final response = await _apiService.post<AuthResponse>(
        ApiConstants.registerEndpoint,
        data: {
          'email': email,
          'password': password,
          'nombre': nombre,
          'apellido': apellido,
        },
        fromJson: (json) => AuthResponse.fromJson(json),
      );

      if (response.success && response.data != null) {
        // Guardar token y usuario
        await _saveAuthData(response.data!);
        return response.data!;
      } else {
        throw Exception(response.message ?? 'Error al registrar usuario');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Autentica un usuario existente
  Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _apiService.post<AuthResponse>(
        ApiConstants.loginEndpoint,
        data: {
          'email': email,
          'password': password,
        },
        fromJson: (json) => AuthResponse.fromJson(json),
      );

      if (response.success && response.data != null) {
        // Guardar token y usuario
        await _saveAuthData(response.data!);
        return response.data!;
      } else {
        throw Exception(response.message ?? 'Error al iniciar sesión');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Obtiene el perfil del usuario autenticado
  Future<User> getProfile() async {
    try {
      final token = await _storageService.getToken();
      if (token == null) {
        throw AppError.authentication('No hay token de autenticación');
      }

      // Configurar token en las peticiones
      _apiService.setAuthToken(token);

      final response = await _apiService.get<User>(
        ApiConstants.profileEndpoint,
        fromJson: (json) => User.fromJson(json),
      );

      if (response.success && response.data != null) {
        // Actualizar datos del usuario guardados
        await _storageService.saveUser(response.data!);
        return response.data!;
      } else {
        throw AppError.unknown();
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Valida la sesión actual
  Future<bool> validateSession() async {
    try {
      final token = await _storageService.getToken();
      if (token == null) {
        return false;
      }

      // Configurar token en las peticiones
      _apiService.setAuthToken(token);

      final response = await _apiService.get<Map<String, dynamic>>(
        ApiConstants.validateEndpoint,
        fromJson: (json) => json as Map<String, dynamic>,
      );

      if (response.success && response.data != null) {
        final isValid = response.data!['valid'] as bool? ?? false;
        if (isValid) {
          // Actualizar datos del usuario si la sesión es válida
          final userData = response.data!['user'] as Map<String, dynamic>?;
          if (userData != null) {
            final user = User.fromJson(userData);
            await _storageService.saveUser(user);
          }
        }
        return isValid;
      } else {
        return false;
      }
    } catch (e) {
      // Si hay error, limpiar datos de autenticación
      await logout();
      return false;
    }
  }

  /// Cierra la sesión del usuario
  Future<void> logout() async {
    try {
      // Limpiar token de las peticiones
      _apiService.clearAuthToken();
      
      // Limpiar datos locales
      await _storageService.clearAuthData();
    } catch (e) {
      // Aunque haya error, intentar limpiar datos locales
      await _storageService.clearAuthData();
    }
  }

  /// Verifica si el usuario está autenticado
  Future<bool> isAuthenticated() async {
    final token = await _storageService.getToken();
    return token != null && token.isNotEmpty;
  }

  /// Obtiene el usuario actual desde el almacenamiento local
  Future<User?> getCurrentUser() async {
    return await _storageService.getUser();
  }

  /// Obtiene el token actual
  Future<String?> getCurrentToken() async {
    return await _storageService.getToken();
  }

  /// Carga la sesión desde el almacenamiento local
  Future<void> loadStoredSession() async {
    final token = await _storageService.getToken();
    if (token != null) {
      _apiService.setAuthToken(token);
    }
  }

  /// Actualiza el perfil del usuario
  Future<User> updateProfile({
    String? nombre,
    String? apellido,
    String? email,
  }) async {
    try {
      final token = await _storageService.getToken();
      if (token == null) {
        throw AppError.authentication('No hay token de autenticación');
      }

      _apiService.setAuthToken(token);

      final data = <String, dynamic>{};
      if (nombre != null) data['nombre'] = nombre;
      if (apellido != null) data['apellido'] = apellido;
      if (email != null) data['email'] = email;

      final response = await _apiService.put<User>(
        ApiConstants.profileEndpoint,
        data: data,
        fromJson: (json) => User.fromJson(json),
      );

      if (response.success && response.data != null) {
        // Actualizar datos del usuario guardados
        await _storageService.saveUser(response.data!);
        return response.data!;
      } else {
        throw Exception(response.message ?? 'Error al actualizar perfil');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Cambia la contraseña del usuario
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final token = await _storageService.getToken();
      if (token == null) {
        throw AppError.authentication('No hay token de autenticación');
      }

      _apiService.setAuthToken(token);

      final response = await _apiService.put<Map<String, dynamic>>(
        '/api/auth/change-password',
        data: {
          'currentPassword': currentPassword,
          'newPassword': newPassword,
        },
      );

      if (!response.success) {
        throw Exception(response.message ?? 'Error al cambiar contraseña');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Guarda los datos de autenticación
  Future<void> _saveAuthData(AuthResponse authResponse) async {
    await Future.wait([
      _storageService.saveToken(authResponse.token),
      _storageService.saveUser(authResponse.user),
    ]);
    
    // Configurar token en las peticiones
    _apiService.setAuthToken(authResponse.token);
  }

  /// Verifica si hay una sesión guardada
  Future<bool> hasStoredSession() async {
    return await _storageService.hasStoredSession();
  }
}