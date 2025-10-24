-- RedefineTables
PRAGMA defer_foreign_keys=ON;
PRAGMA foreign_keys=OFF;
CREATE TABLE "new_usuarios" (
    "id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
    "email" TEXT NOT NULL,
    "password" TEXT,
    "nombre" TEXT NOT NULL,
    "apellido" TEXT NOT NULL,
    "activo" BOOLEAN NOT NULL DEFAULT true,
    "emailVerified" BOOLEAN NOT NULL DEFAULT false,
    "verificationToken" TEXT,
    "createdAt" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" DATETIME NOT NULL,
    "firebaseUid" TEXT,
    "authProvider" TEXT NOT NULL DEFAULT 'local',
    "photoURL" TEXT,
    "fcmTokens" TEXT
);
INSERT INTO "new_usuarios" ("activo", "apellido", "createdAt", "email", "emailVerified", "id", "nombre", "password", "updatedAt", "verificationToken") SELECT "activo", "apellido", "createdAt", "email", "emailVerified", "id", "nombre", "password", "updatedAt", "verificationToken" FROM "usuarios";
DROP TABLE "usuarios";
ALTER TABLE "new_usuarios" RENAME TO "usuarios";
CREATE UNIQUE INDEX "usuarios_email_key" ON "usuarios"("email");
CREATE UNIQUE INDEX "usuarios_verificationToken_key" ON "usuarios"("verificationToken");
CREATE UNIQUE INDEX "usuarios_firebaseUid_key" ON "usuarios"("firebaseUid");
PRAGMA foreign_keys=ON;
PRAGMA defer_foreign_keys=OFF;
