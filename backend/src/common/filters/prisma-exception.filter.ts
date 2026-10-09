import { ExceptionFilter, Catch, ArgumentsHost, HttpStatus } from '@nestjs/common';
import { Response } from 'express';
import { Prisma } from '@prisma/client';

@Catch(Prisma.PrismaClientKnownRequestError)
export class PrismaExceptionFilter implements ExceptionFilter {
  catch(exception: Prisma.PrismaClientKnownRequestError, host: ArgumentsHost) {
    const ctx = host.switchToHttp();
    const response = ctx.getResponse<Response>();
    const isProduction = process.env.NODE_ENV === 'production';

    let statusCode = HttpStatus.BAD_REQUEST;
    let message = 'Database operation failed';
    const errors: string[] = [];

    console.error('[PrismaExceptionFilter]', {
      code: exception.code,
      message: exception.message,
      meta: exception.meta,
    });

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
        const fieldName = (exception.meta?.field_name as string) || (exception.meta?.constraint as string) || '';
        message = fieldName.includes('category')
          ? 'Selected Category or Sub Category is invalid or does not exist.'
          : fieldName.includes('brand')
          ? 'Selected Brand is invalid or does not exist.'
          : 'Foreign key constraint failed. Related record does not exist.';
        errors.push(message);
        break;
      }
      case 'P2011':
      case 'P2012': {
        statusCode = HttpStatus.BAD_REQUEST;
        message = 'Missing required field in database operation.';
        break;
      }
      default:
        message = isProduction
          ? 'An unexpected database error occurred'
          : `Database error: ${exception.message}`;
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
