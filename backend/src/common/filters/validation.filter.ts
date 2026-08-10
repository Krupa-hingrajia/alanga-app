import { ExceptionFilter, Catch, ArgumentsHost } from '@nestjs/common';
import { Response } from 'express';
import { ValidationException } from '../exceptions/validation.exception';

@Catch(ValidationException)
export class ValidationFilter implements ExceptionFilter {
  catch(exception: ValidationException, host: ArgumentsHost) {
    const ctx = host.switchToHttp();
    const response = ctx.getResponse<Response>();
    
    const errors: any[] = [];
    
    const formatErrors = (validationErrors: any[]) => {
      for (const error of validationErrors) {
        if (error.constraints) {
          errors.push({
            field: error.property,
            messages: Object.values(error.constraints),
          });
        }
        if (error.children && error.children.length > 0) {
          formatErrors(error.children);
        }
      }
    };
    
    formatErrors(exception.validationErrors);

    response.status(400).json({
      success: false,
      message: 'Validation failed',
      errors,
      statusCode: 400,
    });
  }
}
