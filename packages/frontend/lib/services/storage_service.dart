import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/user.dart';
import '../utils/constants.dart';

class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  /// Guarda el token JWT de forma segura
  Future<void> saveToken(String token) async {
    await _secureStorage.write(key: StorageKeys.authToken, value: token);
  }

  /// Obtiene el token JWT guardado
  Future<String?> getToken() async {
    return await _secureStorage.read(key: StorageKeys.authToken);
  }

  /// Elimina el token JWT
  Future<void> deleteToken() async {
    await _secureStorage.delete(key: StorageKeys.authToken);
  }

  /// Guarda los datos del usuario en SharedPreferences
  Future<void> saveUser(User user) async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = jsonEncode(user.toJson());
    await prefs.setString(StorageKeys.userData, userJson);
  }

  /// Obtiene los datos del usuario guardados
  Future<User?> getUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString(StorageKeys.userData);
      
      if (userJson != null) {
        final userMap = jsonDecode(userJson) as Map<String, dynamic>;
        return User.fromJson(userMap);
      }
      
      return null;
    } catch (e) {
      // Si hay error al decodificar, limpiar datos corruptos
      await clearUserData();
      return null;
    }
  }

  /// Elimina los datos del usuario
  Future<void> deleteUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(StorageKeys.userData);
  }

  /// Limpia todos los datos de autenticación
  Future<void> clearAuthData() async {
    await Future.wait([
      deleteToken(),
      deleteUser(),
    ]);
  }

  /// Limpia todos los datos del usuario (incluyendo datos corruptos)
  Future<void> clearUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(StorageKeys.userData);
  }

  /// Limpia todo el almacenamiento
  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    await _secureStorage.deleteAll();
  }

  /// Verifica si el usuario tiene una sesión guardada
  Future<bool> hasStoredSession() async {
    final token = await getToken();
    final user = await getUser();
    return token != null && user != null;
  }

  /// Marca si es el primer lanzamiento de la app
  Future<void> setFirstLaunch(bool isFirstLaunch) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(StorageKeys.isFirstLaunch, isFirstLaunch);
  }

  /// Verifica si es el primer lanzamiento de la app
  Future<bool> isFirstLaunch() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(StorageKeys.isFirstLaunch) ?? true;
  }

  /// Guarda un valor genérico en SharedPreferences
  Future<void> setString(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
  }

  /// Obtiene un valor genérico de SharedPreferences
  Future<String?> getString(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(key);
  }

  /// Guarda un valor booleano en SharedPreferences
  Future<void> setBool(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  /// Obtiene un valor booleano de SharedPreferences
  Future<bool?> getBool(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(key);
  }

  /// Guarda un valor entero en SharedPreferences
  Future<void> setInt(String key, int value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(key, value);
  }

  /// Obtiene un valor entero de SharedPreferences
  Future<int?> getInt(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(key);
  }

  /// Elimina una clave específica de SharedPreferences
  Future<void> remove(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(key);
  }

  /// Elimina una clave específica del almacenamiento seguro
  Future<void> removeSecure(String key) async {
    await _secureStorage.delete(key: key);
  }

  /// Obtiene todas las claves de SharedPreferences
  Future<Set<String>> getAllKeys() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getKeys();
  }

  /// Verifica si existe una clave en SharedPreferences
  Future<bool> containsKey(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(key);
  }
}
