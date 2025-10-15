import { Request, Response } from 'express';
import { prisma } from '../config/database';
import { asyncHandler, createError } from '../middlewares/errorHandler';
import { CreateUsuarioDto, UpdateUsuarioDto } from '../models/Usuario';

// Obtener todos los usuarios
export const getUsuarios = asyncHandler(async (req: Request, res: Response) => {
  const usuarios = await prisma.usuario.findMany({
    orderBy: { createdAt: 'desc' },
  });

  res.json({
    success: true,
    data: usuarios,
    count: usuarios.length,
  });
});

// Obtener un usuario por ID
export const getUsuario = asyncHandler(async (req: Request, res: Response) => {
  const { id } = req.params;
  const usuarioId = parseInt(id);

  if (isNaN(usuarioId)) {
    throw createError('ID de usuario inválido', 400);
  }

  const usuario = await prisma.usuario.findUnique({
    where: { id: usuarioId },
  });

  if (!usuario) {
    throw createError('Usuario no encontrado', 404);
  }

  res.json({
    success: true,
    data: usuario,
  });
});

// Crear un nuevo usuario
export const createUsuario = asyncHandler(async (req: Request, res: Response) => {
  const { email, nombre, apellido, activo = true }: CreateUsuarioDto = req.body;

  // Validaciones básicas
  if (!email || !nombre || !apellido) {
    throw createError('Email, nombre y apellido son requeridos', 400);
  }

  // Verificar si el email ya existe
  const existingUsuario = await prisma.usuario.findUnique({
    where: { email },
  });

  if (existingUsuario) {
    throw createError('El email ya está en uso', 409);
  }

  const usuario = await prisma.usuario.create({
    data: {
      email,
      nombre,
      apellido,
      activo,
    },
  });

  res.status(201).json({
    success: true,
    data: usuario,
    message: 'Usuario creado exitosamente',
  });
});

// Actualizar un usuario
export const updateUsuario = asyncHandler(async (req: Request, res: Response) => {
  const { id } = req.params;
  const usuarioId = parseInt(id);
  const updateData: UpdateUsuarioDto = req.body;

  if (isNaN(usuarioId)) {
    throw createError('ID de usuario inválido', 400);
  }

  // Verificar si el usuario existe
  const existingUsuario = await prisma.usuario.findUnique({
    where: { id: usuarioId },
  });

  if (!existingUsuario) {
    throw createError('Usuario no encontrado', 404);
  }

  // Si se está actualizando el email, verificar que no esté en uso por otro usuario
  if (updateData.email && updateData.email !== existingUsuario.email) {
    const emailInUse = await prisma.usuario.findUnique({
      where: { email: updateData.email },
    });

    if (emailInUse) {
      throw createError('El email ya está en uso por otro usuario', 409);
    }
  }

  const usuario = await prisma.usuario.update({
    where: { id: usuarioId },
    data: updateData,
  });

  res.json({
    success: true,
    data: usuario,
    message: 'Usuario actualizado exitosamente',
  });
});

// Eliminar un usuario
export const deleteUsuario = asyncHandler(async (req: Request, res: Response) => {
  const { id } = req.params;
  const usuarioId = parseInt(id);

  if (isNaN(usuarioId)) {
    throw createError('ID de usuario inválido', 400);
  }

  // Verificar si el usuario existe
  const existingUsuario = await prisma.usuario.findUnique({
    where: { id: usuarioId },
  });

  if (!existingUsuario) {
    throw createError('Usuario no encontrado', 404);
  }

  await prisma.usuario.delete({
    where: { id: usuarioId },
  });

  res.json({
    success: true,
    message: 'Usuario eliminado exitosamente',
  });
});
