import express from 'express';
import cors from 'cors';
import helmet from 'helmet';
import { config } from './config/env';
import { database } from './config/database';
import { httpLogger, logger } from './middlewares/logger';
import { errorHandler } from './middlewares/errorHandler';

// Importar rutas
import usuarioRoutes from './routes/usuarioRoutes';

const app = express();

// Middlewares de seguridad
app.use(helmet());
app.use(cors({
  origin: config.corsOrigin,
  credentials: true,
}));

// Middlewares de parsing
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true }));

// Middleware de logging
app.use(httpLogger);

// Rutas
app.get('/health', (req, res) => {
  res.json({
    success: true,
    message: 'Servidor funcionando correctamente',
    timestamp: new Date().toISOString(),
    environment: config.nodeEnv,
  });
});

app.get('/', (req, res) => {
  res.json({
    success: true,
    message: 'API Backend Express con TypeScript y SQLite',
    version: '1.0.0',
    endpoints: {
      health: '/health',
      usuarios: '/api/usuarios',
    },
  });
});

// Rutas de la API
app.use('/api/usuarios', usuarioRoutes);

// Middleware de manejo de errores (debe ir al final)
app.use(errorHandler);

// Middleware para rutas no encontradas
app.use('*', (req, res) => {
  res.status(404).json({
    success: false,
    error: {
      message: `Ruta ${req.originalUrl} no encontrada`,
      statusCode: 404,
    },
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
      }, '🚀 Servidor iniciado correctamente');
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

// Iniciar servidor
startServer();
