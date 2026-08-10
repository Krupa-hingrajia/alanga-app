import { Injectable, NestInterceptor, ExecutionContext, CallHandler } from '@nestjs/common';
import { Observable } from 'rxjs';
import { map } from 'rxjs/operators';

export interface Response<T> {
  success: boolean;
  message: string;
  data: T;
  statusCode: number;
}

@Injectable()
export class TransformInterceptor<T> implements NestInterceptor<T, Response<T>> {
  intercept(context: ExecutionContext, next: CallHandler): Observable<Response<T>> {
    const ctx = context.switchToHttp();
    const response = ctx.getResponse();
    
    return next.handle().pipe(
      map((data) => {
        const statusCode = response.statusCode || 200;
        
        // If data is already in standard format, return as is
        if (data && typeof data === 'object' && 'success' in data && 'statusCode' in data) {
          return data;
        }

        let message = 'Operation completed successfully';
        let responseData = data;

        // Extract custom message if returned from the service/controller
        if (data && typeof data === 'object' && ('message' in data || 'data' in data)) {
          message = data.message !== undefined ? data.message : message;
          responseData = data.data !== undefined ? data.data : data;
        }

        return {
          success: true,
          message,
          data: responseData ?? {},
          statusCode,
        };
      }),
    );
  }
}
