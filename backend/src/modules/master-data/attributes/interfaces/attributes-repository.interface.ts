import { ProductAttributeEntity } from '../entities/attribute.entity';
import { CreateAttributeDto } from '../dto/create-attribute.dto';
import { UpdateAttributeDto } from '../dto/update-attribute.dto';

export abstract class IAttributesRepository {
  abstract create(data: CreateAttributeDto, userId: string): Promise<ProductAttributeEntity>;
  abstract findMany(): Promise<ProductAttributeEntity[]>;
  abstract findById(id: string): Promise<ProductAttributeEntity | null>;
  abstract findByName(name: string): Promise<ProductAttributeEntity | null>;
  abstract update(id: string, data: UpdateAttributeDto, userId: string): Promise<ProductAttributeEntity>;
  abstract softDelete(id: string, userId: string): Promise<ProductAttributeEntity>;
}
