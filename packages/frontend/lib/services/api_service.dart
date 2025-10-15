import 'package:dio/dio.dart';
import '../models/api_response.dart';
import '../utils/constants.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  late Dio _dio;

  /// Inicializa el servicio API con configuración base
  void initialize() {
    _dio = Dio(BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: ApiConstants.connectTimeout,
      receiveTimeout: ApiConstants.receiveTimeout,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    _setupInterceptors();
  }

  /// Configura los interceptores de Dio
  void _setupInterceptors() {
    // Interceptor para logging (solo en desarrollo)
    _dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      error: true,
      requestHeader: true,
      responseHeader: false,
    ));

    // Interceptor para agregar token de autorización automáticamente
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        // Aquí se puede agregar lógica para obtener el token del storage
        // Por ahora, el token se agregará manualmente en AuthService
        handler.next(options);
      },
      onResponse: (response, handler) {
        handler.next(response);
      },
      onError: (error, handler) {
        handler.next(error);
      },
    ));
  }

  /// Configura el token de autorización en el header
  void setAuthToken(String token) {
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }

  /// Remueve el token de autorización
  void clearAuthToken() {
    _dio.options.headers.remove('Authorization');
  }

  /// Realiza una petición GET
  Future<ApiResponse<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final response = await _dio.get(
        path,
        queryParameters: queryParameters,
      );

      return ApiResponse.fromJson(response.data, fromJson);
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw Exception('Error inesperado: $e');
    }
  }

  /// Realiza una petición POST
  Future<ApiResponse<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final response = await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
      );

      return ApiResponse.fromJson(response.data, fromJson);
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw Exception('Error inesperado: $e');
    }
  }

  /// Realiza una petición PUT
  Future<ApiResponse<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final response = await _dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
      );

      return ApiResponse.fromJson(response.data, fromJson);
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw Exception('Error inesperado: $e');
    }
  }

  /// Realiza una petición PATCH
  Future<ApiResponse<T>> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final response = await _dio.patch(
        path,
        data: data,
        queryParameters: queryParameters,
      );

      return ApiResponse.fromJson(response.data, fromJson);
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw Exception('Error inesperado: $e');
    }
  }

  /// Realiza una petición DELETE
  Future<ApiResponse<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final response = await _dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
      );

      return ApiResponse.fromJson(response.data, fromJson);
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw Exception('Error inesperado: $e');
    }
  }

  /// Maneja errores de Dio y los convierte en excepciones amigables
  Exception _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return Exception(AppConstants.networkError);
      
      case DioExceptionType.connectionError:
        return Exception(AppConstants.networkError);
      
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        final responseData = error.response?.data;
        
        if (responseData is Map<String, dynamic> && responseData['error'] != null) {
          final apiError = ApiError.fromJson(responseData['error']);
          return Exception(apiError.message);
        }
        
        switch (statusCode) {
          case 400:
            return Exception('Solicitud inválida');
          case 401:
            return Exception('No autorizado');
          case 403:
            return Exception('Acceso denegado');
          case 404:
            return Exception('Recurso no encontrado');
          case 422:
            return Exception('Datos de entrada inválidos');
          case 500:
            return Exception(AppConstants.serverError);
          default:
            return Exception(AppConstants.serverError);
        }
      
      case DioExceptionType.cancel:
        return Exception('Solicitud cancelada');
      
      case DioExceptionType.unknown:
      default:
        return Exception(AppConstants.unknownError);
    }
  }

  /// Actualiza la URL base (útil para cambiar entornos)
  void updateBaseUrl(String newBaseUrl) {
    _dio.options.baseUrl = newBaseUrl;
  }
}
