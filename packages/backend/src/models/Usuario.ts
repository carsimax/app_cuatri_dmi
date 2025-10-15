export interface CreateUsuarioDto {
  email: string;
  password: string;
  nombre: string;
  apellido: string;
  activo?: boolean;
  emailVerified?: boolean;
  verificationToken?: string;
}

export interface UpdateUsuarioDto {
  email?: string;
  password?: string;
  nombre?: string;
  apellido?: string;
  activo?: boolean;
  emailVerified?: boolean;
  verificationToken?: string;
}

export interface UsuarioResponse {
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
 * Usuario completo con todos los campos (incluyendo password)
 */
export interface UsuarioComplete {
  id: number;
  email: string;
  password: string;
  nombre: string;
  apellido: string;
  activo: boolean;
  emailVerified: boolean;
  verificationToken: string | null;
  createdAt: Date;
  updatedAt: Date;
}

/**
 * Usuario sin información sensible (sin password)
 */
export interface UsuarioSafe {
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
 * Función helper para excluir campos sensibles del usuario
 * @param usuario - Usuario completo de la base de datos
 * @returns Usuario sin campos sensibles
 */
export const excludePassword = (usuario: UsuarioComplete): UsuarioSafe => {
  const { password, ...usuarioSafe } = usuario;
  return usuarioSafe;
};
