# BFF para Flutter con Dio

Backend For Frontend (BFF) optimizado para Flutter con Dio, desarrollado con Express.js, TypeScript y SQLite usando Prisma como ORM.

## 🚀 Características

- **BFF optimizado** para Flutter con Dio
- **Express.js** con TypeScript
- **SQLite** como base de datos
- **Prisma** como ORM
- **Validación** robusta con express-validator
- **Paginación** automática en todos los endpoints
- **Upload de archivos** con Multer
- **Respuestas estandarizadas** compatibles con Dio
- **Logging** estructurado con Pino
- **Manejo de errores** centralizado y mapeado
- **CORS** configurado para Flutter (emuladores y dispositivos)
- **Helmet** para seguridad

## 📁 Estructura del Proyecto

```
packages/backend/
├── src/
│   ├── config/
│   │   ├── database.ts      # Configuración de Prisma
│   │   ├── env.ts          # Variables de entorno
│   │   └── multer.ts       # Configuración de uploads
│   ├── controllers/
│   │   └── usuarioController.ts
│   ├── middlewares/
│   │   ├── errorHandler.ts  # Manejo de errores mejorado
│   │   ├── logger.ts        # Sistema de logging con Pino
│   │   ├── validator.ts     # Middleware de validación
│   │   └── upload.ts        # Middleware de uploads
│   ├── models/
│   │   ├── Usuario.ts       # Tipos de Usuario
│   │   └── ApiResponse.ts   # Tipos de respuesta para Dio
│   ├── routes/
│   │   └── usuarioRoutes.ts
│   ├── validators/
│   │   └── usuarioValidator.ts # Validadores express-validator
│   ├── utils/
│   │   └── pagination.ts    # Utilidades de paginación
│   └── index.ts             # Punto de entrada
├── prisma/
│   ├── migrations/          # Migraciones de base de datos
│   └── schema.prisma        # Esquema de Prisma
├── uploads/                 # Directorio de archivos subidos
├── .env                     # Variables de entorno
├── package.json
├── tsconfig.json
└── README.md
```

## 🛠️ Instalación

1. **Navegar al directorio del backend:**
   ```bash
   cd packages/backend
   ```

2. **Instalar dependencias:**
   ```bash
   npm install
   ```

3. **Configurar variables de entorno:**
   ```bash
   cp .env.example .env
   # Editar .env con tus configuraciones
   ```

4. **Configurar la base de datos:**
   ```bash
   npm run prisma:migrate
   npm run prisma:generate
   ```

## 🚀 Uso

### Desarrollo
```bash
npm run dev
```
El servidor se ejecutará en `http://localhost:3000` con hot reload habilitado.

### Producción
```bash
npm run build
npm start
```

## 📊 Scripts Disponibles

- `npm run dev` - Desarrollo con hot reload
- `npm run build` - Compilar TypeScript
- `npm start` - Ejecutar versión compilada
- `npm run prisma:generate` - Generar cliente de Prisma
- `npm run prisma:migrate` - Ejecutar migraciones
- `npm run prisma:studio` - Abrir Prisma Studio
- `npm run prisma:reset` - Resetear base de datos

## 🌐 API Endpoints

### Health Check
- `GET /health` - Estado del servidor
- `GET /` - Información de la API

### Usuarios
- `GET /api/usuarios` - Obtener todos los usuarios (con paginación y filtros)
- `GET /api/usuarios/:id` - Obtener un usuario por ID
- `POST /api/usuarios` - Crear un nuevo usuario
- `PUT /api/usuarios/:id` - Actualizar un usuario
- `PATCH /api/usuarios/:id/toggle-activo` - Activar/desactivar usuario
- `DELETE /api/usuarios/:id` - Eliminar un usuario
- `GET /api/usuarios/search?q=termino` - Búsqueda avanzada
- `GET /api/usuarios/stats` - Estadísticas de usuarios

## 📱 Uso con Flutter/Dio

### Configuración básica de Dio

```dart
final dio = Dio(BaseOptions(
  baseUrl: 'http://10.0.2.2:3000/api', // Emulador Android
  // baseUrl: 'http://localhost:3000/api', // iOS Simulator
  connectTimeout: Duration(seconds: 5),
  receiveTimeout: Duration(seconds: 3),
  headers: {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  },
));
```

