import { Request, Response } from 'express';
import { prisma } from '../config/database';
import { asyncHandler, createError } from '../middlewares/errorHandler';
import { CreateUsuarioDto, UpdateUsuarioDto } from '../models/Usuario';
import { createSuccessResponse, createPaginatedResponse } from '../models/ApiResponse';
import { 
  parsePaginationQuery, 
  calculatePaginationMeta, 
  createPrismaPaginationOptions,
  PaginationQuery 
} from '../utils/pagination';

// Obtener todos los usuarios con paginación y filtros
export const getUsuarios = asyncHandler(async (req: Request, res: Response) => {
  const query = req.query as PaginationQuery;
  const options = parsePaginationQuery(query);
  
  // Configurar opciones de Prisma
  const prismaOptions = createPrismaPaginationOptions(
    options, 
    query.search, 
    query.activo
  );

  // Obtener usuarios y total
  const [usuarios, total] = await Promise.all([
    prisma.usuario.findMany(prismaOptions),
    prisma.usuario.count({ where: prismaOptions.where })
  ]);

  // Calcular metadatos de paginación
  const meta = calculatePaginationMeta(options.page, options.limit, total);

  // Crear respuesta paginada
  const response = createPaginatedResponse(
    usuarios,
    meta,
    `Se encontraron ${usuarios.length} usuarios`
  );

  res.json(response);
});

// Obtener un usuario por ID
export const getUsuario = asyncHandler(async (req: Request, res: Response) => {
  const { id } = req.params;
  const usuarioId = parseInt(id);

  if (isNaN(usuarioId)) {
    throw createError('ID de usuario inválido', 400, 'INVALID_ID');
  }

  const usuario = await prisma.usuario.findUnique({
    where: { id: usuarioId },
  });

  if (!usuario) {
    throw createError('Usuario no encontrado', 404, 'USER_NOT_FOUND');
  }

  const response = createSuccessResponse(usuario, 'Usuario encontrado');
  res.json(response);
});

// Crear un nuevo usuario
export const createUsuario = asyncHandler(async (req: Request, res: Response) => {
  const { email, password, nombre, apellido, activo = true }: CreateUsuarioDto = req.body;

  // Verificar si el email ya existe
  const existingUsuario = await prisma.usuario.findUnique({
    where: { email },
  });

  if (existingUsuario) {
    throw createError('El email ya está en uso', 409, 'EMAIL_ALREADY_EXISTS');
  }

  const usuario = await prisma.usuario.create({
    data: {
      email,
      password,
      nombre,
      apellido,
      activo,
    },
  });

  const response = createSuccessResponse(usuario, 'Usuario creado exitosamente', 201);
  res.status(201).json(response);
});

// Actualizar un usuario
export const updateUsuario = asyncHandler(async (req: Request, res: Response) => {
  const { id } = req.params;
  const usuarioId = parseInt(id);
  const updateData: UpdateUsuarioDto = req.body;

  if (isNaN(usuarioId)) {
    throw createError('ID de usuario inválido', 400, 'INVALID_ID');
  }

  // Verificar si el usuario existe
  const existingUsuario = await prisma.usuario.findUnique({
    where: { id: usuarioId },
  });

  if (!existingUsuario) {
    throw createError('Usuario no encontrado', 404, 'USER_NOT_FOUND');
  }

  // Si se está actualizando el email, verificar que no esté en uso por otro usuario
  if (updateData.email && updateData.email !== existingUsuario.email) {
    const emailInUse = await prisma.usuario.findUnique({
      where: { email: updateData.email },
    });

    if (emailInUse) {
      throw createError('El email ya está en uso por otro usuario', 409, 'EMAIL_ALREADY_EXISTS');
    }
  }

  const usuario = await prisma.usuario.update({
    where: { id: usuarioId },
    data: updateData,
  });

  const response = createSuccessResponse(usuario, 'Usuario actualizado exitosamente');
  res.json(response);
});

