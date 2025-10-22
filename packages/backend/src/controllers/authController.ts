import { Request, Response } from 'express';
import { prisma } from '../config/database';
import { asyncHandler, createError } from '../middlewares/errorHandler';
import { createSuccessResponse } from '../models/ApiResponse';
import { RegisterDto, LoginDto, AuthResponse, UserWithoutPassword, ValidateSessionResponse } from '../models/Auth';
import { excludePassword } from '../models/Usuario';
import { generateToken } from '../utils/jwt';
import { hashPassword, comparePassword } from '../utils/password';
import { generateVerificationToken } from '../utils/jwt';
import { firebaseAuth } from '../config/firebase';

/**
 * Registro de nuevo usuario
 */
export const register = asyncHandler(async (req: Request, res: Response) => {
  const { email, password, nombre, apellido }: RegisterDto = req.body;

  // Verificar si el email ya existe
  const existingUsuario = await prisma.usuario.findUnique({
    where: { email },
  });

  if (existingUsuario) {
    throw createError('El email ya está en uso', 409, 'EMAIL_ALREADY_EXISTS');
  }

  // Hash de la contraseña
  const hashedPassword = await hashPassword(password);

  // Generar token de verificación
  const verificationToken = generateVerificationToken();

  // Crear usuario
  const usuario = await prisma.usuario.create({
    data: {
      email,
      password: hashedPassword,
      nombre,
      apellido,
      emailVerified: false,
      verificationToken,
    },
  });

  // Generar JWT
  const token = generateToken({
    id: usuario.id,
    email: usuario.email,
  });

  // Preparar respuesta sin password
  const userResponse: UserWithoutPassword = excludePassword(usuario);

  const response: AuthResponse = {
    user: userResponse,
    token,
  };

  res.status(201).json(createSuccessResponse(response, 'Usuario registrado exitosamente', 201));
});

/**
 * Login de usuario
 */
export const login = asyncHandler(async (req: Request, res: Response) => {
  const { email, password }: LoginDto = req.body;

  // Buscar usuario por email
  const usuario = await prisma.usuario.findUnique({
    where: { email },
  });

  if (!usuario) {
    throw createError('Credenciales inválidas', 401, 'INVALID_CREDENTIALS');
  }

  // Verificar si el usuario está activo
  if (!usuario.activo) {
    throw createError('Usuario desactivado', 403, 'USER_DISABLED');
  }

  // Comparar contraseñas
  const isPasswordValid = await comparePassword(password, usuario.password!);

  if (!isPasswordValid) {
    throw createError('Credenciales inválidas', 401, 'INVALID_CREDENTIALS');
  }

  // Generar JWT
  const token = generateToken({
    id: usuario.id,
    email: usuario.email,
  });

  // Preparar respuesta sin password
  const userResponse: UserWithoutPassword = excludePassword(usuario);

  const response: AuthResponse = {
    user: userResponse,
    token,
  };

  res.json(createSuccessResponse(response, 'Login exitoso'));
});

/**
 * Obtener perfil del usuario autenticado
 */
export const getProfile = asyncHandler(async (req: Request, res: Response) => {
  // El usuario ya está disponible en req.user gracias al middleware authenticate
  if (!req.user) {
    throw createError('Usuario no autenticado', 401, 'USER_NOT_AUTHENTICATED');
  }

  res.json(createSuccessResponse(req.user, 'Perfil obtenido exitosamente'));
});

/**
 * Validar sesión activa
 */
export const validateSession = asyncHandler(async (req: Request, res: Response) => {
  // El usuario ya está disponible en req.user gracias al middleware authenticate
  if (!req.user) {
    throw createError('Usuario no autenticado', 401, 'USER_NOT_AUTHENTICATED');
  }

  const response: ValidateSessionResponse = {
    valid: true,
    user: req.user,
  };

  res.json(createSuccessResponse(response, 'Sesión válida'));
});

/**
 * Actualizar perfil del usuario autenticado
 */
