import pino from 'pino';
import pinoHttp from 'pino-http';
import { config } from '../config/env';

// Configurar logger de Pino
const logger = pino({
  level: config.nodeEnv === 'production' ? 'info' : 'debug',
  transport: config.nodeEnv !== 'production' ? {
    target: 'pino-pretty',
    options: {
      colorize: true,
      translateTime: 'SYS:standard',
      ignore: 'pid,hostname',
      singleLine: false,
      hideObject: false,
    },
  } : undefined,
  base: {
    env: config.nodeEnv,
  },
});

// Middleware HTTP de Pino
export const httpLogger = pinoHttp({
  logger,
  customLogLevel: function (req, res, err) {
    if (res.statusCode >= 400 && res.statusCode < 500) {
      return 'warn';
    } else if (res.statusCode >= 500 || err) {
      return 'error';
    }
    return 'info';
  },
  customSuccessMessage: function (req, res) {
    if (res.statusCode === 404) {
      return 'Ruta no encontrada';
    }
    return `${req.method} ${req.url} completado`;
  },
  customErrorMessage: function (req, res, err) {
    return `${req.method} ${req.url} error: ${err.message}`;
  },
  customProps: function (req, res) {
    return {
      method: req.method,
      url: req.url,
      statusCode: res.statusCode,
      responseTime: (res as any).responseTime,
      userAgent: req.headers['user-agent'],
    };
  },
});

export { logger };
export default httpLogger;