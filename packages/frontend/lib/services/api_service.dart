import 'package:dio/dio.dart';
import '../models/api_response.dart';
import '../utils/constants.dart';
import '../utils/app_error.dart';

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
      throw AppError.unknown();
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
      throw AppError.unknown();
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
      throw AppError.unknown();
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
      throw AppError.unknown();
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
      throw AppError.unknown();
    }
  }

  /// Maneja errores de Dio y los convierte en AppError amigables
  AppError _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return AppError.network();
      
      case DioExceptionType.connectionError:
        return AppError.network();
      
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        final responseData = error.response?.data;
        
        // Si el backend envía un error estructurado, usarlo
        if (responseData is Map<String, dynamic> && responseData['error'] != null) {
          final apiError = ApiError.fromJson(responseData['error']);
          return AppError.fromApiError(apiError);
        }
        
        // Manejar códigos de estado HTTP específicos
        switch (statusCode) {
          case 400:
            return const AppError(
              message: 'Solicitud inválida',
              code: 'BAD_REQUEST',
              statusCode: 400,
            );
          case 401:
            return const AppError(
              message: 'No autorizado',
              code: 'UNAUTHORIZED',
              statusCode: 401,
            );
          case 403:
            return const AppError(
              message: 'Acceso denegado',
              code: 'FORBIDDEN',
              statusCode: 403,
            );
          case 404:
            return const AppError(
              message: 'Recurso no encontrado',
              code: 'NOT_FOUND',
              statusCode: 404,
            );
          case 422:
            return const AppError(
              message: 'Datos de entrada inválidos',
              code: 'VALIDATION_ERROR',
              statusCode: 422,
            );
          case 500:
            return AppError.server();
          default:
            return AppError.server();
        }
      
      case DioExceptionType.cancel:
        return const AppError(
          message: 'Solicitud cancelada',
          code: 'REQUEST_CANCELLED',
        );
      
      case DioExceptionType.unknown:
      default:
        return AppError.unknown();
    }
  }

  /// Actualiza la URL base (útil para cambiar entornos)
  void updateBaseUrl(String newBaseUrl) {
    _dio.options.baseUrl = newBaseUrl;
  }
}
