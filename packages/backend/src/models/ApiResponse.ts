// Tipos de respuesta API optimizados para Flutter con Dio

export interface ApiSuccessResponse<T = any> {
  success: true;
  data?: T;
  message?: string;
  statusCode: number;
  timestamp: string;
}

export interface ApiErrorResponse {
  success: false;
  error: {
    message: string;
    statusCode: number;
    code?: string;
    details?: any;
  };
  timestamp: string;
}

export interface PaginationMeta {
  page: number;
  limit: number;
  total: number;
  totalPages: number;
  hasNextPage: boolean;
  hasPrevPage: boolean;
}

export interface PaginatedResponse<T = any> {
  success: true;
  data: T[];
  meta: PaginationMeta;
  message?: string;
  statusCode: number;
  timestamp: string;
}

export type ApiResponse<T = any> = ApiSuccessResponse<T> | ApiErrorResponse;

// Helper para crear respuestas exitosas
export const createSuccessResponse = <T>(
  data?: T,
  message?: string,
  statusCode: number = 200
): ApiSuccessResponse<T> => ({
  success: true,
  data,
  message,
  statusCode,
  timestamp: new Date().toISOString(),
});

// Helper para crear respuestas de lista paginada
export const createPaginatedResponse = <T>(
  data: T[],
  meta: PaginationMeta,
  message?: string,
  statusCode: number = 200
): PaginatedResponse<T> => ({
  success: true,
  data,
  meta,
  message,
  statusCode,
  timestamp: new Date().toISOString(),
});

// Helper para crear respuestas de error
export const createErrorResponse = (
  message: string,
  statusCode: number = 500,
  code?: string,
  details?: any
): ApiErrorResponse => ({
  success: false,
  error: {
    message,
    statusCode,
    code,
    details,
  },
  timestamp: new Date().toISOString(),
});
