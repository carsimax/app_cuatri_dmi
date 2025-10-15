import { Request, Response } from 'express';
import { prisma } from '../config/database';
import { asyncHandler, createError } from '../middlewares/errorHandler';
import { CreateProductoDto, UpdateProductoDto } from '../models/Producto';

// Obtener todos los productos
export const getProductos = asyncHandler(async (req: Request, res: Response) => {
  const productos = await prisma.producto.findMany({
    orderBy: { createdAt: 'desc' },
  });

  res.json({
    success: true,
    data: productos,
    count: productos.length,
  });
});

// Obtener un producto por ID
export const getProducto = asyncHandler(async (req: Request, res: Response) => {
  const { id } = req.params;
  const productoId = parseInt(id);

  if (isNaN(productoId)) {
    throw createError('ID de producto inválido', 400);
  }

  const producto = await prisma.producto.findUnique({
    where: { id: productoId },
  });

  if (!producto) {
    throw createError('Producto no encontrado', 404);
  }

  res.json({
    success: true,
    data: producto,
  });
});

// Crear un nuevo producto
export const createProducto = asyncHandler(async (req: Request, res: Response) => {
  const { nombre, descripcion, precio, stock = 0, activo = true }: CreateProductoDto = req.body;

  // Validaciones básicas
  if (!nombre || precio === undefined || precio < 0) {
    throw createError('Nombre y precio válido son requeridos', 400);
  }

  if (stock < 0) {
    throw createError('El stock no puede ser negativo', 400);
  }

  const producto = await prisma.producto.create({
    data: {
      nombre,
      descripcion,
      precio,
      stock,
      activo,
    },
  });

  res.status(201).json({
    success: true,
    data: producto,
    message: 'Producto creado exitosamente',
  });
});

// Actualizar un producto
export const updateProducto = asyncHandler(async (req: Request, res: Response) => {
  const { id } = req.params;
  const productoId = parseInt(id);
  const updateData: UpdateProductoDto = req.body;

  if (isNaN(productoId)) {
    throw createError('ID de producto inválido', 400);
  }

  // Verificar si el producto existe
  const existingProducto = await prisma.producto.findUnique({
    where: { id: productoId },
  });

  if (!existingProducto) {
    throw createError('Producto no encontrado', 404);
  }

  // Validaciones
  if (updateData.precio !== undefined && updateData.precio < 0) {
    throw createError('El precio no puede ser negativo', 400);
  }

  if (updateData.stock !== undefined && updateData.stock < 0) {
    throw createError('El stock no puede ser negativo', 400);
  }

  const producto = await prisma.producto.update({
    where: { id: productoId },
    data: updateData,
  });

  res.json({
    success: true,
    data: producto,
    message: 'Producto actualizado exitosamente',
  });
});

// Eliminar un producto
export const deleteProducto = asyncHandler(async (req: Request, res: Response) => {
  const { id } = req.params;
  const productoId = parseInt(id);

  if (isNaN(productoId)) {
    throw createError('ID de producto inválido', 400);
  }

  // Verificar si el producto existe
  const existingProducto = await prisma.producto.findUnique({
    where: { id: productoId },
  });

  if (!existingProducto) {
    throw createError('Producto no encontrado', 404);
  }

  await prisma.producto.delete({
    where: { id: productoId },
  });

  res.json({
    success: true,
    message: 'Producto eliminado exitosamente',
  });
});
