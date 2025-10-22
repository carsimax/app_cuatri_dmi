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