export const updateProfile = asyncHandler(async (req: Request, res: Response) => {
  if (!req.user) {
    throw createError('Usuario no autenticado', 401, 'USER_NOT_AUTHENTICATED');
  }

  const { nombre, apellido, email } = req.body;
  const updateData: any = {};

  // Solo actualizar campos que se proporcionen
  if (nombre !== undefined) updateData.nombre = nombre;
  if (apellido !== undefined) updateData.apellido = apellido;
  if (email !== undefined) updateData.email = email;

  // Si se está actualizando el email, verificar que no esté en uso por otro usuario
  if (email && email !== req.user.email) {
    const emailInUse = await prisma.usuario.findUnique({
      where: { email },
    });

    if (emailInUse) {
      throw createError('El email ya está en uso por otro usuario', 409, 'EMAIL_ALREADY_EXISTS');
    }

    // Si cambia el email, marcar como no verificado y generar nuevo token
    updateData.emailVerified = false;
    updateData.verificationToken = generateVerificationToken();
  }

  // Actualizar usuario
  const usuarioActualizado = await prisma.usuario.update({
    where: { id: req.user.id },
    data: updateData,
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

  res.json(createSuccessResponse(usuarioActualizado, 'Perfil actualizado exitosamente'));
});

/**
 * Cambiar contraseña del usuario autenticado
 */
export const changePassword = asyncHandler(async (req: Request, res: Response) => {
  if (!req.user) {
    throw createError('Usuario no autenticado', 401, 'USER_NOT_AUTHENTICATED');
  }

  const { currentPassword, newPassword } = req.body;

  // Obtener usuario completo con password
  const usuario = await prisma.usuario.findUnique({
    where: { id: req.user.id },
  });

  if (!usuario) {
    throw createError('Usuario no encontrado', 404, 'USER_NOT_FOUND');
  }

  // Verificar contraseña actual
  const isCurrentPasswordValid = await comparePassword(currentPassword, usuario.password!);

  if (!isCurrentPasswordValid) {
    throw createError('Contraseña actual incorrecta', 401, 'INVALID_CURRENT_PASSWORD');
  }

  // Hash de la nueva contraseña
  const hashedNewPassword = await hashPassword(newPassword);

  // Actualizar contraseña
  await prisma.usuario.update({
    where: { id: req.user.id },
    data: { password: hashedNewPassword },
  });

  res.json(createSuccessResponse(null, 'Contraseña cambiada exitosamente'));
});

/**
 * Verificar email del usuario
 */
export const verifyEmail = asyncHandler(async (req: Request, res: Response) => {
  const { token } = req.body;

  // Buscar usuario por token de verificación
  const usuario = await prisma.usuario.findUnique({
    where: { verificationToken: token },
  });

  if (!usuario) {
    throw createError('Token de verificación inválido', 400, 'INVALID_VERIFICATION_TOKEN');
  }

  // Verificar email
  await prisma.usuario.update({
    where: { id: usuario.id },
    data: {
      emailVerified: true,
      verificationToken: null, // Limpiar token después de verificar
    },
  });

  res.json(createSuccessResponse(null, 'Email verificado exitosamente'));
});

export const firebaseLogin = asyncHandler(async (req: Request, res: Response) => {
  const { idToken } = req.body; // Token de Firebase del frontend

  // Verificar el token de Firebase
  const decodedToken = await firebaseAuth.verifyIdToken(idToken);
  const { uid, email, name, picture, firebase } = decodedToken;
  
  if (!email) {
    throw createError('Email no disponible en el token de Firebase', 400, 'EMAIL_NOT_AVAILABLE');
  }

  // Determinar el proveedor de autenticación
  const provider = firebase.sign_in_provider || 'local'; // "password", "google.com", etc.

  // Buscar usuario en la BD por firebaseUid o email
  let usuario = await prisma.usuario.findFirst({
    where: {
      OR: [
        { firebaseUid: uid },
        { email: email },
      ],
    },
  });

  if (usuario) {
    // Usuario existente: actualizar datos de Firebase si es necesario
    if (!usuario.firebaseUid) {
      // Migración: vincular cuenta existente con Firebase
      usuario = await prisma.usuario.update({
        where: { id: usuario.id },
        data: {
          firebaseUid: uid,
          authProvider: provider,
          emailVerified: decodedToken.email_verified || false,
          photoURL: picture || usuario.photoURL,
        },
      });
    }
  } else {
    // Usuario nuevo: crear en la BD
    const [nombre, apellido] = (name || email.split('@')[0]).split(' ');
    usuario = await prisma.usuario.create({
      data: {
        email,
        firebaseUid: uid,
        nombre: nombre || email.split('@')[0],
        apellido: apellido || '',
        authProvider: provider,
        emailVerified: decodedToken.email_verified || false,
        photoURL: picture,
        password: null, // No hay password para usuarios de Google
      },
    });
  }

  // Generar JWT propio (opcional, puedes usar solo Firebase tokens)
  const token = generateToken({
    id: usuario.id,
    email: usuario.email,
  });

  const userResponse: UserWithoutPassword = excludePassword(usuario);

  const response: AuthResponse = {
    user: userResponse,
    token,
  };

  res.json(createSuccessResponse(response, 'Login exitoso'));
});

export const registerFcmToken = asyncHandler(async (req: Request, res: Response) => {
  if (!req.user) {
    throw createError('Usuario no autenticado', 401, 'USER_NOT_AUTHENTICATED');
  }

  const { fcmToken } = req.body;

  if (!fcmToken) {
    throw createError('Token FCM requerido', 400, 'FCM_TOKEN_REQUIRED');
  }

  // Obtener tokens existentes
  const usuario = await prisma.usuario.findUnique({
    where: { id: req.user.id },
    select: { fcmTokens: true },
  });

  let tokens: string[] = [];
  if (usuario?.fcmTokens) {
    try {
      tokens = JSON.parse(usuario.fcmTokens);
    } catch (e) {
      tokens = [];
    }
  }

  // Agregar nuevo token si no existe
  if (!tokens.includes(fcmToken)) {
    tokens.push(fcmToken);
  }

  // Actualizar en la BD
  await prisma.usuario.update({
    where: { id: req.user.id },
    data: { fcmTokens: JSON.stringify(tokens) },
  });

  res.json(createSuccessResponse(null, 'Token FCM registrado exitosamente'));
});
