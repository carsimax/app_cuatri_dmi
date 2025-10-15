import { Request, Response, NextFunction } from 'express';

export const logger = (req: Request, res: Response, next: NextFunction): void => {
  const start = Date.now();
  const timestamp = new Date().toISOString();
  
  // Log de la petición entrante
  console.log(`📥 ${req.method} ${req.url} - ${timestamp}`);
  
  // Interceptar el método end para loggear la respuesta
  const originalEnd = res.end;
  res.end = function(chunk?: any, encoding?: any, cb?: any) {
    const duration = Date.now() - start;
    const statusColor = res.statusCode >= 400 ? '🔴' : res.statusCode >= 300 ? '🟡' : '🟢';
    
    console.log(`📤 ${statusColor} ${req.method} ${req.url} - ${res.statusCode} - ${duration}ms`);
    
    // Llamar al método end original
    return originalEnd.call(this, chunk, encoding, cb);
  };
  
  next();
};
