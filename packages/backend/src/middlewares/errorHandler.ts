import { Request, Response, NextFunction } from 'express';
import { Prisma } from '@prisma/client';
import { createErrorResponse } from '../models/ApiResponse';
import { logger } from './logger';

export interface AppError extends Error {
  statusCode?: number;
  isOperational?: boolean;
  code?: string;
  details?: any;
}

export const createError = (
  message: string, 
  statusCode: number = 500, 
  code?: string,
  details?: any
): AppError => {
  const error: AppError = new Error(message);
  error.statusCode = statusCode;
  error.isOperational = true;
  error.code = code;
  error.details = details;
  return error;
};

// Mapear errores de Prisma a errores HTTP apropiados
const mapPrismaError = (error: any): { statusCode: number; message: string; code: string } => {
  if (error instanceof Prisma.PrismaClientKnownRequestError) {
    switch (error.code) {
      case 'P2002':
        return {
          statusCode: 409,
          message: 'Conflicto de unicidad: el registro ya existe',
          code: 'UNIQUE_CONSTRAINT_VIOLATION'
        };
      case 'P2025':
        return {
          statusCode: 404,
          message: 'Registro no encontrado',
          code: 'RECORD_NOT_FOUND'
        };
      case 'P2003':
        return {
          statusCode: 400,
          message: 'Violación de clave foránea',
          code: 'FOREIGN_KEY_CONSTRAINT'
        };
      default:
        return {
          statusCode: 400,
          message: 'Error en la base de datos',
          code: 'DATABASE_ERROR'
        };
    }
  }

  if (error instanceof Prisma.PrismaClientValidationError) {
    return {
      statusCode: 400,
      message: 'Datos de entrada inválidos',
      code: 'VALIDATION_ERROR'
    };
  }

  return {
    statusCode: 500,
    message: 'Error interno del servidor',
    code: 'INTERNAL_ERROR'
  };
};

export const errorHandler = (
  error: AppError,
  req: Request,
  res: Response,
  next: NextFunction
): void => {
  let statusCode = error.statusCode || 500;
  let message = error.message;
  let code = error.code;
  let details = error.details;

  // Mapear errores de Prisma
  if (error.name?.includes('Prisma')) {
    const prismaError = mapPrismaError(error);
    statusCode = prismaError.statusCode;
    message = prismaError.message;
    code = prismaError.code;
  }

  // Log del error
  logger.error({
    error: {
      name: error.name,
      message: error.message,
      stack: error.stack,
      statusCode,
      code
    },
    request: {
      method: req.method,
      url: req.url,
      userAgent: req.headers['user-agent'],
      ip: req.ip
    }
  }, 'Error en request');

  // Crear respuesta de error
  const errorResponse = createErrorResponse(
    statusCode === 500 ? 'Error interno del servidor' : message,
    statusCode,
    code,
    process.env.NODE_ENV === 'development' ? {
      ...details,
      stack: error.stack,
      originalError: error.message
    } : details
  );

  res.status(statusCode).json(errorResponse);
};

export const asyncHandler = (fn: Function) => {
  return (req: Request, res: Response, next: NextFunction) => {
    Promise.resolve(fn(req, res, next)).catch(next);
  };
};
