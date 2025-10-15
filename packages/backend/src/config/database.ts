import { PrismaClient } from '@prisma/client';

// Singleton pattern para la conexión a la base de datos
class Database {
  private static instance: Database;
  public prisma: PrismaClient;

  private constructor() {
    this.prisma = new PrismaClient({
      log: process.env.NODE_ENV === 'development' ? ['query', 'info', 'warn', 'error'] : ['error'],
    });
  }

  public static getInstance(): Database {
    if (!Database.instance) {
      Database.instance = new Database();
    }
    return Database.instance;
  }

  public async connect(): Promise<void> {
    try {
      await this.prisma.$connect();
      console.log('✅ Base de datos conectada exitosamente');
    } catch (error) {
      console.error('❌ Error al conectar con la base de datos:', error);
      process.exit(1);
    }
  }

  public async disconnect(): Promise<void> {
    await this.prisma.$disconnect();
    console.log('🔌 Base de datos desconectada');
  }
}

export const database = Database.getInstance();
export const prisma = database.prisma;