### Ejemplo de consumo

```dart
// Obtener usuarios con paginación
final response = await dio.get('/usuarios', queryParameters: {
  'page': 1,
  'limit': 10,
  'sortBy': 'createdAt',
  'order': 'desc',
  'search': 'juan',
  'activo': 'true',
});

// Respuesta paginada
final data = response.data['data'] as List;
final meta = response.data['meta'];
print('Total: ${meta['total']}');
print('Página: ${meta['page']} de ${meta['totalPages']}');
```

### Estructura de respuestas para Dio

#### Respuesta exitosa
```json
{
  "success": true,
  "data": { ... },
  "message": "Operación exitosa",
  "statusCode": 200,
  "timestamp": "2024-01-15T10:30:00.000Z"
}
```

#### Respuesta paginada
```json
{
  "success": true,
  "data": [...],
  "meta": {
    "page": 1,
    "limit": 10,
    "total": 50,
    "totalPages": 5,
    "hasNextPage": true,
    "hasPrevPage": false
  },
  "message": "Se encontraron 10 usuarios",
  "statusCode": 200,
  "timestamp": "2024-01-15T10:30:00.000Z"
}
```

#### Respuesta de error
```json
{
  "success": false,
  "error": {
    "message": "Descripción del error",
    "statusCode": 400,
    "code": "VALIDATION_ERROR",
    "details": [...]
  },
  "timestamp": "2024-01-15T10:30:00.000Z"
}
```

## 📄 Paginación y Filtros

### Parámetros de query disponibles

- `page` - Número de página (default: 1)
- `limit` - Elementos por página (default: 10, máximo: 100)
- `sortBy` - Campo de ordenamiento (id, email, nombre, apellido, createdAt, updatedAt)
- `order` - Orden (asc, desc)
- `search` - Búsqueda en nombre, apellido y email
- `activo` - Filtrar por estado activo (true/false)

### Ejemplo de uso

```bash
GET /api/usuarios?page=2&limit=20&sortBy=nombre&order=asc&search=juan&activo=true
```

## 📎 Upload de archivos

### Configuración

- **Tipos permitidos**: JPEG, JPG, PNG, WEBP, GIF
- **Tamaño máximo**: 5MB por archivo
- **Máximo archivos**: 5 por request
- **Directorio**: `uploads/`

### Ejemplo con Dio

```dart
final formData = FormData.fromMap({
  'file': await MultipartFile.fromFile(
    filePath,
    filename: 'avatar.jpg',
  ),
});

final response = await dio.post('/usuarios/upload', data: formData);
```

## ✅ Validaciones

### Usuario (crear)
- `email`: Email válido, único, 5-100 caracteres
- `nombre`: 2-50 caracteres, solo letras y espacios
- `apellido`: 2-50 caracteres, solo letras y espacios
- `activo`: Boolean opcional

### Códigos de error

- `VALIDATION_ERROR` - Error de validación (400)
- `EMAIL_ALREADY_EXISTS` - Email duplicado (409)
- `USER_NOT_FOUND` - Usuario no encontrado (404)
- `INVALID_ID` - ID inválido (400)
- `UNIQUE_CONSTRAINT_VIOLATION` - Violación de unicidad (409)
- `RECORD_NOT_FOUND` - Registro no encontrado (404)

## 🌐 CORS para Flutter

El backend está configurado para aceptar requests desde:

- **Localhost**: `http://localhost:3000`, `http://localhost:8080`, `http://localhost:8081`
- **Emulador Android**: `http://10.0.2.2:3000`, `http://10.0.2.2:8080`, `http://10.0.2.2:8081`
- **127.0.0.1**: `http://127.0.0.1:3000`, etc.

### Headers permitidos
- `Content-Type`, `Accept`, `Authorization`
- `X-API-Key`, `X-Request-ID`
- `Cache-Control`, `Pragma`

### Headers expuestos
- `X-Total-Count`, `X-Page`, `X-Limit`, `X-Total-Pages`

## 📝 Ejemplos de Uso

### Crear un Usuario
```bash
curl -X POST http://localhost:3000/api/usuarios \
  -H "Content-Type: application/json" \
  -d '{
    "email": "usuario@ejemplo.com",
    "nombre": "Juan",
    "apellido": "Pérez"
  }'
```

