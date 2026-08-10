import { ExceptionFilter, Catch, ArgumentsHost, HttpException } from '@nestjs/common';
import { Response } from 'express';

@Catch(HttpException)
export class HttpExceptionFilter implements ExceptionFilter {
  catch(exception: HttpException, host: ArgumentsHost) {
    const ctx = host.switchToHttp();
    const response = ctx.getResponse<Response>();
    const statusCode = exception.getStatus();
    const exceptionResponse = exception.getResponse();

    let message = exception.message;
    let errors: any[] = [];

    if (typeof exceptionResponse === 'object' && exceptionResponse !== null) {
      const responseObj = exceptionResponse as any;
      if (Array.isArray(responseObj.message)) {
        errors = responseObj.message;
        message = 'Validation failed';
      } else {
        message = responseObj.message || exception.message;
      }
    }

    response.status(statusCode).json({
      success: false,
      message,
      errors,
      statusCode,
    });
  }
}
