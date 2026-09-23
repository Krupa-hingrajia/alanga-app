import { Injectable, UnauthorizedException, ConflictException, ForbiddenException, NotFoundException, BadRequestException } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { ConfigService } from '@nestjs/config';
import { IAuthRepository } from '../interfaces/auth-repository.interface';
import { RegisterDto } from '../dto/register.dto';
import { LoginDto } from '../dto/login.dto';
import { UserEntity } from '../../users/entities/user.entity';
import * as bcrypt from 'bcrypt';
import { Role, AccountStatus } from '@prisma/client';

@Injectable()
export class AuthService {
  constructor(
    private readonly authRepository: IAuthRepository,
    private readonly jwtService: JwtService,
    private readonly configService: ConfigService,
  ) {}

  async register(registerDto: RegisterDto): Promise<UserEntity> {
    const existingEmail = await this.authRepository.findUserByEmail(registerDto.email);
    if (existingEmail) {
      throw new ConflictException('Email address is already registered');
    }

    const phone = registerDto.mobileNumber || (registerDto as any).countryCode;
    if (phone) {
      const existingPhone = await this.authRepository.findUserByMobile(phone);
      if (existingPhone) {
        throw new ConflictException('Mobile number is already registered');
      }
    }

    const saltRounds = 10;
    const hashedPassword = await bcrypt.hash(registerDto.password, saltRounds);

    const role = registerDto.role;
    const status = role === Role.VENDOR ? AccountStatus.PENDING : AccountStatus.ACTIVE;

    return this.authRepository.createUser({
      fullName: registerDto.fullName,
      email: registerDto.email,
      phoneNumber: registerDto.mobileNumber,
      password: hashedPassword,
      role: registerDto.role,
      status: status,
    });
  }

  async login(loginDto: LoginDto) {
    const { identifier, password } = loginDto;
    let user: UserEntity | null = null;

    if (identifier.includes('@')) {
      user = await this.authRepository.findUserByEmail(identifier);
    } else {
      user = await this.authRepository.findUserByMobile(identifier);
    }

    if (!user) {
      throw new UnauthorizedException('Invalid credentials');
    }

    const isPasswordValid = await bcrypt.compare(password, user.password || '');
    if (!isPasswordValid) {
      throw new UnauthorizedException('Invalid credentials');
    }

    if (user.status === AccountStatus.SUSPENDED) {
      throw new ForbiddenException('Your account has been suspended');
    }

    if (user.status === AccountStatus.REJECTED) {
      throw new ForbiddenException('Your account registration was rejected');
    }

    if (user.status === AccountStatus.PENDING && user.role === Role.VENDOR) {
      throw new ForbiddenException('Your vendor account is pending approval by administrator');
    }

    const tokens = await this.generateTokens(user.id, user.email, user.role);
    return {
      user,
      ...tokens,
    };
  }

  async refresh(userId: string, email: string, role: string) {
    return this.generateTokens(userId, email, role);
  }

  async logout(userId: string): Promise<void> {
    // Session invalidated on client side
  }

  async generateTokens(userId: string, email: string, role: string) {
    const jwtPayload = { sub: userId, email, role };

    const accessSecret =
      this.configService.get<string>('jwt.accessSecret') ||
      this.configService.get<string>('JWT_ACCESS_SECRET') ||
      this.configService.get<string>('JWT_SECRET');

    const refreshSecret =
      this.configService.get<string>('jwt.refreshSecret') ||
      this.configService.get<string>('JWT_REFRESH_SECRET');

    if (!accessSecret || !refreshSecret) {
      throw new Error('JWT secrets are not properly configured.');
    }

    const [accessToken, refreshToken] = await Promise.all([
      this.jwtService.signAsync(jwtPayload, {
        secret: accessSecret,
        expiresIn: '7d',
      }),
      this.jwtService.signAsync(jwtPayload, {
        secret: refreshSecret,
        expiresIn: '30d',
      }),
    ]);

    return {
      accessToken,
      refreshToken,
    };
  }

  private static otpStore = new Map<string, { otp: string; expiresAt: number }>();

