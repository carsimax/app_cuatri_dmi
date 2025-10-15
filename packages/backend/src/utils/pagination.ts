// Utilidades para paginación compatible con Flutter Dio

export interface PaginationOptions {
  page: number;
  limit: number;
  sortBy?: string;
  order?: 'asc' | 'desc';
}

export interface PaginationMeta {
  page: number;
  limit: number;
  total: number;
  totalPages: number;
  hasNextPage: boolean;
  hasPrevPage: boolean;
}

export interface PaginationQuery {
  page?: string;
  limit?: string;
  sortBy?: string;
  order?: string;
  search?: string;
  activo?: string;
}

// Parsear parámetros de query a opciones de paginación
export const parsePaginationQuery = (query: PaginationQuery): PaginationOptions => {
  const page = parseInt(query.page || '1', 10);
  const limit = parseInt(query.limit || '10', 10);
  const sortBy = query.sortBy || 'createdAt';
  const order = (query.order as 'asc' | 'desc') || 'desc';

  return {
    page: Math.max(1, page),
    limit: Math.min(Math.max(1, limit), 100), // Máximo 100 elementos por página
    sortBy,
    order,
  };
};

// Calcular metadatos de paginación
export const calculatePaginationMeta = (
  page: number,
  limit: number,
  total: number
): PaginationMeta => {
  const totalPages = Math.ceil(total / limit);
  
  return {
    page,
    limit,
    total,
    totalPages,
    hasNextPage: page < totalPages,
    hasPrevPage: page > 1,
  };
};

// Crear opciones de ordenamiento para Prisma
export const createOrderBy = (sortBy: string, order: 'asc' | 'desc') => {
  const validSortFields = ['id', 'email', 'nombre', 'apellido', 'createdAt', 'updatedAt'];
  
  if (!validSortFields.includes(sortBy)) {
    return { createdAt: 'desc' as const };
  }
  
  return { [sortBy]: order };
};

// Crear filtros de búsqueda para Prisma
export const createSearchFilter = (search?: string, activo?: string) => {
  const filters: any = {};
  
  // Filtro de búsqueda en nombre, apellido y email
  if (search) {
    // Para SQLite no usamos mode: 'insensitive', solo contains
    filters.OR = [
      { nombre: { contains: search } },
      { apellido: { contains: search } },
      { email: { contains: search } },
    ];
  }
  
  // Filtro por estado activo
  if (activo !== undefined) {
    filters.activo = activo === 'true';
  }
  
  return filters;
};

// Crear opciones de Prisma para paginación
export const createPrismaPaginationOptions = (
  options: PaginationOptions,
  search?: string,
  activo?: string
) => {
  const skip = (options.page - 1) * options.limit;
  
  return {
    skip,
    take: options.limit,
    orderBy: createOrderBy(options.sortBy || 'createdAt', options.order || 'desc'),
    where: createSearchFilter(search, activo),
  };
};
