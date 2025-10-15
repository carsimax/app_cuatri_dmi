import express from 'express';
import cors from 'cors';
import helmet from 'helmet';
import { config } from './config/env';
import { database } from './config/database';
import { logger } from './middlewares/logger';
import { errorHandler } from './middlewares/errorHandler';

// Importar rutas
import usuarioRoutes from './routes/usuarioRoutes';
import productoRoutes from './routes/productoRoutes';

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
app.use(logger);

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
      productos: '/api/productos',
    },
  });
});

// Rutas de la API
app.use('/api/usuarios', usuarioRoutes);
app.use('/api/productos', productoRoutes);

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
      console.log(`🚀 Servidor ejecutándose en puerto ${config.port}`);
      console.log(`📊 Entorno: ${config.nodeEnv}`);
      console.log(`🌐 URL: http://localhost:${config.port}`);
      console.log(`💾 Base de datos: ${config.databaseUrl}`);
    });
  } catch (error) {
    console.error('❌ Error al iniciar el servidor:', error);
    process.exit(1);
  }
};

// Manejo de cierre graceful
process.on('SIGTERM', async () => {
  console.log('🛑 SIGTERM recibido, cerrando servidor...');
  await database.disconnect();
  process.exit(0);
});

process.on('SIGINT', async () => {
  console.log('🛑 SIGINT recibido, cerrando servidor...');
  await database.disconnect();
  process.exit(0);
});

// Iniciar servidor
startServer();
