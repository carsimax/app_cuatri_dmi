import { Request, Response, NextFunction } from 'express';
import { validationResult, ValidationChain } from 'express-validator';
import { createErrorResponse } from '../models/ApiResponse';

// Middleware para manejar errores de validación
export const handleValidationErrors = (
  req: Request,
  res: Response,
  next: NextFunction
): void => {
  const errors = validationResult(req);
  
  if (!errors.isEmpty()) {
    const formattedErrors = errors.array().map(error => ({
      field: error.type === 'field' ? error.path : undefined,
      message: error.msg,
      value: error.type === 'field' ? error.value : undefined,
    }));

    const response = createErrorResponse(
      'Datos de entrada inválidos',
      400,
      'VALIDATION_ERROR',
      formattedErrors
    );

    res.status(400).json(response);
    return;
  }

  next();
};

// Helper para ejecutar múltiples validadores
export const validate = (validations: ValidationChain[]) => {
  return [
    ...validations,
    handleValidationErrors,
  ];
};

// Sanitizar campos sensibles para logging
export const sanitizeForLogging = (obj: any): any => {
  if (!obj || typeof obj !== 'object') return obj;
  
  const sensitiveFields = ['password', 'token', 'secret', 'key'];
  const sanitized = { ...obj };
  
  Object.keys(sanitized).forEach(key => {
    if (sensitiveFields.some(field => key.toLowerCase().includes(field))) {
      sanitized[key] = '[REDACTED]';
    }
  });
  
  return sanitized;
};
