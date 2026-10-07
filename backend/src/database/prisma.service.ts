import { Injectable, OnModuleInit, OnModuleDestroy, Logger } from '@nestjs/common';
import { PrismaClient } from '@prisma/client';
import { ConfigService } from '@nestjs/config';

@Injectable()
export class PrismaService extends PrismaClient implements OnModuleInit, OnModuleDestroy {
  private readonly logger = new Logger(PrismaService.name);

  constructor(private readonly configService: ConfigService) {
    const dbUrl =
      configService.get<string>('database.url') ||
      process.env.DATABASE_URL ||
      'postgresql://postgres:Sachit%402026@34.21.175.107:5432/postgres?sslmode=disable';

    super({
      datasources: {
        db: {
          url: dbUrl,
        },
      },
      log: ['warn', 'error'],
    });
  }

  async onModuleInit() {
    try {
      await this.$connect();
      this.logger.log('Prisma connected to Database successfully');
    } catch (error) {
      this.logger.error(`Prisma connection error (will retry on demand): ${error.message}`);
    }
  }

  async onModuleDestroy() {
    await this.$disconnect();
  }
}
