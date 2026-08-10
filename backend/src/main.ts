import { NestFactory, Reflector } from '@nestjs/core';
import { ValidationPipe, ClassSerializerInterceptor } from '@nestjs/common';
import { SwaggerModule, DocumentBuilder } from '@nestjs/swagger';
import { ConfigService } from '@nestjs/config';
import { AppModule } from './app.module';
import { TransformInterceptor } from './common/interceptors/transform.interceptor';
import { HttpExceptionFilter } from './common/filters/http-exception.filter';
import { ValidationFilter } from './common/filters/validation.filter';
import { PrismaExceptionFilter } from './common/filters/prisma-exception.filter';
import { ValidationException } from './common/exceptions/validation.exception';

async function bootstrap() {
  const app = await NestFactory.create(AppModule);

  const configService = app.get(ConfigService);

  // Set API Versioning prefix
  app.setGlobalPrefix('api/v1');

  // Enable CORS
  app.enableCors();

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
  SwaggerModule.setup('api/v1/docs', app, document);

  const port = configService.get<number>('port') || 3000;
  await app.listen(port);
  console.log(`Application is running on: http://localhost:${port}/api/v1`);
  console.log(`Swagger documentation is available at: http://localhost:${port}/api/v1/docs`);
}
bootstrap();
