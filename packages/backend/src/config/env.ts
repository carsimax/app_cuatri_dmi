import dotenv from 'dotenv';

// Cargar variables de entorno
dotenv.config();

export const config = {
  port: process.env.PORT || 3000,
  nodeEnv: process.env.NODE_ENV || 'development',
  databaseUrl: process.env.DATABASE_URL || 'file:./dev.db',
  corsOrigin: process.env.CORS_ORIGIN || 'http://localhost:3000',
  jwtSecret: process.env.JWT_SECRET || 'your-secret-key-here',
  jwtExpiresIn: process.env.JWT_EXPIRES_IN || '7d',
  // Agregar después de las variables existentes:
  firebaseProjectId: process.env.FIREBASE_PROJECT_ID,
  firebasePrivateKey: process.env.FIREBASE_PRIVATE_KEY,
  firebaseClientEmail: process.env.FIREBASE_CLIENT_EMAIL,
  fcmServerKey: process.env.FCM_SERVER_KEY,
} as const;
