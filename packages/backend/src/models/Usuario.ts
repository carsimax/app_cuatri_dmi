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
export function excludePassword<T extends { password?: string | null }>(usuario: T): Omit<T, 'password'> {
    // Desestructuramos y eliminamos password incluso si es null/undefined
    // eslint-disable-next-line @typescript-eslint/no-unused-vars
    const { password, ...rest } = usuario as any;
    return rest as Omit<T, 'password'>;
};
