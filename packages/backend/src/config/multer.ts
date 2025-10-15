import multer from 'multer';
import path from 'path';
import { Request } from 'express';

// Configuración de storage para archivos
const storage = multer.diskStorage({
  destination: (req: any, file: any, cb: any) => {
    cb(null, 'uploads/');
  },
  filename: (req: any, file: any, cb: any) => {
    // Generar nombre único: timestamp + número aleatorio + extensión
    const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1E9);
    const extension = path.extname(file.originalname);
    cb(null, file.fieldname + '-' + uniqueSuffix + extension);
  }
});

// Filtro para tipos de archivo permitidos
const fileFilter = (req: any, file: any, cb: any) => {
  // Tipos de imagen permitidos
  const allowedTypes = /jpeg|jpg|png|webp|gif/;
  const extname = allowedTypes.test(path.extname(file.originalname).toLowerCase());
  const mimetype = allowedTypes.test(file.mimetype);

  if (mimetype && extname) {
    return cb(null, true);
  } else {
    cb(new Error('Solo se permiten archivos de imagen (JPEG, JPG, PNG, WEBP, GIF)'));
  }
};

// Configuración de multer
export const upload = multer({
  storage: storage,
  limits: {
    fileSize: 5 * 1024 * 1024, // 5MB máximo
    files: 5, // Máximo 5 archivos por request
  },
  fileFilter: fileFilter,
});

// Middlewares específicos para diferentes casos de uso
export const uploadSingle = upload.single('file');
export const uploadMultiple = upload.array('files', 5);
export const uploadFields = upload.fields([
  { name: 'avatar', maxCount: 1 },
  { name: 'documents', maxCount: 5 }
]);

// Middleware personalizado para manejo de errores de multer
export const handleMulterError = (error: any, req: Request, res: any, next: any) => {
  if (error instanceof multer.MulterError) {
    switch (error.code) {
      case 'LIMIT_FILE_SIZE':
        return res.status(400).json({
          success: false,
          error: {
            message: 'El archivo es demasiado grande. Máximo 5MB',
            statusCode: 400,
            code: 'FILE_TOO_LARGE'
          },
          timestamp: new Date().toISOString()
        });
      case 'LIMIT_FILE_COUNT':
        return res.status(400).json({
          success: false,
          error: {
            message: 'Demasiados archivos. Máximo 5 archivos',
            statusCode: 400,
            code: 'TOO_MANY_FILES'
          },
          timestamp: new Date().toISOString()
        });
      case 'LIMIT_UNEXPECTED_FILE':
        return res.status(400).json({
          success: false,
          error: {
            message: 'Campo de archivo inesperado',
            statusCode: 400,
            code: 'UNEXPECTED_FIELD'
          },
          timestamp: new Date().toISOString()
        });
      default:
        return res.status(400).json({
          success: false,
          error: {
            message: 'Error al subir archivo',
            statusCode: 400,
            code: 'UPLOAD_ERROR'
          },
          timestamp: new Date().toISOString()
        });
    }
  } else if (error) {
    return res.status(400).json({
      success: false,
      error: {
        message: error.message,
        statusCode: 400,
        code: 'INVALID_FILE'
      },
      timestamp: new Date().toISOString()
    });
  }
  next();
};
