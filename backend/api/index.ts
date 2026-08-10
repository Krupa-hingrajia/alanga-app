import { NestFactory, Reflector } from '@nestjs/core';
import { ValidationPipe, ClassSerializerInterceptor } from '@nestjs/common';
import { SwaggerModule, DocumentBuilder } from '@nestjs/swagger';
import { ExpressAdapter } from '@nestjs/platform-express';
import express from 'express';
import { AppModule } from '../src/app.module';
import { TransformInterceptor } from '../src/common/interceptors/transform.interceptor';
import { HttpExceptionFilter } from '../src/common/filters/http-exception.filter';
import { ValidationFilter } from '../src/common/filters/validation.filter';
import { PrismaExceptionFilter } from '../src/common/filters/prisma-exception.filter';
import { ValidationException } from '../src/common/exceptions/validation.exception';

// Create Express server instance
const server = express();

let isAppInitialized = false;

async function bootstrap() {
  if (isAppInitialized) {
    return server;
  }

  // Create Nest application using Express Adapter
  const app = await NestFactory.create(
    AppModule,
    new ExpressAdapter(server),
  );

  // Set API Versioning prefix
  app.setGlobalPrefix('api/v1');

  // Enable CORS
  app.enableCors();

  // Serialization interceptor (exclude fields marked with @Exclude like password/refresh token)
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

  // Swagger Documentation Setup
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
  SwaggerModule.setup('api/v1/docs', app, document, {
    customCssUrl: 'https://cdnjs.cloudflare.com/ajax/libs/swagger-ui/4.15.5/swagger-ui.min.css',
    customJs: [
      'https://cdnjs.cloudflare.com/ajax/libs/swagger-ui/4.15.5/swagger-ui-bundle.min.js',
      'https://cdnjs.cloudflare.com/ajax/libs/swagger-ui/4.15.5/swagger-ui-standalone-preset.min.js',
    ],
  });

  await app.init();
  isAppInitialized = true;
  return server;
}

// Vercel serverless function export
export default async (req: any, res: any) => {
  await bootstrap();
  server(req, res);
};