// Eliminar un usuario
export const deleteUsuario = asyncHandler(async (req: Request, res: Response) => {
  const { id } = req.params;
  const usuarioId = parseInt(id);

  if (isNaN(usuarioId)) {
    throw createError('ID de usuario inválido', 400, 'INVALID_ID');
  }

  // Verificar si el usuario existe
  const existingUsuario = await prisma.usuario.findUnique({
    where: { id: usuarioId },
  });

  if (!existingUsuario) {
    throw createError('Usuario no encontrado', 404, 'USER_NOT_FOUND');
  }

  await prisma.usuario.delete({
    where: { id: usuarioId },
  });

  const response = createSuccessResponse(null, 'Usuario eliminado exitosamente');
  res.json(response);
});

// Activar/desactivar usuario (toggle)
export const toggleActivoUsuario = asyncHandler(async (req: Request, res: Response) => {
  const { id } = req.params;
  const usuarioId = parseInt(id);

  if (isNaN(usuarioId)) {
    throw createError('ID de usuario inválido', 400, 'INVALID_ID');
  }

  // Verificar si el usuario existe
  const existingUsuario = await prisma.usuario.findUnique({
    where: { id: usuarioId },
  });

  if (!existingUsuario) {
    throw createError('Usuario no encontrado', 404, 'USER_NOT_FOUND');
  }

  // Toggle del estado activo
  const usuario = await prisma.usuario.update({
    where: { id: usuarioId },
    data: { activo: !existingUsuario.activo },
  });

  const message = usuario.activo 
    ? 'Usuario activado exitosamente' 
    : 'Usuario desactivado exitosamente';

  const response = createSuccessResponse(usuario, message);
  res.json(response);
});

// Búsqueda avanzada de usuarios
export const searchUsuarios = asyncHandler(async (req: Request, res: Response) => {
  const { q: searchTerm } = req.query;
  const query = req.query as PaginationQuery;
  const options = parsePaginationQuery(query);

  if (!searchTerm || typeof searchTerm !== 'string') {
    throw createError('Término de búsqueda requerido', 400, 'SEARCH_TERM_REQUIRED');
  }

  // Configurar opciones de búsqueda
  const searchOptions = {
    skip: (options.page - 1) * options.limit,
    take: options.limit,
    where: {
      OR: [
        { nombre: { contains: searchTerm } },
        { apellido: { contains: searchTerm } },
        { email: { contains: searchTerm } },
      ],
    },
    orderBy: createOrderBy(options.sortBy || 'createdAt', options.order || 'desc'),
  };

  // Obtener usuarios y total
  const [usuarios, total] = await Promise.all([
    prisma.usuario.findMany(searchOptions),
    prisma.usuario.count({ where: searchOptions.where })
  ]);

  // Calcular metadatos de paginación
  const meta = calculatePaginationMeta(options.page, options.limit, total);

  // Crear respuesta paginada
  const response = createPaginatedResponse(
    usuarios,
    meta,
    `Se encontraron ${usuarios.length} usuarios para "${searchTerm}"`
  );

  res.json(response);
});

// Obtener estadísticas de usuarios
export const getUsuariosStats = asyncHandler(async (req: Request, res: Response) => {
  const [total, activos, inactivos] = await Promise.all([
    prisma.usuario.count(),
    prisma.usuario.count({ where: { activo: true } }),
    prisma.usuario.count({ where: { activo: false } })
  ]);

  const stats = {
    total,
    activos,
    inactivos,
    porcentajeActivos: total > 0 ? Math.round((activos / total) * 100) : 0,
    porcentajeInactivos: total > 0 ? Math.round((inactivos / total) * 100) : 0,
  };

  const response = createSuccessResponse(stats, 'Estadísticas de usuarios');
  res.json(response);
});

// Helper para crear ordenamiento (reutilizado)
const createOrderBy = (sortBy: string, order: 'asc' | 'desc') => {
  const validSortFields = ['id', 'email', 'nombre', 'apellido', 'createdAt', 'updatedAt'];
  
  if (!validSortFields.includes(sortBy)) {
    return { createdAt: 'desc' as const };
  }
  
  return { [sortBy]: order };
};
