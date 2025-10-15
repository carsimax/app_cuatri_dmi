/*
  Warnings:

  - Added the required column `password` to the `usuarios` table without a default value. This is not possible if the table is not empty.

*/
-- RedefineTables
PRAGMA defer_foreign_keys=ON;
PRAGMA foreign_keys=OFF;
CREATE TABLE "new_usuarios" (
    "id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
    "email" TEXT NOT NULL,
    "password" TEXT NOT NULL,
    "nombre" TEXT NOT NULL,
    "apellido" TEXT NOT NULL,
    "activo" BOOLEAN NOT NULL DEFAULT true,
    "emailVerified" BOOLEAN NOT NULL DEFAULT false,
    "verificationToken" TEXT,
    "createdAt" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" DATETIME NOT NULL
);
INSERT INTO "new_usuarios" ("activo", "apellido", "createdAt", "email", "id", "nombre", "updatedAt", "password", "emailVerified", "verificationToken") SELECT "activo", "apellido", "createdAt", "email", "id", "nombre", "updatedAt", 'TEMP_PASSWORD_TO_UPDATE', false, NULL FROM "usuarios";
DROP TABLE "usuarios";
ALTER TABLE "new_usuarios" RENAME TO "usuarios";
CREATE UNIQUE INDEX "usuarios_email_key" ON "usuarios"("email");
CREATE UNIQUE INDEX "usuarios_verificationToken_key" ON "usuarios"("verificationToken");
PRAGMA foreign_keys=ON;
PRAGMA defer_foreign_keys=OFF;
