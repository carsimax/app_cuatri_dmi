/**
 * DTO para registro de usuario
 */
export interface RegisterDto {
  email: string;
  password: string;
  nombre: string;
  apellido: string;
}

/**
 * DTO para login de usuario
 */
export interface LoginDto {
  email: string;
  password: string;
}

/**
 * Respuesta de autenticación (login/register)
 */
export interface AuthResponse {
  user: UserWithoutPassword;
  token: string;
}

/**
 * Usuario sin información sensible (sin password)
 */
export interface UserWithoutPassword {
  id: number;
  email: string;
  nombre: string;
  apellido: string;
  activo: boolean;
  emailVerified: boolean;
  createdAt: Date;
  updatedAt: Date;
}

/**
 * Respuesta para validación de sesión
 */
export interface ValidateSessionResponse {
  valid: boolean;
  user: UserWithoutPassword;
}

/**
 * DTO para actualizar perfil de usuario
 */
export interface UpdateProfileDto {
  nombre?: string;
  apellido?: string;
  email?: string;
}

/**
 * DTO para cambio de contraseña
 */
export interface ChangePasswordDto {
  currentPassword: string;
  newPassword: string;
}

/**
 * DTO para solicitud de reset de contraseña
 */
export interface ForgotPasswordDto {
  email: string;
}

/**
 * DTO para reset de contraseña
 */
export interface ResetPasswordDto {
  token: string;
  newPassword: string;
}

/**
 * DTO para verificación de email
 */
export interface VerifyEmailDto {
  token: string;
}
