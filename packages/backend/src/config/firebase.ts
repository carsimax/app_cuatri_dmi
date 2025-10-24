import admin from 'firebase-admin';
import { config } from './env';

// Inicializar Firebase Admin SDK
const privateKey = config.firebasePrivateKey?.replace(/\\n/g, '\n');

if (!config.firebaseProjectId || !privateKey || !config.firebaseClientEmail) {
  throw new Error('Firebase credentials are not configured in environment variables');
}

admin.initializeApp({
  credential: admin.credential.cert({
    projectId: config.firebaseProjectId,
    privateKey: privateKey,
    clientEmail: config.firebaseClientEmail,
  }),
});

export const firebaseAuth = admin.auth();
export const firebaseMessaging = admin.messaging();

export default admin;