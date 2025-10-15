export interface CreateUsuarioDto {
  email: string;
  nombre: string;
  apellido: string;
  activo?: boolean;
}

export interface UpdateUsuarioDto {
  email?: string;
  nombre?: string;
  apellido?: string;
  activo?: boolean;
}

export interface UsuarioResponse {
  id: number;
  email: string;
  nombre: string;
  apellido: string;
  activo: boolean;
  createdAt: Date;
  updatedAt: Date;
}
