import { Injectable, NotFoundException, BadRequestException, ConflictException } from '@nestjs/common';
import { IProductShippingRepository } from '../interfaces/product-shipping-repository.interface';
import { ProductsService } from './products.service';
import { CreateShippingDto } from '../dto/create-shipping.dto';
import { UpdateShippingDto } from '../dto/update-shipping.dto';
import { ShippingResponseDto } from '../dto/shipping-response.dto';
import { ProductShippingEntity } from '../entities/product-shipping.entity';

@Injectable()
export class ProductShippingService {
  constructor(
    private readonly shippingRepository: IProductShippingRepository,
    private readonly productsService: ProductsService,
  ) {}

  private mapToResponseDto(entity: ProductShippingEntity): ShippingResponseDto {
    const minDays = entity.estimatedDeliveryMinDays ?? 3;
    const maxDays = entity.estimatedDeliveryMaxDays ?? 7;
    const estimatedDeliveryLabel = minDays === maxDays ? `${minDays} Days` : `${minDays}-${maxDays} Days`;

    return new ShippingResponseDto({
      id: entity.id,
      productId: entity.productId,
      weight: entity.weight,
      weightUnit: entity.weightUnit,
      length: entity.length,
      width: entity.width,
      height: entity.height,
      dimensionUnit: entity.dimensionUnit,
      shippingCharge: entity.shippingCharge,
      isFreeShipping: entity.isFreeShipping,
      freeShippingAboveAmount: entity.freeShippingAboveAmount,
      estimatedDeliveryMinDays: minDays,
      estimatedDeliveryMaxDays: maxDays,
      estimatedDeliveryLabel,
      codAvailable: entity.codAvailable,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    });
  }

  private validateShippingValues(dto: Partial<CreateShippingDto>, existing?: ProductShippingEntity) {
    const weight = dto.weight ?? existing?.weight ?? 0;
    const length = dto.length ?? existing?.length ?? 0;
    const width = dto.width ?? existing?.width ?? 0;
    const height = dto.height ?? existing?.height ?? 0;
    const shippingCharge = dto.shippingCharge ?? existing?.shippingCharge ?? 0;
    const freeShippingAbove = dto.freeShippingAboveAmount ?? existing?.freeShippingAboveAmount;
    const minDays = dto.estimatedDeliveryMinDays ?? existing?.estimatedDeliveryMinDays ?? 3;
    const maxDays = dto.estimatedDeliveryMaxDays ?? existing?.estimatedDeliveryMaxDays ?? 7;

    if (weight < 0) throw new BadRequestException('Weight cannot be negative.');
    if (length < 0) throw new BadRequestException('Length cannot be negative.');
    if (width < 0) throw new BadRequestException('Width cannot be negative.');
    if (height < 0) throw new BadRequestException('Height cannot be negative.');
    if (shippingCharge < 0) throw new BadRequestException('Shipping charge cannot be negative.');
    if (freeShippingAbove !== undefined && freeShippingAbove !== null && freeShippingAbove < 0) {
      throw new BadRequestException('Minimum free shipping amount cannot be negative.');
    }
    if (minDays < 1) throw new BadRequestException('Minimum delivery days must be at least 1.');
    if (maxDays < minDays) {
      throw new BadRequestException('Maximum estimated delivery days cannot be less than minimum delivery days.');
    }
  }

  async createShipping(productId: string, vendorId: string, dto: CreateShippingDto): Promise<ShippingResponseDto> {
    // Validate Product ownership
    await this.productsService.findOneByVendor(productId, vendorId);

    const existing = await this.shippingRepository.findByProductId(productId);
    if (existing) {
      throw new ConflictException(`Shipping configuration already exists for product "${productId}". Use PUT to update.`);
    }

    this.validateShippingValues(dto);

    const created = await this.shippingRepository.create(productId, dto);
    return this.mapToResponseDto(created);
  }

  async getShipping(productId: string, vendorId: string): Promise<ShippingResponseDto> {
    // Validate Product ownership
    await this.productsService.findOneByVendor(productId, vendorId);

    const shipping = await this.shippingRepository.findByProductId(productId);
    if (!shipping) {
      throw new NotFoundException(`Shipping configuration for product "${productId}" not found.`);
    }

    return this.mapToResponseDto(shipping);
  }

  async updateShipping(productId: string, vendorId: string, dto: UpdateShippingDto): Promise<ShippingResponseDto> {
    // Validate Product ownership
    await this.productsService.findOneByVendor(productId, vendorId);

    const existing = await this.shippingRepository.findByProductId(productId);
    this.validateShippingValues(dto, existing ?? undefined);

    const updated = await this.shippingRepository.upsert(productId, dto);
    return this.mapToResponseDto(updated);
  }
}
