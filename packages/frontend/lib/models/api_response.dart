class ApiResponse<T> {
  final bool success;
  final T? data;
  final String? message;
  final int statusCode;
  final DateTime timestamp;
  final PaginationMeta? meta;
  final ApiError? error;

  const ApiResponse({
    required this.success,
    this.data,
    this.message,
    required this.statusCode,
    required this.timestamp,
    this.meta,
    this.error,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic)? fromJsonT,
  ) {
    return ApiResponse(
      success: json['success'] ?? false,
      data: json['data'] != null && fromJsonT != null
          ? fromJsonT(json['data'])
          : json['data'],
      message: json['message'],
      statusCode: json['statusCode'] ?? 500,
      timestamp: DateTime.parse(json['timestamp']),
      meta: json['meta'] != null 
          ? PaginationMeta.fromJson(json['meta']) 
          : null,
      error: json['error'] != null 
          ? ApiError.fromJson(json['error']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'data': data,
      'message': message,
      'statusCode': statusCode,
      'timestamp': timestamp.toIso8601String(),
      'meta': meta?.toJson(),
      'error': error?.toJson(),
    };
  }

  @override
  String toString() {
    return 'ApiResponse(success: $success, data: $data, message: $message, statusCode: $statusCode, timestamp: $timestamp, meta: $meta, error: $error)';
  }
}

class PaginationMeta {
  final int page;
  final int limit;
  final int total;
  final int totalPages;
  final bool hasNextPage;
  final bool hasPrevPage;

  const PaginationMeta({
    required this.page,
    required this.limit,
    required this.total,
    required this.totalPages,
    required this.hasNextPage,
    required this.hasPrevPage,
  });

  factory PaginationMeta.fromJson(Map<String, dynamic> json) {
    return PaginationMeta(
      page: json['page'] ?? 1,
      limit: json['limit'] ?? 10,
      total: json['total'] ?? 0,
      totalPages: json['totalPages'] ?? 0,
      hasNextPage: json['hasNextPage'] ?? false,
      hasPrevPage: json['hasPrevPage'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'page': page,
      'limit': limit,
      'total': total,
      'totalPages': totalPages,
      'hasNextPage': hasNextPage,
      'hasPrevPage': hasPrevPage,
    };
  }

  @override
  String toString() {
    return 'PaginationMeta(page: $page, limit: $limit, total: $total, totalPages: $totalPages, hasNextPage: $hasNextPage, hasPrevPage: $hasPrevPage)';
  }
}

class ApiError {
  final String message;
  final int statusCode;
  final String code;
  final Map<String, dynamic>? details;

  const ApiError({
    required this.message,
    required this.statusCode,
    required this.code,
    this.details,
  });

  factory ApiError.fromJson(Map<String, dynamic> json) {
    return ApiError(
      message: json['message'] ?? 'Error desconocido',
      statusCode: json['statusCode'] ?? 500,
      code: json['code'] ?? 'UNKNOWN_ERROR',
      details: json['details'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'statusCode': statusCode,
      'code': code,
      'details': details,
    };
  }

  @override
  String toString() {
    return 'ApiError(message: $message, statusCode: $statusCode, code: $code, details: $details)';
  }
}
