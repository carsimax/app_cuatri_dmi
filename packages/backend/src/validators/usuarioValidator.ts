import { body, param, query } from 'express-validator';

// Validaciones para crear usuario
export const createUsuarioValidation = [
  body('email')
    .isEmail()
    .withMessage('El email debe ser válido')
    .normalizeEmail()
    .isLength({ min: 5, max: 100 })
    .withMessage('El email debe tener entre 5 y 100 caracteres'),

  body('nombre')
    .trim()
    .isLength({ min: 2, max: 50 })
    .withMessage('El nombre debe tener entre 2 y 50 caracteres')
    .matches(/^[a-zA-ZáéíóúÁÉÍÓÚñÑ\s]+$/)
    .withMessage('El nombre solo puede contener letras y espacios'),

  body('apellido')
    .trim()
    .isLength({ min: 2, max: 50 })
    .withMessage('El apellido debe tener entre 2 y 50 caracteres')
    .matches(/^[a-zA-ZáéíóúÁÉÍÓÚñÑ\s]+$/)
    .withMessage('El apellido solo puede contener letras y espacios'),

  body('activo')
    .optional()
    .isBoolean()
    .withMessage('El campo activo debe ser un booleano'),
];

// Validaciones para actualizar usuario
export const updateUsuarioValidation = [
  param('id')
    .isInt({ min: 1 })
    .withMessage('El ID debe ser un número entero positivo'),

  body('email')
    .optional()
    .isEmail()
    .withMessage('El email debe ser válido')
    .normalizeEmail()
    .isLength({ min: 5, max: 100 })
    .withMessage('El email debe tener entre 5 y 100 caracteres'),

  body('nombre')
    .optional()
    .trim()
    .isLength({ min: 2, max: 50 })
    .withMessage('El nombre debe tener entre 2 y 50 caracteres')
    .matches(/^[a-zA-ZáéíóúÁÉÍÓÚñÑ\s]+$/)
    .withMessage('El nombre solo puede contener letras y espacios'),

  body('apellido')
    .optional()
    .trim()
    .isLength({ min: 2, max: 50 })
    .withMessage('El apellido debe tener entre 2 y 50 caracteres')
    .matches(/^[a-zA-ZáéíóúÁÉÍÓÚñÑ\s]+$/)
    .withMessage('El apellido solo puede contener letras y espacios'),

  body('activo')
    .optional()
    .isBoolean()
    .withMessage('El campo activo debe ser un booleano'),
];

// Validaciones para obtener usuario por ID
export const getUsuarioValidation = [
  param('id')
    .isInt({ min: 1 })
    .withMessage('El ID debe ser un número entero positivo'),
];

// Validaciones para eliminar usuario
export const deleteUsuarioValidation = [
  param('id')
    .isInt({ min: 1 })
    .withMessage('El ID debe ser un número entero positivo'),
];

// Validaciones para paginación y filtros
export const getUsuariosValidation = [
  query('page')
    .optional()
    .isInt({ min: 1 })
    .withMessage('La página debe ser un número entero mayor a 0'),

  query('limit')
    .optional()
    .isInt({ min: 1, max: 100 })
    .withMessage('El límite debe ser un número entre 1 y 100'),

  query('sortBy')
    .optional()
    .isIn(['id', 'email', 'nombre', 'apellido', 'createdAt', 'updatedAt'])
    .withMessage('Campo de ordenamiento inválido'),

  query('order')
    .optional()
    .isIn(['asc', 'desc'])
    .withMessage('El orden debe ser asc o desc'),

  query('search')
    .optional()
    .trim()
    .isLength({ min: 1, max: 100 })
    .withMessage('La búsqueda debe tener entre 1 y 100 caracteres'),

  query('activo')
    .optional()
    .isBoolean()
    .withMessage('El filtro activo debe ser un booleano'),
];

// Validaciones para toggle activo
export const toggleActivoValidation = [
  param('id')
    .isInt({ min: 1 })
    .withMessage('El ID debe ser un número entero positivo'),
];

// Validaciones para búsqueda avanzada
export const searchUsuariosValidation = [
  query('q')
    .notEmpty()
    .withMessage('El término de búsqueda es requerido')
    .trim()
    .isLength({ min: 1, max: 100 })
    .withMessage('El término de búsqueda debe tener entre 1 y 100 caracteres'),

  query('page')
    .optional()
    .isInt({ min: 1 })
    .withMessage('La página debe ser un número entero mayor a 0'),

  query('limit')
    .optional()
    .isInt({ min: 1, max: 100 })
    .withMessage('El límite debe ser un número entre 1 y 100'),
];
