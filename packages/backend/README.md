# Backend Express con TypeScript y SQLite

Un backend robusto construido con Express.js, TypeScript y SQLite usando Prisma ORM.

## 🚀 Características

- **Express.js** - Framework web rápido y minimalista
- **TypeScript** - Tipado estático para JavaScript
- **SQLite** - Base de datos ligera para desarrollo
- **Prisma ORM** - ORM moderno y type-safe
- **Middleware de seguridad** - Helmet, CORS
- **Manejo de errores** - Sistema robusto de manejo de errores
- **Logging** - Sistema de logging personalizado
- **Hot reload** - Desarrollo con recarga automática

## 📁 Estructura del Proyecto

```
packages/backend/
├── src/
│   ├── config/
│   │   ├── database.ts      # Configuración de Prisma
│   │   └── env.ts          # Variables de entorno
│   ├── controllers/
│   │   ├── usuarioController.ts
│   │   └── productoController.ts
│   ├── middlewares/
│   │   ├── errorHandler.ts  # Manejo de errores
│   │   └── logger.ts        # Sistema de logging
│   ├── models/
│   │   ├── Usuario.ts       # Tipos de Usuario
│   │   └── Producto.ts      # Tipos de Producto
│   ├── routes/
│   │   ├── usuarioRoutes.ts
│   │   └── productoRoutes.ts
│   └── index.ts             # Punto de entrada
├── prisma/
│   ├── migrations/          # Migraciones de base de datos
│   └── schema.prisma        # Esquema de Prisma
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
   cp env.example .env
   ```

4. **Configurar la base de datos:**
   ```bash
   npm run prisma:generate
   npm run prisma:migrate
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
- `GET /api/usuarios` - Obtener todos los usuarios
- `GET /api/usuarios/:id` - Obtener usuario por ID
- `POST /api/usuarios` - Crear nuevo usuario
- `PUT /api/usuarios/:id` - Actualizar usuario
- `DELETE /api/usuarios/:id` - Eliminar usuario

### Productos
- `GET /api/productos` - Obtener todos los productos
- `GET /api/productos/:id` - Obtener producto por ID
- `POST /api/productos` - Crear nuevo producto
- `PUT /api/productos/:id` - Actualizar producto
- `DELETE /api/productos/:id` - Eliminar producto

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

### Crear un Producto
```bash
curl -X POST http://localhost:3000/api/productos \
  -H "Content-Type: application/json" \
  -d '{
    "nombre": "Laptop",
    "descripcion": "Laptop para desarrollo",
    "precio": 1500.00,
    "stock": 10
  }'
```

## 🗄️ Base de Datos

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

## 🛡️ Características de Seguridad

- **Helmet** - Headers de seguridad HTTP
- **CORS** - Control de acceso cross-origin
- **Validación de datos** - Validación de entrada
- **Manejo de errores** - No exposición de información sensible
- **Logging** - Registro de todas las operaciones

## 📚 Tecnologías Utilizadas

- [Express.js](https://expressjs.com/) - Framework web
- [TypeScript](https://www.typescriptlang.org/) - Superset de JavaScript
- [Prisma](https://www.prisma.io/) - ORM moderno
- [SQLite](https://www.sqlite.org/) - Base de datos embebida
- [Helmet](https://helmetjs.github.io/) - Seguridad HTTP
- [CORS](https://github.com/expressjs/cors) - Cross-Origin Resource Sharing

## 🤝 Contribuir

1. Fork el proyecto
2. Crea una rama para tu feature (`git checkout -b feature/AmazingFeature`)
3. Commit tus cambios (`git commit -m 'Add some AmazingFeature'`)
4. Push a la rama (`git push origin feature/AmazingFeature`)
5. Abre un Pull Request

## 📄 Licencia

Este proyecto está bajo la Licencia MIT. Ver el archivo `LICENSE` para más detalles.
