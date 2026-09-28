import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../../../database/prisma.service';
import { UpdateVendorProfileDto } from '../dto/update-vendor-profile.dto';
import { KYCStatus } from '@prisma/client';

@Injectable()
export class VendorProfileService {
  constructor(private readonly prisma: PrismaService) {}

  async getProfile(vendorId: string) {
    const user = await this.prisma.user.findUnique({
      where: { id: vendorId },
      include: { vendorProfile: true },
    });

    if (!user) {
      throw new NotFoundException('Vendor user not found');
    }

    return {
      userId: user.id,
      fullName: user.fullName,
      email: user.email,
      phoneNumber: user.phoneNumber,
      status: user.status,
      kycStatus: user.kycStatus,
      profile: user.vendorProfile || {
        storeName: user.fullName,
        legalName: null,
        businessType: 'Individual Seller',
        businessDescription: null,
        panNumber: null,
        panCardUrl: null,
        gstNumber: null,
        gstCertificateUrl: null,
        pickupAddressLine1: null,
        pickupAddressLine2: null,
        pickupCity: null,
        pickupState: null,
        pickupPincode: null,
        pickupContactPhone: user.phoneNumber,
        bankAccountHolderName: null,
        bankAccountNumber: null,
        bankIfscCode: null,
        bankName: null,
        bankAccountType: 'CURRENT',
        cancelledChequeUrl: null,
        digitalSignatureUrl: null,
      },
    };
  }

  async updateProfile(vendorId: string, dto: UpdateVendorProfileDto) {
    const user = await this.prisma.user.findUnique({
      where: { id: vendorId },
      include: { vendorProfile: true },
    });

    if (!user) {
      throw new NotFoundException('Vendor user not found');
    }

    // Determine new KYC status: If PAN/GST or bank details are provided and not already verified, mark PENDING review
    let nextKycStatus = user.kycStatus;
    const hasKycInfo = !!(
      dto.panNumber ||
      dto.gstNumber ||
      dto.bankAccountNumber ||
      user.vendorProfile?.panNumber ||
      user.vendorProfile?.bankAccountNumber
    );

    if (user.kycStatus === KYCStatus.NOT_SUBMITTED && hasKycInfo) {
      nextKycStatus = KYCStatus.PENDING;
    }

    // Upsert vendor profile
    const profile = await this.prisma.vendorProfile.upsert({
      where: { userId: vendorId },
      create: {
        userId: vendorId,
        storeName: dto.storeName || user.fullName,
        legalName: dto.legalName,
        businessType: dto.businessType || 'Individual Seller',
        businessDescription: dto.businessDescription,
        panNumber: dto.panNumber,
        panCardUrl: dto.panCardUrl,
        gstNumber: dto.gstNumber,
        gstCertificateUrl: dto.gstCertificateUrl,
        pickupAddressLine1: dto.pickupAddressLine1,
        pickupAddressLine2: dto.pickupAddressLine2,
        pickupCity: dto.pickupCity,
        pickupState: dto.pickupState,
        pickupPincode: dto.pickupPincode,
        pickupContactPhone: dto.pickupContactPhone || user.phoneNumber,
        bankAccountHolderName: dto.bankAccountHolderName,
        bankAccountNumber: dto.bankAccountNumber,
        bankIfscCode: dto.bankIfscCode,
        bankName: dto.bankName,
        bankAccountType: dto.bankAccountType || 'CURRENT',
        cancelledChequeUrl: dto.cancelledChequeUrl,
        digitalSignatureUrl: dto.digitalSignatureUrl,
      },
      update: {
        ...(dto.storeName && { storeName: dto.storeName }),
        ...(dto.legalName !== undefined && { legalName: dto.legalName }),
        ...(dto.businessType && { businessType: dto.businessType }),
        ...(dto.businessDescription !== undefined && { businessDescription: dto.businessDescription }),
        ...(dto.panNumber !== undefined && { panNumber: dto.panNumber }),
        ...(dto.panCardUrl !== undefined && { panCardUrl: dto.panCardUrl }),
        ...(dto.gstNumber !== undefined && { gstNumber: dto.gstNumber }),
        ...(dto.gstCertificateUrl !== undefined && { gstCertificateUrl: dto.gstCertificateUrl }),
        ...(dto.pickupAddressLine1 !== undefined && { pickupAddressLine1: dto.pickupAddressLine1 }),
        ...(dto.pickupAddressLine2 !== undefined && { pickupAddressLine2: dto.pickupAddressLine2 }),
        ...(dto.pickupCity !== undefined && { pickupCity: dto.pickupCity }),
        ...(dto.pickupState !== undefined && { pickupState: dto.pickupState }),
        ...(dto.pickupPincode !== undefined && { pickupPincode: dto.pickupPincode }),
        ...(dto.pickupContactPhone !== undefined && { pickupContactPhone: dto.pickupContactPhone }),
        ...(dto.bankAccountHolderName !== undefined && { bankAccountHolderName: dto.bankAccountHolderName }),
        ...(dto.bankAccountNumber !== undefined && { bankAccountNumber: dto.bankAccountNumber }),
        ...(dto.bankIfscCode !== undefined && { bankIfscCode: dto.bankIfscCode }),
        ...(dto.bankName !== undefined && { bankName: dto.bankName }),
        ...(dto.bankAccountType !== undefined && { bankAccountType: dto.bankAccountType }),
        ...(dto.cancelledChequeUrl !== undefined && { cancelledChequeUrl: dto.cancelledChequeUrl }),
        ...(dto.digitalSignatureUrl !== undefined && { digitalSignatureUrl: dto.digitalSignatureUrl }),
      },
    });

    if (nextKycStatus !== user.kycStatus) {
      await this.prisma.user.update({
        where: { id: vendorId },
        data: { kycStatus: nextKycStatus },
      });
    }

    return {
      userId: user.id,
      fullName: user.fullName,
      email: user.email,
      phoneNumber: user.phoneNumber,
      status: user.status,
      kycStatus: nextKycStatus,
      profile,
    };
  }
}
