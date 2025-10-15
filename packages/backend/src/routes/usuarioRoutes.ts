import { Router } from 'express';
import {
  getUsuarios,
  getUsuario,
  createUsuario,
  updateUsuario,
  deleteUsuario,
  toggleActivoUsuario,
  searchUsuarios,
  getUsuariosStats,
} from '../controllers/usuarioController';
import { validate } from '../middlewares/validator';
import {
  createUsuarioValidation,
  updateUsuarioValidation,
  getUsuarioValidation,
  deleteUsuarioValidation,
  getUsuariosValidation,
  toggleActivoValidation,
  searchUsuariosValidation,
} from '../validators/usuarioValidator';

const router = Router();

// GET /api/usuarios/stats - Obtener estadísticas de usuarios
router.get('/stats', getUsuariosStats);

// GET /api/usuarios/search - Búsqueda avanzada de usuarios
router.get('/search', validate(searchUsuariosValidation), searchUsuarios);

// GET /api/usuarios - Obtener todos los usuarios con paginación y filtros
router.get('/', validate(getUsuariosValidation), getUsuarios);

// GET /api/usuarios/:id - Obtener un usuario por ID
router.get('/:id', validate(getUsuarioValidation), getUsuario);

// POST /api/usuarios - Crear un nuevo usuario
router.post('/', validate(createUsuarioValidation), createUsuario);

// PUT /api/usuarios/:id - Actualizar un usuario
router.put('/:id', validate(updateUsuarioValidation), updateUsuario);

// PATCH /api/usuarios/:id/toggle-activo - Activar/desactivar usuario
router.patch('/:id/toggle-activo', validate(toggleActivoValidation), toggleActivoUsuario);

// DELETE /api/usuarios/:id - Eliminar un usuario
router.delete('/:id', validate(deleteUsuarioValidation), deleteUsuario);

export default router;