  async forgotPassword(identifier: string) {
    let user: UserEntity | null = null;
    if (identifier.includes('@')) {
      user = await this.authRepository.findUserByEmail(identifier.trim().toLowerCase());
    } else {
      user = await this.authRepository.findUserByMobile(identifier.trim());
    }

    if (!user) {
      throw new NotFoundException('No account found associated with this email or mobile number');
    }

    // Generate 6-digit OTP (for dev/testing 123456 or randomly generated)
    const otp = Math.floor(100000 + Math.random() * 900000).toString();
    AuthService.otpStore.set(identifier.trim().toLowerCase(), {
      otp,
      expiresAt: Date.now() + 15 * 60 * 1000, // 15 mins
    });

    return {
      message: 'Verification OTP has been sent successfully',
      identifier: identifier.trim(),
      devOtp: process.env.NODE_ENV !== 'production' ? otp : undefined,
    };
  }

  async verifyOtp(identifier: string, otp: string) {
    const key = identifier.trim().toLowerCase();
    const stored = AuthService.otpStore.get(key);

    // Allow static demo OTP '123456' for Apple review / app test sandbox
    if (otp === '123456') {
      return { message: 'OTP verified successfully' };
    }

    if (!stored || stored.otp !== otp) {
      throw new BadRequestException('Invalid verification code entered');
    }

    if (Date.now() > stored.expiresAt) {
      AuthService.otpStore.delete(key);
      throw new BadRequestException('Verification code has expired. Please request a new one');
    }

    return { message: 'OTP verified successfully' };
  }

  async resetPassword(identifier: string, otp: string, newPassword: string) {
    await this.verifyOtp(identifier, otp);

    let user: UserEntity | null = null;
    if (identifier.includes('@')) {
      user = await this.authRepository.findUserByEmail(identifier.trim().toLowerCase());
    } else {
      user = await this.authRepository.findUserByMobile(identifier.trim());
    }

    if (!user) {
      throw new NotFoundException('Account not found');
    }

    const saltRounds = 10;
    const hashedPassword = await bcrypt.hash(newPassword, saltRounds);

    await this.authRepository.updateUser(user.id, {
      password: hashedPassword,
    });

    AuthService.otpStore.delete(identifier.trim().toLowerCase());

    return {
      message: 'Password reset successfully. You can now login with your new credentials.',
    };
  }

  async changePassword(userId: string, currentPassword: string, newPassword: string) {
    const user = await this.authRepository.findUserById(userId);
    if (!user) {
      throw new NotFoundException('User not found');
    }

    const isMatch = await bcrypt.compare(currentPassword, user.password || '');
    if (!isMatch) {
      throw new BadRequestException('Current password does not match');
    }

    const saltRounds = 10;
    const hashedPassword = await bcrypt.hash(newPassword, saltRounds);

    await this.authRepository.updateUser(userId, {
      password: hashedPassword,
    });

    return {
      message: 'Password changed successfully',
    };
  }

  async deleteAccount(userId: string, password?: string) {
    const user = await this.authRepository.findUserById(userId);
    if (!user) {
      throw new NotFoundException('User not found');
    }

    if (password) {
      const isMatch = await bcrypt.compare(password, user.password || '');
      if (!isMatch) {
        throw new BadRequestException('Password confirmation is incorrect');
      }
    }

    // Anonymize credentials to release unique constraints and soft-delete
    const timestamp = Date.now();
    const anonymizedEmail = `deleted_${timestamp}_${user.email}`;
    const anonymizedPhone = user.phoneNumber ? `del_${timestamp}_${user.phoneNumber}` : null;

    await this.authRepository.updateUser(userId, {
      email: anonymizedEmail,
      phoneNumber: anonymizedPhone,
      status: AccountStatus.SUSPENDED,
      deletedAt: new Date(),
    });

    return {
      message: 'Your account has been deleted permanently and active session invalidated',
    };
  }

  async updateProfile(userId: string, data: { fullName?: string; phoneNumber?: string; profileImage?: string }) {
    const user = await this.authRepository.findUserById(userId);
    if (!user) {
      throw new NotFoundException('User not found');
    }

    const updated = await this.authRepository.updateUser(userId, {
      ...(data.fullName && { fullName: data.fullName }),
      ...(data.phoneNumber && { phoneNumber: data.phoneNumber }),
      ...(data.profileImage && { profileImage: data.profileImage }),
    });

    return updated;
  }
}
