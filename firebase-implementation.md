# Guía de Implementación de Firebase

## Descripción General

Este documento describe el proceso completo para integrar Firebase Authentication (Email/Password + Google Sign-In) y Firebase Cloud Messaging (notificaciones push) en la aplicación, incluyendo la migración de usuarios existentes del sistema JWT actual.

---

## Fase 1: Configuración en Firebase Console

### 1.1 Crear Proyecto en Firebase

1. Acceder a [Firebase Console](https://console.firebase.google.com/)
2. Hacer clic en "Agregar proyecto" o "Create a project"
3. Nombre del proyecto: `app-cuatri-dmi` (o el nombre que prefieras)
4. Desactivar Google Analytics (opcional, puedes activarlo después)
5. Hacer clic en "Crear proyecto"
6. Esperar a que se complete la creación (15-30 segundos)

### 1.2 Agregar Aplicación Android

1. En la página de inicio del proyecto, hacer clic en el ícono de Android
2. Registrar la app:

   - **Android package name**: `com.utez.frontend` (debe coincidir exactamente con `applicationId` en `android/app/build.gradle.kts`)
   - **App nickname**: `App Cuatri DMI Android` (opcional)
   - **Debug signing certificate SHA-1**: Dejar vacío por ahora (lo configuraremos después para Google Sign-In)

3. Hacer clic en "Registrar app"

### 1.3 Descargar google-services.json

1. Descargar el archivo `google-services.json`
2. **IMPORTANTE**: Guardar este archivo en la carpeta `packages/frontend/android/app/`
3. Verificar que el archivo esté en la ruta correcta: `packages/frontend/android/app/google-services.json`
4. Hacer clic en "Siguiente" y luego "Continuar a la consola"

### 1.4 Habilitar Firebase Authentication

1. En el menú lateral de Firebase Console, ir a **Build > Authentication**
2. Hacer clic en "Get started" o "Comenzar"
3. En la pestaña "Sign-in method", habilitar los siguientes proveedores:

**Email/Password:**

   - Hacer clic en "Email/Password"
   - Activar el switch "Enable"
   - Hacer clic en "Save"

**Google:**

   - Hacer clic en "Google"
   - Activar el switch "Enable"
   - Configurar:
     - **Project support email**: Seleccionar tu email
     - **Project public-facing name**: `App Cuatri DMI` (visible para usuarios)
   - Hacer clic en "Save"

### 1.5 Obtener SHA-1 para Google Sign-In

**En tu terminal (desde la raíz del proyecto):**

```bash
cd packages/frontend/android
./gradlew signingReport
```

Buscar en la salida la sección `Task :app:signingReport` > `Variant: debug` y copiar el valor de **SHA1**.

**De vuelta en Firebase Console:**

1. Ir a **Project Settings** (ícono de engranaje en el menú lateral)
2. Seleccionar tu app Android
3. Hacer clic en "Add fingerprint"
4. Pegar el SHA-1 copiado
5. Hacer clic en "Save"
6. **Descargar nuevamente** el archivo `google-services.json` actualizado y reemplazarlo en `packages/frontend/android/app/`

### 1.6 Habilitar Firebase Cloud Messaging (FCM)

1. En Firebase Console, ir a **Build > Cloud Messaging**
2. Si aparece "Get started", hacer clic
3. FCM ya estará habilitado automáticamente con tu app Android registrada

### 1.7 Obtener Server Key de FCM (para el Backend)

1. En Firebase Console, ir a **Project Settings > Cloud Messaging**
2. En la sección "Cloud Messaging API (Legacy)":

   - Si dice "Disabled", hacer clic en el menú de tres puntos y seleccionar "Manage API in Google Cloud Console"
   - En Google Cloud Console, hacer clic en "Enable" para habilitar la API
   - Regresar a Firebase Console

3. Copiar el **Server Key** (necesario para enviar notificaciones desde el backend)
4. Guardar este valor de forma segura (lo usaremos en el archivo `.env` del backend)

---

## Fase 2: Configuración del Backend

### 2.1 Instalar Dependencias de Firebase Admin SDK

**Archivo: `packages/backend/package.json`**

Agregar las siguientes dependencias:

```bash
cd packages/backend
npm install firebase-admin
npm install @types/node --save-dev
```

### 2.2 Configurar Variables de Entorno

**Archivo: `packages/backend/.env`**

Agregar las siguientes variables:

```env
# Existentes...
NODE_ENV=development
PORT=3000
DATABASE_URL="file:./prisma/dev.db"

# Nuevas variables de Firebase
FIREBASE_PROJECT_ID=app-cuatri-dmi
FIREBASE_PRIVATE_KEY="-----BEGIN PRIVATE KEY-----\n...\n-----END PRIVATE KEY-----\n"
FIREBASE_CLIENT_EMAIL=firebase-adminsdk-xxxxx@app-cuatri-dmi.iam.gserviceaccount.com
FCM_SERVER_KEY=AAAAxxxxxxxx:xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
```

**Cómo obtener las credenciales de Firebase Admin:**

1. En Firebase Console, ir a **Project Settings > Service Accounts**
2. Hacer clic en "Generate new private key"
3. Confirmar haciendo clic en "Generate key"
4. Se descargará un archivo JSON con las credenciales
5. Abrir el archivo JSON y copiar:

   - `project_id` → `FIREBASE_PROJECT_ID`
   - `private_key` → `FIREBASE_PRIVATE_KEY` (incluir los saltos de línea como `\n`)
   - `client_email` → `FIREBASE_CLIENT_EMAIL`

6. **IMPORTANTE**: NO versionar este archivo JSON ni el `.env` con estas credenciales

### 2.3 Actualizar Schema de Prisma

**Archivo: `packages/backend/prisma/schema.prisma`**

Agregar campos para Firebase y tokens FCM:

```prisma
model Usuario {
  id                Int      @id @default(autoincrement())
  email             String   @unique
  password          String?  // Hacer opcional para usuarios de Google
  nombre            String
  apellido          String
  activo            Boolean  @default(true)
  emailVerified     Boolean  @default(false)
  verificationToken String?  @unique
  
  // Campos Firebase
  firebaseUid       String?  @unique  // UID de Firebase Auth
  authProvider      String   @default("local")  // "local", "google.com"
  photoURL          String?  // URL de foto de perfil (de Google)
  
  // Tokens FCM para notificaciones push
  fcmTokens         String?  // JSON array de tokens
  
  createdAt         DateTime @default(now())
  updatedAt         DateTime @updatedAt

  @@map("usuarios")
}
```

Ejecutar migración:

```bash
npm run prisma:migrate
```

### 2.4 Crear Configuración de Firebase Admin

**Archivo: `packages/backend/src/config/firebase.ts`** (nuevo archivo)

```typescript
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
```

### 2.5 Actualizar Archivo de Configuración de Entorno

**Archivo: `packages/backend/src/config/env.ts`**

Agregar las nuevas variables:

```typescript
// Agregar después de las variables existentes:
firebaseProjectId: process.env.FIREBASE_PROJECT_ID,
firebasePrivateKey: process.env.FIREBASE_PRIVATE_KEY,
firebaseClientEmail: process.env.FIREBASE_CLIENT_EMAIL,
fcmServerKey: process.env.FCM_SERVER_KEY,
```

### 2.6 Modificar Controlador de Autenticación

**Archivo: `packages/backend/src/controllers/authController.ts`**

Agregar nuevos endpoints para Firebase:

1. **Endpoint de Login con Firebase (Email/Password y Google)**
```typescript
import { firebaseAuth } from '../config/firebase';

export const firebaseLogin = asyncHandler(async (req: Request, res: Response) => {
  const { idToken } = req.body; // Token de Firebase del frontend

  // Verificar el token de Firebase
  const decodedToken = await firebaseAuth.verifyIdToken(idToken);
  const { uid, email, name, picture, firebase } = decodedToken;
  
  if (!email) {
    throw createError('Email no disponible en el token de Firebase', 400, 'EMAIL_NOT_AVAILABLE');
  }

  // Determinar el proveedor de autenticación
  const provider = firebase.sign_in_provider || 'local'; // "password", "google.com", etc.

  // Buscar usuario en la BD por firebaseUid o email
  let usuario = await prisma.usuario.findFirst({
    where: {
      OR: [
        { firebaseUid: uid },
        { email: email },
      ],
    },
  });

  if (usuario) {
    // Usuario existente: actualizar datos de Firebase si es necesario
    if (!usuario.firebaseUid) {
      // Migración: vincular cuenta existente con Firebase
      usuario = await prisma.usuario.update({
        where: { id: usuario.id },
        data: {
          firebaseUid: uid,
          authProvider: provider,
          emailVerified: decodedToken.email_verified || false,
          photoURL: picture || usuario.photoURL,
        },
      });
    }
  } else {
    // Usuario nuevo: crear en la BD
    const [nombre, apellido] = (name || email.split('@')[0]).split(' ');
    usuario = await prisma.usuario.create({
      data: {
        email,
        firebaseUid: uid,
        nombre: nombre || email.split('@')[0],
        apellido: apellido || '',
        authProvider: provider,
        emailVerified: decodedToken.email_verified || false,
        photoURL: picture,
        password: null, // No hay password para usuarios de Google
      },
    });
  }

  // Generar JWT propio (opcional, puedes usar solo Firebase tokens)
  const token = generateToken({
    id: usuario.id,
    email: usuario.email,
  });

  const userResponse: UserWithoutPassword = excludePassword(usuario);

  const response: AuthResponse = {
    user: userResponse,
    token,
  };

  res.json(createSuccessResponse(response, 'Login exitoso'));
});
```

2. **Endpoint para Registrar Token FCM**
```typescript
export const registerFcmToken = asyncHandler(async (req: Request, res: Response) => {
  if (!req.user) {
    throw createError('Usuario no autenticado', 401, 'USER_NOT_AUTHENTICATED');
  }

  const { fcmToken } = req.body;

  if (!fcmToken) {
    throw createError('Token FCM requerido', 400, 'FCM_TOKEN_REQUIRED');
  }

  // Obtener tokens existentes
  const usuario = await prisma.usuario.findUnique({
    where: { id: req.user.id },
    select: { fcmTokens: true },
  });

  let tokens: string[] = [];
  if (usuario?.fcmTokens) {
    try {
      tokens = JSON.parse(usuario.fcmTokens);
    } catch (e) {
      tokens = [];
    }
  }

  // Agregar nuevo token si no existe
  if (!tokens.includes(fcmToken)) {
    tokens.push(fcmToken);
  }

  // Actualizar en la BD
  await prisma.usuario.update({
    where: { id: req.user.id },
    data: { fcmTokens: JSON.stringify(tokens) },
  });

  res.json(createSuccessResponse(null, 'Token FCM registrado exitosamente'));
});
```

3. **Endpoint para Enviar Notificación Push (ejemplo)**

**Archivo: `packages/backend/src/controllers/notificationController.ts`** (nuevo archivo)

```typescript
import { Request, Response } from 'express';
import { asyncHandler, createError } from '../middlewares/errorHandler';
import { createSuccessResponse } from '../models/ApiResponse';
import { firebaseMessaging } from '../config/firebase';
import { prisma } from '../config/database';

export const sendNotification = asyncHandler(async (req: Request, res: Response) => {
  const { usuarioId, title, body, data } = req.body;

  // Obtener tokens FCM del usuario
  const usuario = await prisma.usuario.findUnique({
    where: { id: usuarioId },
    select: { fcmTokens: true },
  });

  if (!usuario || !usuario.fcmTokens) {
    throw createError('Usuario no tiene tokens FCM registrados', 404, 'NO_FCM_TOKENS');
  }

  let tokens: string[] = [];
  try {
    tokens = JSON.parse(usuario.fcmTokens);
  } catch (e) {
    throw createError('Error al parsear tokens FCM', 500, 'PARSE_ERROR');
  }

  if (tokens.length === 0) {
    throw createError('No hay tokens FCM para este usuario', 404, 'NO_TOKENS');
  }

  // Enviar notificación a todos los dispositivos del usuario
  const message = {
    notification: {
      title,
      body,
    },
    data: data || {},
    tokens,
  };

  const response = await firebaseMessaging.sendMulticast(message);

  res.json(createSuccessResponse(
    { successCount: response.successCount, failureCount: response.failureCount },
    'Notificación enviada'
  ));
});
```

### 2.7 Crear/Actualizar Rutas de Autenticación

**Archivo: `packages/backend/src/routes/authRoutes.ts`**

Agregar las nuevas rutas:

```typescript
import { registerFcmToken } from '../controllers/authController';

// Agregar después de las rutas existentes:
router.post('/firebase-login', firebaseLogin);
router.post('/fcm-token', authenticate, registerFcmToken);
```

**Archivo: `packages/backend/src/routes/notificationRoutes.ts`** (nuevo archivo)

```typescript
import { Router } from 'express';
import { sendNotification } from '../controllers/notificationController';
import { authenticate } from '../middlewares/auth';

const router = Router();

router.post('/send', authenticate, sendNotification);

export default router;
```

Registrar en `packages/backend/src/index.ts`:

```typescript
import notificationRoutes from './routes/notificationRoutes';

app.use('/api/notifications', notificationRoutes);
```

### 2.8 Script de Migración de Usuarios

**Archivo: `packages/backend/src/scripts/migrateUsersToFirebase.ts`** (nuevo archivo)

Script para migrar usuarios existentes a Firebase Authentication:

```typescript
import { prisma } from '../config/database';
import { firebaseAuth } from '../config/firebase';

async function migrateUsersToFirebase() {
  console.log('Iniciando migración de usuarios a Firebase...');

  const usuarios = await prisma.usuario.findMany({
    where: { firebaseUid: null },
  });

  console.log(`Encontrados ${usuarios.length} usuarios para migrar`);

  for (const usuario of usuarios) {
    try {
      // Crear usuario en Firebase Auth
      const userRecord = await firebaseAuth.createUser({
        email: usuario.email,
        emailVerified: usuario.emailVerified,
        displayName: `${usuario.nombre} ${usuario.apellido}`,
        disabled: !usuario.activo,
      });

      // Actualizar usuario en la BD con el UID de Firebase
      await prisma.usuario.update({
        where: { id: usuario.id },
        data: {
          firebaseUid: userRecord.uid,
          authProvider: 'local',
        },
      });

      console.log(`✓ Usuario migrado: ${usuario.email}`);
    } catch (error: any) {
      if (error.code === 'auth/email-already-exists') {
        // El usuario ya existe en Firebase, obtener su UID
        const userRecord = await firebaseAuth.getUserByEmail(usuario.email);
        await prisma.usuario.update({
          where: { id: usuario.id },
          data: {
            firebaseUid: userRecord.uid,
            authProvider: 'local',
          },
        });
        console.log(`✓ Usuario vinculado (ya existía en Firebase): ${usuario.email}`);
      } else {
        console.error(`✗ Error migrando ${usuario.email}:`, error.message);
      }
    }
  }

  console.log('Migración completada');
  process.exit(0);
}

migrateUsersToFirebase().catch((error) => {
  console.error('Error en la migración:', error);
  process.exit(1);
});
```

Agregar script en `package.json`:

```json
"scripts": {
  "migrate:firebase": "ts-node src/scripts/migrateUsersToFirebase.ts"
}
```

---

## Fase 3: Configuración del Frontend (Flutter)

### 3.1 Agregar Dependencias de Firebase

**Archivo: `packages/frontend/pubspec.yaml`**

```yaml
dependencies:
  flutter:
    sdk: flutter
  dio: ^5.4.0
  provider: ^6.1.1
  shared_preferences: ^2.2.2
  flutter_secure_storage: ^9.0.0
  
  # Firebase
  firebase_core: ^3.6.0
  firebase_auth: ^5.3.1
  google_sign_in: ^6.2.1
  firebase_messaging: ^15.1.3
  flutter_local_notifications: ^18.0.1

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^5.0.0

flutter:
  uses-material-design: true
```

Ejecutar:

```bash
cd packages/frontend
flutter pub get
```

### 3.2 Configurar Gradle para Firebase

**Archivo: `packages/frontend/android/build.gradle.kts`**

Agregar el plugin de Google Services:

```kotlin
plugins {
    // Existentes...
}

buildscript {
    dependencies {
        classpath("com.google.gms:google-services:4.4.2")
    }
}

// ... resto del archivo
```

**Archivo: `packages/frontend/android/app/build.gradle.kts`**

```kotlin
plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")  // ← Agregar esta línea
}

android {
    namespace = "com.utez.frontend"
    compileSdk = flutter.compileSdkVersion
    // Actualizar minSdk para Firebase
    
    defaultConfig {
        applicationId = "com.utez.frontend"
        minSdk = 21  // ← Cambiar de flutter.minSdkVersion a 21 (requerido por Firebase)
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        
        multiDexEnabled = true  // ← Agregar para evitar límite de métodos
    }
    
    // ... resto del archivo
}

dependencies {
    implementation("androidx.multidex:multidex:2.0.1")
}
```

### 3.3 Configurar AndroidManifest.xml

**Archivo: `packages/frontend/android/app/src/main/AndroidManifest.xml`**

Agregar permisos y metadata:

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <!-- Permisos para notificaciones -->
    <uses-permission android:name="android.permission.INTERNET"/>
    <uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
    <uses-permission android:name="android.permission.VIBRATE"/>
    <uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED"/>
    
    <application
        android:label="frontned"
        android:name="${applicationName}"
        android:icon="@mipmap/ic_launcher">
        
        <!-- Metadata de Google Services -->
        <meta-data
            android:name="com.google.firebase.messaging.default_notification_channel_id"
            android:value="default_channel" />
        
        <activity
            android:name=".MainActivity"
            android:exported="true"
            android:launchMode="singleTop"
            android:configChanges="orientation|keyboardHidden|keyboard|screenSize|smallestScreenSize|locale|layoutDirection|fontScale|screenLayout|density|uiMode"
            android:hardwareAccelerated="true"
            android:windowSoftInputMode="adjustResize">
            
            <meta-data
              android:name="io.flutter.embedding.android.NormalTheme"
              android:resource="@style/NormalTheme"
              />
            <intent-filter>
                <action android:name="android.intent.action.MAIN"/>
                <category android:name="android.intent.category.LAUNCHER"/>
            </intent-filter>
            
            <!-- Intent filter para notificaciones -->
            <intent-filter>
                <action android:name="FLUTTER_NOTIFICATION_CLICK" />
                <category android:name="android.intent.category.DEFAULT" />
            </intent-filter>
        </activity>
        
        <meta-data
            android:name="flutterEmbedding"
            android:value="2" />
    </application>
</manifest>
```

### 3.4 Inicializar Firebase en la App

**Archivo: `packages/frontend/lib/main.dart`**

```dart
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

// Handler para notificaciones en background
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('Handling background message: ${message.messageId}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inicializar Firebase
  await Firebase.initializeApp();
  
  // Configurar handler de notificaciones en background
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  
  runApp(const MyApp());
}

// ... resto del archivo
```

### 3.5 Crear Servicio de Firebase Auth

**Archivo: `packages/frontend/lib/services/firebase_auth_service.dart`** (nuevo archivo)

```dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class FirebaseAuthService {
  static final FirebaseAuthService _instance = FirebaseAuthService._internal();
  factory FirebaseAuthService() => _instance;
  FirebaseAuthService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  /// Login con Email y Password
  Future<UserCredential> signInWithEmailPassword(String email, String password) async {
    return await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  /// Registro con Email y Password
  Future<UserCredential> registerWithEmailPassword(
    String email,
    String password,
    String displayName,
  ) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    
    // Actualizar perfil
    await credential.user?.updateDisplayName(displayName);
    
    return credential;
  }

  /// Login con Google
  Future<UserCredential> signInWithGoogle() async {
    // Iniciar flujo de autenticación de Google
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
    
    if (googleUser == null) {
      throw Exception('Inicio de sesión con Google cancelado');
    }

    // Obtener detalles de autenticación
    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

    // Crear credencial de Firebase
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    // Autenticar con Firebase
    return await _auth.signInWithCredential(credential);
  }

  /// Obtener ID Token de Firebase (para enviar al backend)
  Future<String?> getIdToken() async {
    final user = _auth.currentUser;
    return await user?.getIdToken();
  }

  /// Cerrar sesión
  Future<void> signOut() async {
    await Future.wait([
      _auth.signOut(),
      _googleSignIn.signOut(),
    ]);
  }

  /// Usuario actual
  User? get currentUser => _auth.currentUser;

  /// Stream de cambios de autenticación
  Stream<User?> get authStateChanges => _auth.authStateChanges();
}
```

### 3.6 Crear Servicio de Firebase Messaging

**Archivo: `packages/frontend/lib/services/firebase_messaging_service.dart`** (nuevo archivo)

```dart
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class FirebaseMessagingService {
  static final FirebaseMessagingService _instance = FirebaseMessagingService._internal();
  factory FirebaseMessagingService() => _instance;
  FirebaseMessagingService._internal();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

  /// Inicializar servicio de notificaciones
  Future<void> initialize() async {
    // Solicitar permisos
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('Permisos de notificación concedidos');
    } else {
      print('Permisos de notificación denegados');
    }

    // Configurar notificaciones locales
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidSettings);
    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    // Crear canal de notificaciones
    const channel = AndroidNotificationChannel(
      'default_channel',
      'Notificaciones',
      description: 'Canal de notificaciones por defecto',
      importance: Importance.high,
    );
    await _localNotifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    // Escuchar notificaciones en foreground
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Escuchar cuando se abre la app desde una notificación
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);
  }

  /// Obtener token FCM
  Future<String?> getToken() async {
    return await _messaging.getToken();
  }

  /// Manejar notificaciones en foreground
  void _handleForegroundMessage(RemoteMessage message) {
    print('Mensaje recibido en foreground: ${message.messageId}');
    
    // Mostrar notificación local
    _showLocalNotification(message);
  }

  /// Mostrar notificación local
  Future<void> _showLocalNotification(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) return;

    const androidDetails = AndroidNotificationDetails(
      'default_channel',
      'Notificaciones',
      channelDescription: 'Canal de notificaciones por defecto',
      importance: Importance.high,
      priority: Priority.high,
    );
    const details = NotificationDetails(android: androidDetails);

    await _localNotifications.show(
      notification.hashCode,
      notification.title,
      notification.body,
      details,
      payload: message.data.toString(),
    );
  }

  /// Manejar tap en notificación
  void _onNotificationTap(NotificationResponse response) {
    print('Notificación tocada: ${response.payload}');
    // Navegar a la pantalla correspondiente
  }

  /// Manejar cuando se abre la app desde una notificación
  void _handleMessageOpenedApp(RemoteMessage message) {
    print('App abierta desde notificación: ${message.messageId}');
    // Navegar a la pantalla correspondiente
  }
}
```

### 3.7 Actualizar AuthService para Usar Firebase

**Archivo: `packages/frontend/lib/services/auth_service.dart`**

Modificar los métodos de login y registro:

```dart
import 'firebase_auth_service.dart';
import 'firebase_messaging_service.dart';

