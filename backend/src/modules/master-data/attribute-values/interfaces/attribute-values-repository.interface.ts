import { AttributeValueEntity } from '../entities/attribute-value.entity';
import { CreateAttributeValueDto } from '../dto/create-attribute-value.dto';
import { UpdateAttributeValueDto } from '../dto/update-attribute-value.dto';

export abstract class IAttributeValuesRepository {
  abstract create(data: CreateAttributeValueDto, userId: string): Promise<AttributeValueEntity>;
  abstract findMany(attributeId?: string): Promise<AttributeValueEntity[]>;
  abstract findById(id: string): Promise<AttributeValueEntity | null>;
  abstract findByValueAndAttribute(value: string, attributeId: string): Promise<AttributeValueEntity | null>;
  abstract update(id: string, data: UpdateAttributeValueDto, userId: string): Promise<AttributeValueEntity>;
  abstract softDelete(id: string, userId: string): Promise<AttributeValueEntity>;
}
