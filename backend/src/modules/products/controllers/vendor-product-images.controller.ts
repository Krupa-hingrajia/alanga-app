import {
  Controller,
  Post,
  Get,
  Put,
  Delete,
  Param,
  Query,
  Body,
  UseGuards,
  HttpCode,
  HttpStatus,
  UseInterceptors,
  UploadedFiles,
  BadRequestException,
} from '@nestjs/common';
import { FilesInterceptor } from '@nestjs/platform-express';
import { ApiTags, ApiOperation, ApiResponse, ApiBearerAuth, ApiConsumes, ApiBody, ApiQuery } from '@nestjs/swagger';
import { memoryStorage } from 'multer';
import { extname } from 'path';
import { Role } from '@prisma/client';
import { JwtAuthGuard } from '../../auth/guards/jwt-auth.guard';
import { RolesGuard } from '../../../common/guards/roles.guard';
import { Roles } from '../../../common/decorators/roles.decorator';
import { CurrentUser } from '../../../common/decorators/current-user.decorator';
import { ProductImagesService } from '../services/product-images.service';
import { UploadProductImagesDto } from '../dto/upload-product-images.dto';
import { ReorderProductImagesDto } from '../dto/reorder-product-images.dto';
import { ProductImageResponseDto } from '../dto/product-image-response.dto';

const multerOptions = {
  storage: memoryStorage(),
  fileFilter: (req: any, file: any, cb: any) => {
    const allowedMimeTypes = ['image/jpeg', 'image/jpg', 'image/png', 'image/webp'];
    const allowedExtensions = ['.jpg', '.jpeg', '.png', '.webp'];
    const ext = extname(file.originalname || '').toLowerCase();

    if (allowedMimeTypes.includes(file.mimetype) || allowedExtensions.includes(ext) || !ext) {
      cb(null, true);
    } else {
      cb(
        new BadRequestException(
          `Unsupported file format for ${file.originalname}. Only JPG, JPEG, PNG, and WEBP are allowed.`,
        ),
        false,
      );
    }
  },
  limits: {
    fileSize: 10 * 1024 * 1024, // 10 MB
  },
};

@ApiTags('Vendor Product Images')
@ApiBearerAuth('access-token')
@UseGuards(JwtAuthGuard, RolesGuard)
@Roles(Role.VENDOR)
@Controller('vendor/products/:productId/images')
export class VendorProductImagesController {
  constructor(private readonly productImagesService: ProductImagesService) {}

  @Post()
  @HttpCode(HttpStatus.CREATED)
  @UseInterceptors(FilesInterceptor('files', 10, multerOptions))
  @ApiConsumes('multipart/form-data')
  @ApiOperation({ summary: 'Upload one or multiple product images (Vendor only)' })
  @ApiQuery({ name: 'productVariantId', required: false, type: String, description: 'Optional Product Variant UUID' })
  @ApiBody({ type: UploadProductImagesDto })
  @ApiResponse({
    status: 201,
    description: 'Product images uploaded successfully.',
    type: [ProductImageResponseDto],
  })
  @ApiResponse({ status: 400, description: 'Validation failed (file format, file size > 5MB, max 10 images limit).' })
  @ApiResponse({ status: 403, description: 'Forbidden. You do not own this product.' })
  @ApiResponse({ status: 404, description: 'Product not found.' })
  async uploadImages(
    @Param('productId') productId: string,
    @UploadedFiles() files: Express.Multer.File[],
    @Body() body: UploadProductImagesDto,
    @Query('productVariantId') productVariantIdQuery: string,
    @CurrentUser('id') vendorId: string,
  ) {
    const imageUrls = body.imageUrls
      ? Array.isArray(body.imageUrls)
        ? body.imageUrls
        : [body.imageUrls]
      : undefined;

    const variantId = body.productVariantId || productVariantIdQuery || undefined;

    const data = await this.productImagesService.uploadImages(productId, vendorId, files, imageUrls, variantId);
    return {
      success: true,
      message: 'Product images uploaded successfully',
      data,
      statusCode: HttpStatus.CREATED,
    };
  }

  @Get()
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Get all images of a product or specific variant (Vendor only)' })
  @ApiQuery({ name: 'productVariantId', required: false, type: String, description: 'Optional Product Variant UUID' })
  @ApiResponse({
    status: 200,
    description: 'Product images retrieved successfully.',
    type: [ProductImageResponseDto],
  })
  @ApiResponse({ status: 403, description: 'Forbidden. You do not own this product.' })
  @ApiResponse({ status: 404, description: 'Product not found.' })
  async getImages(
    @Param('productId') productId: string,
    @Query('productVariantId') productVariantId: string,
    @CurrentUser('id') vendorId: string,
  ) {
    const data = await this.productImagesService.getProductImages(productId, vendorId, productVariantId);
    return {
      success: true,
      message: 'Product images retrieved successfully',
      data,
      statusCode: HttpStatus.OK,
    };
  }

  @Put('reorder')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Update image display order (Vendor only)' })
  @ApiResponse({
    status: 200,
    description: 'Image display order updated successfully.',
    type: [ProductImageResponseDto],
  })
  @ApiResponse({ status: 400, description: 'Validation failed or invalid image IDs.' })
  @ApiResponse({ status: 403, description: 'Forbidden. You do not own this product.' })
  @ApiResponse({ status: 404, description: 'Product not found.' })
  async reorderImages(
    @Param('productId') productId: string,
    @Body() reorderDto: ReorderProductImagesDto,
    @CurrentUser('id') vendorId: string,
  ) {
    const data = await this.productImagesService.reorderImages(productId, reorderDto, vendorId);
    return {
      success: true,
      message: 'Image display order updated successfully',
      data,
      statusCode: HttpStatus.OK,
    };
  }

  @Put(':imageId/primary')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Set an image as the Primary Image (Vendor only)' })
  @ApiQuery({ name: 'productVariantId', required: false, type: String, description: 'Optional Product Variant UUID' })
  @ApiResponse({
    status: 200,
    description: 'Primary image updated successfully.',
    type: ProductImageResponseDto,
  })
  @ApiResponse({ status: 403, description: 'Forbidden. You do not own this product.' })
  @ApiResponse({ status: 404, description: 'Product or image not found.' })
  async setPrimary(
    @Param('productId') productId: string,
    @Param('imageId') imageId: string,
    @Query('productVariantId') productVariantId: string,
    @CurrentUser('id') vendorId: string,
  ) {
    const data = await this.productImagesService.setPrimaryImage(productId, imageId, vendorId, productVariantId);
    return {
      success: true,
      message: 'Primary image set successfully',
      data,
      statusCode: HttpStatus.OK,
    };
  }

  @Delete(':imageId')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Soft delete/remove a product image (Vendor only)' })
  @ApiResponse({ status: 200, description: 'Product image deleted successfully.' })
  @ApiResponse({ status: 403, description: 'Forbidden. You do not own this product.' })
  @ApiResponse({ status: 404, description: 'Product or image not found.' })
  async deleteImage(
    @Param('productId') productId: string,
    @Param('imageId') imageId: string,
    @CurrentUser('id') vendorId: string,
  ) {
    const data = await this.productImagesService.deleteImage(productId, imageId, vendorId);
    return {
      success: true,
      message: data.message,
      statusCode: HttpStatus.OK,
    };
  }
}
