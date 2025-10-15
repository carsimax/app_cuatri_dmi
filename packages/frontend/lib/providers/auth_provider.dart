import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  User? _user;
  bool _isAuthenticated = false;
  bool _isLoading = false;
  String? _error;

  // Getters
  User? get user => _user;
  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Inicializa el provider de autenticación
  Future<void> initialize() async {
    _isLoading = true;
    try {
      _authService.initialize();
      await _authService.loadStoredSession();
      
      // Verificar si hay una sesión guardada
      if (await _authService.hasStoredSession()) {
        await _validateStoredSession();
      }
    } catch (e) {
      _error = 'Error al inicializar: $e';
    } finally {
      _isLoading = false;
      // Notificar cambios solo al final
      notifyListeners();
    }
  }

  /// Valida la sesión guardada
  Future<void> _validateStoredSession() async {
    try {
      final isValid = await _authService.validateSession();
      if (isValid) {
        final user = await _authService.getCurrentUser();
        if (user != null) {
          _user = user;
          _isAuthenticated = true;
        }
      } else {
        await _logoutInternal();
      }
    } catch (e) {
      await _logoutInternal();
    }
  }

  /// Inicia sesión con email y contraseña
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _clearError();
    
    try {
      final authResponse = await _authService.login(
        email: email,
        password: password,
      );

      _setUser(authResponse.user);
      _setAuthenticated(true);
      
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Registra un nuevo usuario
  Future<bool> register({
    required String email,
    required String password,
    required String nombre,
    required String apellido,
  }) async {
    _setLoading(true);
    _clearError();
    
    try {
      final authResponse = await _authService.register(
        email: email,
        password: password,
        nombre: nombre,
        apellido: apellido,
      );

      _setUser(authResponse.user);
      _setAuthenticated(true);
      
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Cierra la sesión del usuario
  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      await _authService.logout();
      _user = null;
      _isAuthenticated = false;
      _error = null;
    } catch (e) {
      _error = 'Error al cerrar sesión: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Método interno para logout sin notificar listeners (usado durante inicialización)
  Future<void> _logoutInternal() async {
    try {
      await _authService.logout();
      _user = null;
      _isAuthenticated = false;
      _error = null;
    } catch (e) {
      _error = 'Error al cerrar sesión: $e';
    }
  }

  /// Actualiza el perfil del usuario
  Future<bool> updateProfile({
    String? nombre,
    String? apellido,
    String? email,
  }) async {
    if (_user == null) {
      _setError('No hay usuario autenticado');
      return false;
    }

    _setLoading(true);
    _clearError();
    
    try {
      final updatedUser = await _authService.updateProfile(
        nombre: nombre,
        apellido: apellido,
        email: email,
      );

      _setUser(updatedUser);
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Cambia la contraseña del usuario
  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    if (_user == null) {
      _setError('No hay usuario autenticado');
      return false;
    }

    _setLoading(true);
    _clearError();
    
    try {
      await _authService.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
      
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Obtiene el perfil actualizado del usuario
  Future<bool> refreshProfile() async {
    if (!_isAuthenticated) {
      return false;
    }

    _setLoading(true);
    _clearError();
    
    try {
      final user = await _authService.getProfile();
      _setUser(user);
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Valida la sesión actual
  Future<bool> validateSession() async {
    if (!_isAuthenticated) {
      return false;
    }

    try {
      final isValid = await _authService.validateSession();
      if (!isValid) {
        await logout();
      }
      return isValid;
    } catch (e) {
      await logout();
      return false;
    }
  }

  /// Limpia el mensaje de error
  void clearError() {
    _clearError();
  }

  /// Verifica si el usuario está verificado
  bool get isUserVerified => _user?.emailVerified ?? false;

  /// Obtiene el nombre completo del usuario
  String get userFullName => _user?.fullName ?? '';

  /// Obtiene las iniciales del usuario
  String get userInitials => _user?.initials ?? '';

  // Métodos privados para actualizar el estado
  void _setUser(User? user) {
    _user = user;
    notifyListeners();
  }

  void _setAuthenticated(bool isAuthenticated) {
    _isAuthenticated = isAuthenticated;
    notifyListeners();
  }

  void _setLoading(bool isLoading) {
    _isLoading = isLoading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }

}
