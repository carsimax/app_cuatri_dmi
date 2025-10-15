import { Router } from 'express';
import { 
  register, 
  login, 
  getProfile, 
  validateSession,
  updateProfile,
  changePassword,
  verifyEmail
} from '../controllers/authController';
import { authenticate } from '../middlewares/auth';
import { validate } from '../middlewares/validator';
import { 
  registerValidator, 
  loginValidator,
  updateProfileValidator,
  changePasswordValidator,
  verifyEmailValidator
} from '../validators/authValidator';

const router = Router();

/**
 * @route   POST /api/auth/register
 * @desc    Registrar nuevo usuario
 * @access  Public
 */
router.post('/register', validate(registerValidator), register);

/**
 * @route   POST /api/auth/login
 * @desc    Autenticar usuario
 * @access  Public
 */
router.post('/login', validate(loginValidator), login);

/**
 * @route   GET /api/auth/profile
 * @desc    Obtener perfil del usuario autenticado
 * @access  Private
 */
router.get('/profile', authenticate, getProfile);

/**
 * @route   GET /api/auth/validate
 * @desc    Validar sesión activa
 * @access  Private
 */
router.get('/validate', authenticate, validateSession);

/**
 * @route   PUT /api/auth/profile
 * @desc    Actualizar perfil del usuario autenticado
 * @access  Private
 */
router.put('/profile', authenticate, validate(updateProfileValidator), updateProfile);

/**
 * @route   PUT /api/auth/change-password
 * @desc    Cambiar contraseña del usuario autenticado
 * @access  Private
 */
router.put('/change-password', authenticate, validate(changePasswordValidator), changePassword);

/**
 * @route   POST /api/auth/verify-email
 * @desc    Verificar email del usuario
 * @access  Public
 */
router.post('/verify-email', validate(verifyEmailValidator), verifyEmail);

export default router;
