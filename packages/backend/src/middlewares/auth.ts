import { Request, Response, NextFunction } from 'express';
import { prisma } from '../config/database';
import { asyncHandler, createError } from './errorHandler';
import { verifyToken, extractTokenFromHeader, JwtPayload } from '../utils/jwt';
import { UsuarioSafe } from '../models/Usuario';

/**
 * Extiende la interfaz Request para incluir el usuario autenticado
 */
declare global {
  namespace Express {
    interface Request {
      user?: UsuarioSafe;
    }
  }
}

/**
 * Middleware de autenticación JWT
 * Valida el token JWT y agrega el usuario a req.user
 */
export const authenticate = asyncHandler(async (req: Request, res: Response, next: NextFunction) => {
  try {
    // Extraer token del header Authorization
    const authHeader = req.headers.authorization;
    const token = extractTokenFromHeader(authHeader);

    // Verificar y decodificar el token
    const payload: JwtPayload = verifyToken(token);

    // Buscar el usuario en la base de datos
    const usuario = await prisma.usuario.findUnique({
      where: { id: payload.id },
      select: {
        id: true,
        email: true,
        nombre: true,
        apellido: true,
        activo: true,
        emailVerified: true,
        createdAt: true,
        updatedAt: true,
      },
    });

    if (!usuario) {
      throw createError('Usuario no encontrado', 404, 'USER_NOT_FOUND');
    }

    if (!usuario.activo) {
      throw createError('Usuario desactivado', 403, 'USER_DISABLED');
    }

    // Agregar usuario a la request
    req.user = usuario as UsuarioSafe;

    next();
  } catch (error) {
    if (error instanceof Error) {
      if (error.message.includes('Token expirado')) {
        throw createError('Token expirado', 401, 'TOKEN_EXPIRED');
      } else if (error.message.includes('Token inválido')) {
        throw createError('Token inválido', 401, 'INVALID_TOKEN');
      } else if (error.message.includes('Token de autorización requerido')) {
        throw createError('Token de autorización requerido', 401, 'AUTH_TOKEN_REQUIRED');
      } else if (error.message.includes('Formato de autorización inválido')) {
        throw createError('Formato de autorización inválido. Use: Bearer <token>', 401, 'INVALID_AUTH_FORMAT');
      }
    }
    
    throw createError('Error de autenticación', 401, 'AUTH_ERROR');
  }
});

/**
 * Middleware opcional de autenticación
 * No falla si no hay token, pero agrega usuario si existe
 */
export const optionalAuthenticate = asyncHandler(async (req: Request, res: Response, next: NextFunction) => {
  try {
    const authHeader = req.headers.authorization;
    
    if (!authHeader) {
      // No hay token, continuar sin usuario
      return next();
    }

    const token = extractTokenFromHeader(authHeader);
    const payload: JwtPayload = verifyToken(token);

    const usuario = await prisma.usuario.findUnique({
      where: { id: payload.id },
      select: {
        id: true,
        email: true,
        nombre: true,
        apellido: true,
        activo: true,
        emailVerified: true,
        createdAt: true,
        updatedAt: true,
      },
    });

    if (usuario && usuario.activo) {
      req.user = usuario as UsuarioSafe;
    }

    next();
  } catch (error) {
    // En caso de error, continuar sin usuario (no fallar)
    next();
  }
});

/**
 * Middleware para verificar que el usuario tenga email verificado
 */
export const requireEmailVerified = asyncHandler(async (req: Request, res: Response, next: NextFunction) => {
  if (!req.user) {
    throw createError('Usuario no autenticado', 401, 'USER_NOT_AUTHENTICATED');
  }

  if (!req.user.emailVerified) {
    throw createError('Email no verificado', 403, 'EMAIL_NOT_VERIFIED');
  }

  next();
});

/**
 * Middleware para verificar que el usuario sea el propietario del recurso
 */
export const requireOwnership = (userIdParam: string = 'id') => {
  return asyncHandler(async (req: Request, res: Response, next: NextFunction) => {
    if (!req.user) {
      throw createError('Usuario no autenticado', 401, 'USER_NOT_AUTHENTICATED');
    }

    const resourceUserId = parseInt(req.params[userIdParam]);
    
    if (isNaN(resourceUserId)) {
      throw createError('ID de usuario inválido', 400, 'INVALID_USER_ID');
    }

    if (req.user.id !== resourceUserId) {
      throw createError('No tienes permisos para acceder a este recurso', 403, 'INSUFFICIENT_PERMISSIONS');
    }

    next();
  });
};
