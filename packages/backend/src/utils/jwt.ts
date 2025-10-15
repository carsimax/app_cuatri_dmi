import jwt from 'jsonwebtoken';
import crypto from 'crypto';
import { config } from '../config/env';

export interface JwtPayload {
  id: number;
  email: string;
  iat?: number;
  exp?: number;
}

/**
 * Genera un JWT token con el payload especificado
 * @param payload - Datos del usuario a incluir en el token
 * @returns Token JWT firmado
 */
export const generateToken = (payload: Omit<JwtPayload, 'iat' | 'exp'>): string => {
  return jwt.sign(payload, config.jwtSecret, {
    expiresIn: config.jwtExpiresIn,
    issuer: 'app-cuatri',
    audience: 'app-cuatri-users'
  } as jwt.SignOptions);
};

/**
 * Verifica y decodifica un JWT token
 * @param token - Token JWT a verificar
 * @returns Payload decodificado del token
 * @throws Error si el token es inválido
 */
export const verifyToken = (token: string): JwtPayload => {
  try {
    const decoded = jwt.verify(token, config.jwtSecret, {
      issuer: 'app-cuatri',
      audience: 'app-cuatri-users'
    }) as JwtPayload;
    
    return decoded;
  } catch (error) {
    if (error instanceof jwt.TokenExpiredError) {
      throw new Error('Token expirado');
    } else if (error instanceof jwt.JsonWebTokenError) {
      throw new Error('Token inválido');
    } else {
      throw new Error('Error al verificar token');
    }
  }
};

/**
 * Genera un token aleatorio seguro para verificación de email
 * @returns Token de verificación de 32 bytes en hexadecimal
 */
export const generateVerificationToken = (): string => {
  return crypto.randomBytes(32).toString('hex');
};

/**
 * Extrae el token del header Authorization
 * @param authHeader - Header Authorization completo
 * @returns Token sin el prefijo "Bearer "
 * @throws Error si el formato es inválido
 */
export const extractTokenFromHeader = (authHeader: string | undefined): string => {
  if (!authHeader) {
    throw new Error('Token de autorización requerido');
  }

  const parts = authHeader.split(' ');
  if (parts.length !== 2 || parts[0] !== 'Bearer') {
    throw new Error('Formato de autorización inválido. Use: Bearer <token>');
  }

  return parts[1];
};