class AuthService {
  // ... código existente
  
  final FirebaseAuthService _firebaseAuth = FirebaseAuthService();
  final FirebaseMessagingService _fcm = FirebaseMessagingService();

  /// Login con Firebase y sincronizar con backend
  Future<AuthResponse> loginWithFirebase(String email, String password) async {
    try {
      // 1. Autenticar con Firebase
      final userCredential = await _firebaseAuth.signInWithEmailPassword(email, password);
      
      // 2. Obtener ID Token de Firebase
      final idToken = await userCredential.user?.getIdToken();
      if (idToken == null) {
        throw Exception('No se pudo obtener token de Firebase');
      }
      
      // 3. Enviar token al backend para sincronizar usuario
      final response = await _apiService.post<AuthResponse>(
        '/api/auth/firebase-login',
        data: {'idToken': idToken},
        fromJson: (json) => AuthResponse.fromJson(json),
      );
      
      if (response.success && response.data != null) {
        await _saveAuthData(response.data!);
        
        // 4. Registrar token FCM
        await _registerFcmToken();
        
        return response.data!;
      } else {
        throw Exception(response.message ?? 'Error al iniciar sesión');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Login con Google
  Future<AuthResponse> loginWithGoogle() async {
    try {
      // 1. Autenticar con Google mediante Firebase
      final userCredential = await _firebaseAuth.signInWithGoogle();
      
      // 2. Obtener ID Token
      final idToken = await userCredential.user?.getIdToken();
      if (idToken == null) {
        throw Exception('No se pudo obtener token de Firebase');
      }
      
      // 3. Enviar token al backend
      final response = await _apiService.post<AuthResponse>(
        '/api/auth/firebase-login',
        data: {'idToken': idToken},
        fromJson: (json) => AuthResponse.fromJson(json),
      );
      
      if (response.success && response.data != null) {
        await _saveAuthData(response.data!);
        await _registerFcmToken();
        return response.data!;
      } else {
        throw Exception(response.message ?? 'Error al iniciar sesión con Google');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Registrar token FCM en el backend
  Future<void> _registerFcmToken() async {
    try {
      final fcmToken = await _fcm.getToken();
      if (fcmToken == null) return;
      
      final token = await _storageService.getToken();
      if (token != null) {
        _apiService.setAuthToken(token);
        await _apiService.post(
          '/api/auth/fcm-token',
          data: {'fcmToken': fcmToken},
        );
      }
    } catch (e) {
      print('Error registrando FCM token: $e');
      // No lanzar error para no interrumpir el flujo de login
    }
  }
}
```

### 3.8 Actualizar UI para Google Sign-In

**Archivo: `packages/frontend/lib/screens/login_screen.dart`**

Agregar botón de Google Sign-In:

```dart
// Después del botón de login normal, agregar:
const SizedBox(height: 16),
const Divider(),
const SizedBox(height: 16),

// Botón de Google Sign-In
CustomButton(
  text: 'Continuar con Google',
  onPressed: _isLoading ? null : _loginWithGoogle,
  isLoading: _isGoogleLoading,
  backgroundColor: Colors.white,
  textColor: Colors.black87,
  icon: const Icon(Icons.g_mobiledata, size: 32),
),
```

Agregar el método `_loginWithGoogle`:

```dart
bool _isGoogleLoading = false;

Future<void> _loginWithGoogle() async {
  setState(() => _isGoogleLoading = true);
  
  try {
    await context.read<AuthProvider>().loginWithGoogle();
    // Navegar a home
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/home');
    }
  } catch (e) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  } finally {
    if (mounted) {
      setState(() => _isGoogleLoading = false);
    }
  }
}
```

### 3.9 Actualizar AuthProvider

**Archivo: `packages/frontend/lib/providers/auth_provider.dart`**

Agregar método para Google Sign-In:

```dart
Future<void> loginWithGoogle() async {
  setLoading(true);
  try {
    final authResponse = await _authService.loginWithGoogle();
    _user = authResponse.user;
    _isAuthenticated = true;
    setError(null);
  } catch (e) {
    setError(e.toString());
    rethrow;
  } finally {
    setLoading(false);
  }
}
```

---

## Fase 4: Ejecución y Pruebas

### 4.1 Migrar Usuarios Existentes

```bash
cd packages/backend
npm run migrate:firebase
```

### 4.2 Iniciar Backend

```bash
cd packages/backend
npm run dev
```

### 4.3 Ejecutar App Flutter

```bash
cd packages/frontend
flutter run
```

### 4.4 Probar Funcionalidades

**Autenticación:**

1. Login con Email/Password existente
2. Login con Google (nueva cuenta)
3. Verificar que el usuario se sincroniza en el backend

**Notificaciones Push:**

1. Iniciar sesión en la app
2. Verificar que el token FCM se registra en el backend
3. Desde el backend o Firebase Console, enviar una notificación de prueba
4. Verificar que se recibe en el dispositivo (con app en foreground, background y cerrada)

---

## Notas Adicionales

### Seguridad

- **NUNCA** versionar el archivo `google-services.json` en producción con credenciales reales
- **NUNCA** versionar el archivo `.env` con las credenciales de Firebase Admin
- Usar variables de entorno para credenciales sensibles
- Implementar reglas de seguridad en Firebase Console para Firestore/Storage si se usan

### Producción

- Generar SHA-1 de release keystore y agregarlo a Firebase Console
- Configurar ProGuard/R8 para ofuscar el código Android
- Habilitar App Check de Firebase para prevenir abuso de APIs
- Configurar diferentes proyectos de Firebase para desarrollo y producción

### Troubleshooting

**Error: "Default FirebaseApp is not initialized"**

- Asegurarse de que `google-services.json` esté en la ruta correcta
- Verificar que `Firebase.initializeApp()` se llama en `main()`

**Error: "Google Sign-In failed"**

- Verificar que el SHA-1 esté configurado correctamente
- Asegurar que Google Sign-In esté habilitado en Firebase Console
- Verificar que el `google-services.json` esté actualizado después de agregar SHA-1

**Notificaciones no se reciben:**

- Verificar permisos en AndroidManifest.xml
- Comprobar que el token FCM se registró correctamente en el backend
- Revisar logs de Firebase Cloud Messaging en Firebase Console