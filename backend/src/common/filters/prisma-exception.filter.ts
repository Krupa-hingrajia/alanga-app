import { ExceptionFilter, Catch, ArgumentsHost, HttpStatus } from '@nestjs/common';
import { Response } from 'express';
import { Prisma } from '@prisma/client';

@Catch(Prisma.PrismaClientKnownRequestError)
export class PrismaExceptionFilter implements ExceptionFilter {
  catch(exception: Prisma.PrismaClientKnownRequestError, host: ArgumentsHost) {
    const ctx = host.switchToHttp();
    const response = ctx.getResponse<Response>();
    
    let statusCode = HttpStatus.BAD_REQUEST;
    let message = 'Database operation failed';
    const errors: string[] = [];

    switch (exception.code) {
      case 'P2002': {
        statusCode = HttpStatus.CONFLICT;
        const target = exception.meta?.target as string[];
        const fields = target ? target.join(', ') : 'fields';
        message = `Unique constraint failed. The specified ${fields} is already in use.`;
        errors.push(`${fields} must be unique`);
        break;
      }
      case 'P2025': {
        statusCode = HttpStatus.NOT_FOUND;
        message = (exception.meta?.cause as string) || 'Record not found';
        break;
      }
      case 'P2003': {
        statusCode = HttpStatus.BAD_REQUEST;
        message = 'Foreign key constraint failed';
        break;
      }
      default:
        message = `Database error: ${exception.message}`;
        break;
    }

    response.status(statusCode).json({
      success: false,
      message,
      errors,
      statusCode,
    });
  }
}
