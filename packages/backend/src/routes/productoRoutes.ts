import { Router } from 'express';
import {
  getProductos,
  getProducto,
  createProducto,
  updateProducto,
  deleteProducto,
} from '../controllers/productoController';

const router = Router();

// GET /api/productos - Obtener todos los productos
router.get('/', getProductos);

// GET /api/productos/:id - Obtener un producto por ID
router.get('/:id', getProducto);

// POST /api/productos - Crear un nuevo producto
router.post('/', createProducto);

// PUT /api/productos/:id - Actualizar un producto
router.put('/:id', updateProducto);

// DELETE /api/productos/:id - Eliminar un producto
router.delete('/:id', deleteProducto);

export default router;
