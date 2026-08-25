import {
  Injectable,
  NotFoundException,
  ForbiddenException,
  BadRequestException,
} from '@nestjs/common';
import { IProductImagesRepository } from '../interfaces/product-images-repository.interface';
import { IProductsRepository } from '../interfaces/products-repository.interface';
import { ProductImageEntity } from '../entities/product-image.entity';
import { ReorderProductImagesDto } from '../dto/reorder-product-images.dto';

const ALLOWED_MIME_TYPES = ['image/jpeg', 'image/jpg', 'image/png', 'image/webp'];
const ALLOWED_EXTENSIONS = ['.jpg', '.jpeg', '.png', '.webp'];
const MAX_FILE_SIZE_BYTES = 5 * 1024 * 1024; // 5 MB
const MAX_IMAGES_PER_PRODUCT = 10;

@Injectable()
export class ProductImagesService {
  constructor(
    private readonly productImagesRepository: IProductImagesRepository,
    private readonly productsRepository: IProductsRepository,
  ) {}

  private async verifyVendorOwnership(productId: string, vendorId: string) {
    const product = await this.productsRepository.findById(productId);
    if (!product) {
      throw new NotFoundException(`Product with ID "${productId}" not found.`);
    }
    if (product.createdByVendorId !== vendorId && product.vendorId !== vendorId) {
      throw new ForbiddenException('Access denied. You do not own this product.');
    }
    return product;
  }

  async uploadImages(
    productId: string,
    vendorId: string,
    files?: Express.Multer.File[],
    imageUrls?: string[],
    productVariantId?: string,
  ): Promise<ProductImageEntity[]> {
    await this.verifyVendorOwnership(productId, vendorId);

    const fileList = files || [];
    const urlList = imageUrls || [];
    const totalIncoming = fileList.length + urlList.length;

    if (totalIncoming === 0) {
      throw new BadRequestException('At least one image file or image URL must be provided.');
    }

    // Validate each file
    for (const file of fileList) {
      const ext = file.originalname ? file.originalname.substring(file.originalname.lastIndexOf('.')).toLowerCase() : '';
      const isMimeValid = ALLOWED_MIME_TYPES.includes(file.mimetype);
      const isExtValid = ALLOWED_EXTENSIONS.includes(ext);

      if (!isMimeValid && !isExtValid) {
        throw new BadRequestException(
          `Unsupported image format for "${file.originalname}". Allowed formats are JPG, JPEG, PNG, and WEBP.`,
        );
      }

      if (file.size > MAX_FILE_SIZE_BYTES) {
        throw new BadRequestException(
          `Image "${file.originalname}" exceeds maximum allowed size of 5 MB.`,
        );
      }
    }

    // Check maximum image limit per product/variant
    const activeCount = await this.productImagesRepository.countActiveByProductId(productId, productVariantId);
    if (activeCount + totalIncoming > MAX_IMAGES_PER_PRODUCT) {
      throw new BadRequestException(
        `Cannot upload images. Maximum ${MAX_IMAGES_PER_PRODUCT} images allowed per gallery. Currently has ${activeCount} image(s).`,
      );
    }

    const currentMaxOrder = await this.productImagesRepository.getMaxDisplayOrder(productId, productVariantId);
    let nextDisplayOrder = currentMaxOrder > 0 || activeCount > 0 ? currentMaxOrder + 1 : 0;
    const shouldSetFirstAsPrimary = activeCount === 0;

    const imagesToCreate: Array<{ imageUrl: string; isPrimary: boolean; displayOrder: number; productVariantId?: string | null }> = [];

    // Process file uploads
    fileList.forEach((file, index) => {
      const isPrimary = shouldSetFirstAsPrimary && index === 0 && imagesToCreate.length === 0;
      const imageUrl = file.path ? `/uploads/products/${file.filename}` : `/uploads/products/${file.originalname}`;
      imagesToCreate.push({
        imageUrl,
        isPrimary,
        displayOrder: nextDisplayOrder++,
        productVariantId: productVariantId || null,
      });
    });

    // Process URL inputs
    urlList.forEach((url) => {
      const isPrimary = shouldSetFirstAsPrimary && imagesToCreate.length === 0;
      imagesToCreate.push({
        imageUrl: url,
        isPrimary,
        displayOrder: nextDisplayOrder++,
        productVariantId: productVariantId || null,
      });
    });

    const createdImages = await this.productImagesRepository.createMany(productId, imagesToCreate, productVariantId);

    // Sync primary image to product.image field if main product image
    if (!productVariantId) {
      const primaryImg = createdImages?.find((img) => img.isPrimary);
      if (primaryImg) {
        await this.productsRepository.update(productId, { image: primaryImg.imageUrl }, vendorId);
      }
    }

    return createdImages;
  }

  async getProductImages(productId: string, vendorId: string, productVariantId?: string): Promise<ProductImageEntity[]> {
    await this.verifyVendorOwnership(productId, vendorId);
    return this.productImagesRepository.findByProductId(productId, productVariantId);
  }

  async setPrimaryImage(
    productId: string,
    imageId: string,
    vendorId: string,
    productVariantId?: string,
  ): Promise<ProductImageEntity> {
    await this.verifyVendorOwnership(productId, vendorId);

    const image = await this.productImagesRepository.findById(imageId);
    if (!image || image.productId !== productId) {
      throw new NotFoundException(`Product image with ID "${imageId}" not found.`);
    }

    const updatedImage = await this.productImagesRepository.setPrimaryImage(productId, imageId, productVariantId);
    if (!productVariantId) {
      await this.productsRepository.update(productId, { image: updatedImage.imageUrl }, vendorId);
    }
    return updatedImage;
  }

  async deleteImage(
    productId: string,
    imageId: string,
    vendorId: string,
  ): Promise<{ message: string }> {
    await this.verifyVendorOwnership(productId, vendorId);

    const image = await this.productImagesRepository.findById(imageId);
    if (!image || image.productId !== productId) {
      throw new NotFoundException(`Product image with ID "${imageId}" not found.`);
    }

    const wasPrimary = image.isPrimary;
    const variantId = image.productVariantId || undefined;

    await this.productImagesRepository.softDelete(imageId);

    // If primary image was deleted, automatically make the next available image the Primary Image
    if (wasPrimary) {
      const nextImage = await this.productImagesRepository.findFirstAvailable(productId, variantId);
      if (nextImage) {
        await this.productImagesRepository.setPrimaryImage(productId, nextImage.id, variantId);
        if (!variantId) {
          await this.productsRepository.update(productId, { image: nextImage.imageUrl }, vendorId);
        }
      } else if (!variantId) {
        await this.productsRepository.update(productId, { image: null }, vendorId);
      }
    }

    return { message: 'Product image deleted successfully.' };
  }

  async reorderImages(
    productId: string,
    reorderDto: ReorderProductImagesDto,
    vendorId: string,
  ): Promise<ProductImageEntity[]> {
    await this.verifyVendorOwnership(productId, vendorId);

    const existingImages = await this.productImagesRepository.findByProductId(productId);
    const existingIds = new Set(existingImages.map((img) => img.id));

    for (const item of reorderDto.images) {
      if (!existingIds.has(item.id)) {
        throw new BadRequestException(
          `Image ID "${item.id}" does not belong to product "${productId}".`,
        );
      }
    }

    return this.productImagesRepository.updateDisplayOrders(productId, reorderDto.images);
  }
}
