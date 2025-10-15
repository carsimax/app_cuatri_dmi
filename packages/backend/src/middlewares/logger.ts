import pino from 'pino';
import pinoHttp from 'pino-http';
import { config } from '../config/env';
import { sanitizeForLogging } from './validator';

// Generar ID único para cada request
const generateRequestId = () => {
  return Math.random().toString(36).substring(2, 15) + Math.random().toString(36).substring(2, 15);
};

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

// Middleware HTTP de Pino mejorado para debugging
export const httpLogger = pinoHttp({
  logger,
  genReqId: () => generateRequestId(),
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
    const props: any = {
      method: req.method,
      url: req.url,
      statusCode: res.statusCode,
      responseTime: (res as any).responseTime,
      userAgent: req.headers['user-agent'],
      ip: (req as any).ip,
    };

    // En desarrollo, incluir request body (sanitizado)
    if (config.nodeEnv === 'development' && (req as any).body) {
      props.requestBody = sanitizeForLogging((req as any).body);
    }

    // En desarrollo, incluir response body para debugging
    if (config.nodeEnv === 'development' && (res as any).body) {
      props.responseBody = (res as any).body;
    }

    return props;
  },
  // Interceptor para capturar response body
  customAttributeKeys: {
    req: 'request',
    res: 'response',
    err: 'error',
    responseTime: 'duration'
  },
  // Log request body en desarrollo
  serializers: {
    req: (req: any) => {
      const sanitizedReq: any = {
        method: req.method,
        url: req.url,
        headers: req.headers,
        remoteAddress: req.remoteAddress,
        remotePort: req.remotePort
      };

      if (config.nodeEnv === 'development' && req.body) {
        sanitizedReq.body = sanitizeForLogging(req.body);
      }

      return sanitizedReq;
    },
    res: (res: any) => {
      return {
        statusCode: res.statusCode,
        headers: res.headers
      };
    }
  }
});

export { logger };
export default httpLogger;