import { ApiPropertyOptional } from '@nestjs/swagger';
import { IsInt, Min, IsOptional, IsEnum } from 'class-validator';

export enum CartUpdateAction {
  INCREASE = 'increase',
  DECREASE = 'decrease',
}

export class UpdateCartItemDto {
  @ApiPropertyOptional({ description: 'Exact new quantity', example: 2 })
  @IsInt()
  @Min(0)
  @IsOptional()
  quantity?: number;

  @ApiPropertyOptional({ description: 'Action to perform: increase or decrease', enum: CartUpdateAction })
  @IsEnum(CartUpdateAction)
  @IsOptional()
  action?: CartUpdateAction;
}
