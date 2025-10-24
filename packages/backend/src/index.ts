import express from 'express';
import cors from 'cors';
import helmet from 'helmet';
import { config } from './config/env';
import { database } from './config/database';
import { httpLogger, logger } from './middlewares/logger';
import { errorHandler } from './middlewares/errorHandler';
import { setupStaticFiles } from './middlewares/upload';
import { createSuccessResponse } from './models/ApiResponse';

// Importar rutas
import usuarioRoutes from './routes/usuarioRoutes';
import authRoutes from './routes/authRoutes';
import notificationRoutes from './routes/notificationRoutes';

const app = express();

// Middlewares de seguridad
app.use(helmet({
  crossOriginResourcePolicy: { policy: "cross-origin" }
}));

// Configuración CORS optimizada para Flutter
app.use(cors({
  origin: [
    'http://localhost:3000',
    'http://localhost:8080',
    'http://localhost:8081',
    'http://10.0.2.2:3000', // Emulador Android
    'http://10.0.2.2:8080',
    'http://10.0.2.2:8081',
    'http://127.0.0.1:3000',
    'http://127.0.0.1:8080',
    'http://127.0.0.1:8081',
    ...(config.nodeEnv === 'development' ? ['*'] : [])
  ],
  credentials: true,
  methods: ['GET', 'POST', 'PUT', 'PATCH', 'DELETE', 'OPTIONS'],
  allowedHeaders: [
    'Origin',
    'X-Requested-With',
    'Content-Type',
    'Accept',
    'Authorization',
    'Cache-Control',
    'Pragma',
    'X-API-Key',
    'X-Request-ID'
  ],
  exposedHeaders: [
    'X-Total-Count',
    'X-Page',
    'X-Limit',
    'X-Total-Pages'
  ]
}));

// Middleware para headers personalizados de Dio
app.use((req, res, next) => {
  // Agregar headers útiles para Flutter/Dio
  res.header('X-API-Version', '1.0.0');
  res.header('X-Request-ID', req.headers['x-request-id'] || 'unknown');
  res.header('Cache-Control', 'no-cache, no-store, must-revalidate');
  res.header('Pragma', 'no-cache');
  res.header('Expires', '0');
  next();
});

// Middlewares de parsing
app.use(express.json({ 
  limit: '10mb',
  strict: true,
  type: 'application/json'
}));
app.use(express.urlencoded({ 
  extended: true,
  limit: '10mb'
}));

app.use('/api/notifications', notificationRoutes);

// Configurar archivos estáticos para uploads
setupStaticFiles(app);

// Middleware de logging
app.use(httpLogger);

// Rutas de health check y documentación
app.get('/health', (req, res) => {
  const response = createSuccessResponse({
    status: 'healthy',
    environment: config.nodeEnv,
    database: 'connected',
    uptime: process.uptime(),
    memory: process.memoryUsage(),
  }, 'Servidor funcionando correctamente');
  
  res.json(response);
});

app.get('/', (req, res) => {
  const response = createSuccessResponse({
    name: 'BFF para Flutter con Dio',
    version: '1.0.0',
    description: 'Backend For Frontend optimizado para Flutter con Dio',
    environment: config.nodeEnv,
    endpoints: {
      health: '/health',
      usuarios: '/api/usuarios',
      auth: '/api/auth',
      documentacion: '/api/docs'
    },
    features: [
      'Paginación automática',
      'Validación con express-validator',
      'Upload de archivos con Multer',
      'Respuestas estandarizadas para Dio',
      'Logging mejorado con Pino',
      'Manejo de errores robusto'
    ]
  }, 'BFF API disponible');
  
  res.json(response);
});

// Rutas de la API
app.use('/api/usuarios', usuarioRoutes);
app.use('/api/auth', authRoutes);

// Middleware de manejo de errores (debe ir al final)
app.use(errorHandler);

// Middleware para rutas no encontradas
app.use('*', (req, res) => {
  res.status(404).json({
    success: false,
    error: {
      message: `Ruta ${req.originalUrl} no encontrada`,
      statusCode: 404,
      code: 'ROUTE_NOT_FOUND'
    },
    timestamp: new Date().toISOString(),
  });
});

// Función para iniciar el servidor
const startServer = async (): Promise<void> => {
  try {
    // Conectar a la base de datos
    await database.connect();

    // Iniciar servidor
    app.listen(config.port, () => {
      logger.info({
        port: config.port,
        environment: config.nodeEnv,
        url: `http://localhost:${config.port}`,
        database: config.databaseUrl,
        cors: {
          origins: [
            'http://localhost:3000',
            'http://localhost:8080',
            'http://localhost:8081',
            'http://10.0.2.2:3000',
            'http://10.0.2.2:8080',
            'http://10.0.2.2:8081'
          ],
          credentials: true
        },
        features: [
          'Paginación',
          'Validaciones',
          'Upload de archivos',
          'Respuestas estandarizadas',
          'Logging mejorado'
        ]
      }, '🚀 BFF para Flutter iniciado correctamente');
    });
  } catch (error) {
    logger.error({ error }, '❌ Error al iniciar el servidor');
    process.exit(1);
  }
};

// Manejo de cierre graceful
process.on('SIGTERM', async () => {
  logger.info('🛑 SIGTERM recibido, cerrando servidor...');
  await database.disconnect();
  process.exit(0);
});

process.on('SIGINT', async () => {
  logger.info('🛑 SIGINT recibido, cerrando servidor...');
  await database.disconnect();
  process.exit(0);
});

// Manejo de errores no capturados
process.on('unhandledRejection', (reason, promise) => {
  logger.error({ reason, promise }, 'Unhandled Rejection at Promise');
});

process.on('uncaughtException', (error) => {
  logger.error({ error }, 'Uncaught Exception');
  process.exit(1);
});

// Iniciar servidor
startServer();
