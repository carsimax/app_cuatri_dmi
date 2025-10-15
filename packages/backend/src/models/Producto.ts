export interface CreateProductoDto {
  nombre: string;
  descripcion?: string;
  precio: number;
  stock?: number;
  activo?: boolean;
}

export interface UpdateProductoDto {
  nombre?: string;
  descripcion?: string;
  precio?: number;
  stock?: number;
  activo?: boolean;
}

export interface ProductoResponse {
  id: number;
  nombre: string;
  descripcion: string | null;
  precio: number;
  stock: number;
  activo: boolean;
  createdAt: Date;
  updatedAt: Date;
}