### Obtener usuarios con paginación
```bash
curl "http://localhost:3000/api/usuarios?page=1&limit=5&search=juan&activo=true"
```

### Buscar usuarios
```bash
curl "http://localhost:3000/api/usuarios/search?q=juan&page=1&limit=10"
```

### Obtener estadísticas
```bash
curl "http://localhost:3000/api/usuarios/stats"
```

## 🗄️ Base de Datos

### Modelo de Usuario

```typescript
{
  id: number
  email: string (único)
  nombre: string
  apellido: string
  activo: boolean
  createdAt: Date
  updatedAt: Date
}
```

### Cambiar de SQLite a otro motor

Para cambiar a PostgreSQL, MySQL, etc., modifica el archivo `prisma/schema.prisma`:

```prisma
datasource db {
  provider = "postgresql"  // o "mysql", "mongodb", etc.
  url      = env("DATABASE_URL")
}
```

Luego actualiza la `DATABASE_URL` en tu archivo `.env`:

```env
DATABASE_URL="postgresql://usuario:password@localhost:5432/mi_db"
```

### Prisma Studio
```bash
npm run prisma:studio
```
Abre una interfaz web para gestionar tu base de datos.

## 🔧 Configuración

### Variables de Entorno (.env)
```env
PORT=3000
NODE_ENV=development
DATABASE_URL="file:./dev.db"
CORS_ORIGIN=http://localhost:3000
JWT_SECRET=your-secret-key-here
JWT_EXPIRES_IN=7d
```

## 📊 Logging

El sistema usa Pino para logging estructurado:

- **Desarrollo**: Logs detallados con colores
- **Producción**: Logs optimizados
- **Request/Response**: Body sanitizado en desarrollo
- **IDs únicos**: Para tracing de requests
- **Errores**: Stack traces en desarrollo

## 🛡️ Características de Seguridad

- **Helmet** - Headers de seguridad HTTP
- **CORS** - Control de acceso cross-origin
- **Validación de datos** - Validación robusta con express-validator
- **Manejo de errores** - No exposición de información sensible
- **Logging** - Registro de todas las operaciones
- **Sanitización** - Campos sensibles ocultos en logs

## 📚 Tecnologías Utilizadas

- [Express.js](https://expressjs.com/) - Framework web
- [TypeScript](https://www.typescriptlang.org/) - Superset de JavaScript
- [Prisma](https://www.prisma.io/) - ORM moderno
- [SQLite](https://www.sqlite.org/) - Base de datos embebida
- [Helmet](https://helmetjs.github.io/) - Seguridad HTTP
- [CORS](https://github.com/expressjs/cors) - Cross-Origin Resource Sharing
- [Multer](https://github.com/expressjs/multer) - Manejo de uploads
- [Pino](https://github.com/pinojs/pino) - Logging rápido
- [express-validator](https://github.com/express-validator/express-validator) - Validación

## 🔨 Desarrollo

### Agregar nuevos endpoints

1. Definir el modelo en `prisma/schema.prisma`
2. Ejecutar migración: `npm run prisma:migrate`
3. Crear tipos en `src/models/`
4. Crear validadores en `src/validators/`
5. Crear controlador en `src/controllers/`
6. Crear rutas en `src/routes/`
7. Registrar rutas en `src/index.ts`

### Agregar nuevos tipos de respuesta

Usar los helpers en `src/models/ApiResponse.ts`:

```typescript
import { createSuccessResponse, createPaginatedResponse, createErrorResponse } from '../models/ApiResponse';

// Respuesta simple
const response = createSuccessResponse(data, 'Mensaje');

// Respuesta paginada
const response = createPaginatedResponse(data, meta, 'Mensaje');

// Respuesta de error
const response = createErrorResponse('Error', 400, 'ERROR_CODE');
```

## 🤝 Contribuir

1. Fork el proyecto
2. Crea una rama para tu feature (`git checkout -b feature/AmazingFeature`)
3. Commit tus cambios (`git commit -m 'Add some AmazingFeature'`)
4. Push a la rama (`git push origin feature/AmazingFeature`)
5. Abre un Pull Request

## 📄 Licencia

Este proyecto está bajo la Licencia MIT. Ver el archivo `LICENSE` para más detalles.