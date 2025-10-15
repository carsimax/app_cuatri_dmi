import { body } from 'express-validator';

/**
 * Validaciones para registro de usuario
 */
export const registerValidator = [
  body('email')
    .isEmail()
    .withMessage('Debe ser un email válido')
    .normalizeEmail()
    .withMessage('Email inválido'),

  body('password')
    .isLength({ min: 6 })
    .withMessage('La contraseña debe tener al menos 6 caracteres')
    .matches(/^(?=.*[a-zA-Z])(?=.*\d)/)
    .withMessage('La contraseña debe contener al menos una letra y un número'),

  body('nombre')
    .notEmpty()
    .withMessage('El nombre es requerido')
    .isLength({ min: 2, max: 50 })
    .withMessage('El nombre debe tener entre 2 y 50 caracteres')
    .matches(/^[a-zA-ZáéíóúÁÉÍÓÚñÑ\s]+$/)
    .withMessage('El nombre solo puede contener letras y espacios'),

  body('apellido')
    .notEmpty()
    .withMessage('El apellido es requerido')
    .isLength({ min: 2, max: 50 })
    .withMessage('El apellido debe tener entre 2 y 50 caracteres')
    .matches(/^[a-zA-ZáéíóúÁÉÍÓÚñÑ\s]+$/)
    .withMessage('El apellido solo puede contener letras y espacios'),
];

/**
 * Validaciones para login de usuario
 */
export const loginValidator = [
  body('email')
    .isEmail()
    .withMessage('Debe ser un email válido')
    .normalizeEmail()
    .withMessage('Email inválido'),

  body('password')
    .notEmpty()
    .withMessage('La contraseña es requerida')
    .isLength({ min: 1 })
    .withMessage('La contraseña no puede estar vacía'),
];

/**
 * Validaciones para actualización de perfil
 */
export const updateProfileValidator = [
  body('nombre')
    .optional()
    .isLength({ min: 2, max: 50 })
    .withMessage('El nombre debe tener entre 2 y 50 caracteres')
    .matches(/^[a-zA-ZáéíóúÁÉÍÓÚñÑ\s]+$/)
    .withMessage('El nombre solo puede contener letras y espacios'),

  body('apellido')
    .optional()
    .isLength({ min: 2, max: 50 })
    .withMessage('El apellido debe tener entre 2 y 50 caracteres')
    .matches(/^[a-zA-ZáéíóúÁÉÍÓÚñÑ\s]+$/)
    .withMessage('El apellido solo puede contener letras y espacios'),

  body('email')
    .optional()
    .isEmail()
    .withMessage('Debe ser un email válido')
    .normalizeEmail()
    .withMessage('Email inválido'),
];

/**
 * Validaciones para cambio de contraseña
 */
export const changePasswordValidator = [
  body('currentPassword')
    .notEmpty()
    .withMessage('La contraseña actual es requerida')
    .isLength({ min: 1 })
    .withMessage('La contraseña actual no puede estar vacía'),

  body('newPassword')
    .isLength({ min: 6 })
    .withMessage('La nueva contraseña debe tener al menos 6 caracteres')
    .matches(/^(?=.*[a-zA-Z])(?=.*\d)/)
    .withMessage('La nueva contraseña debe contener al menos una letra y un número'),
];

/**
 * Validaciones para solicitud de reset de contraseña
 */
export const forgotPasswordValidator = [
  body('email')
    .isEmail()
    .withMessage('Debe ser un email válido')
    .normalizeEmail()
    .withMessage('Email inválido'),
];

/**
 * Validaciones para reset de contraseña
 */
export const resetPasswordValidator = [
  body('token')
    .notEmpty()
    .withMessage('El token de reset es requerido')
    .isLength({ min: 64, max: 64 })
    .withMessage('Token de reset inválido'),

  body('newPassword')
    .isLength({ min: 6 })
    .withMessage('La nueva contraseña debe tener al menos 6 caracteres')
    .matches(/^(?=.*[a-zA-Z])(?=.*\d)/)
    .withMessage('La nueva contraseña debe contener al menos una letra y un número'),
];

/**
 * Validaciones para verificación de email
 */
export const verifyEmailValidator = [
  body('token')
    .notEmpty()
    .withMessage('El token de verificación es requerido')
    .isLength({ min: 64, max: 64 })
    .withMessage('Token de verificación inválido'),
];
