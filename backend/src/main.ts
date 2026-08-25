import { NestFactory, Reflector } from '@nestjs/core';
import { ValidationPipe, ClassSerializerInterceptor, Logger } from '@nestjs/common';
import { SwaggerModule, DocumentBuilder } from '@nestjs/swagger';
import { ConfigService } from '@nestjs/config';
import { AppModule } from './app.module';
import { TransformInterceptor } from './common/interceptors/transform.interceptor';
import { HttpExceptionFilter } from './common/filters/http-exception.filter';
import { ValidationFilter } from './common/filters/validation.filter';
import { PrismaExceptionFilter } from './common/filters/prisma-exception.filter';
import { ValidationException } from './common/exceptions/validation.exception';

import { json, urlencoded, static as expressStatic } from 'express';
import { join } from 'path';

async function bootstrap() {
  const logger = new Logger('Bootstrap');

  const app = await NestFactory.create(AppModule, {
    // Disable verbose NestJS logs in production
    logger:
      process.env.NODE_ENV === 'production'
        ? ['error', 'warn']
        : ['error', 'warn', 'log', 'debug', 'verbose'],
  });

  app.use(json({ limit: '50mb' }));
  app.use(urlencoded({ limit: '50mb', extended: true }));
  app.use('/uploads', expressStatic(join(process.cwd(), 'uploads')));

  const configService = app.get(ConfigService);
  const apiPrefix = configService.get<string>('apiPrefix') || 'api/v1';
  const corsOrigin = configService.get<string>('corsOrigin') || '*';
  const isProduction = configService.get<string>('nodeEnv') === 'production';

  // Set API Versioning prefix
  app.setGlobalPrefix(apiPrefix);

  // Enable CORS
  app.enableCors({ origin: corsOrigin });

  // Serialization interceptor (to exclude fields marked with @Exclude like password/refresh token)
  app.useGlobalInterceptors(new ClassSerializerInterceptor(app.get(Reflector)));

  // Global transform interceptor
  app.useGlobalInterceptors(new TransformInterceptor());

  // Global error filters
  app.useGlobalFilters(
    new HttpExceptionFilter(),
    new ValidationFilter(),
    new PrismaExceptionFilter(),
  );

  // Global Validation pipe with custom exception factory
  app.useGlobalPipes(
    new ValidationPipe({
      whitelist: true,
      transform: true,
      exceptionFactory: (errors) => new ValidationException(errors),
    }),
  );

  // Swagger Documentation — only enabled in non-production environments
  if (!isProduction) {
    const config = new DocumentBuilder()
      .setTitle('E-Commerce Marketplace API')
      .setDescription('Production-ready backend API documentation for the E-Commerce Marketplace')
      .setVersion('1.0')
      .addBearerAuth(
        {
          type: 'http',
          scheme: 'bearer',
          bearerFormat: 'JWT',
          name: 'JWT',
          description: 'Enter Access Token',
          in: 'header',
        },
        'access-token',
      )
      .addBearerAuth(
        {
          type: 'http',
          scheme: 'bearer',
          bearerFormat: 'JWT',
          name: 'JWT',
          description: 'Enter Refresh Token',
          in: 'header',
        },
        'refresh-token',
      )
      .build();

    const document = SwaggerModule.createDocument(app, config);
    SwaggerModule.setup(`${apiPrefix}/docs`, app, document, {
      customCssUrl: 'https://cdnjs.cloudflare.com/ajax/libs/swagger-ui/4.15.5/swagger-ui.min.css',
      customJs: [
        'https://cdnjs.cloudflare.com/ajax/libs/swagger-ui/4.15.5/swagger-ui-bundle.min.js',
        'https://cdnjs.cloudflare.com/ajax/libs/swagger-ui/4.15.5/swagger-ui-standalone-preset.min.js',
      ],
    });
  }

  const port = configService.get<number>('port') || 3000;
  await app.listen(port, '0.0.0.0');

  if (!isProduction) {
    logger.log(`Application is running on: http://localhost:${port}/${apiPrefix}`);
    logger.log(`Swagger docs available at: http://localhost:${port}/${apiPrefix}/docs`);
  } else {
    logger.log(`Application is running on port ${port} [production]`);
  }
}
bootstrap();
