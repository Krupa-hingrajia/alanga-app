import { Injectable, UnauthorizedException, ConflictException, ForbiddenException } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { ConfigService } from '@nestjs/config';
import { IAuthRepository } from '../interfaces/auth-repository.interface';
import { RegisterDto } from '../dto/register.dto';
import { LoginDto } from '../dto/login.dto';
import { UserEntity } from '../../users/entities/user.entity';
import * as bcrypt from 'bcrypt';
import { Role, UserStatus } from '@prisma/client';

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

    const existingPhone = await this.authRepository.findUserByMobile(registerDto.mobileNumber);
    if (existingPhone) {
      throw new ConflictException('Mobile number is already registered');
    }

    const saltRounds = 10;
    const hashedPassword = await bcrypt.hash(registerDto.password, saltRounds);

    const role = registerDto.role;
    const status = role === Role.VENDOR ? UserStatus.PENDING : UserStatus.ACTIVE;

    return this.authRepository.createUser({
      fullName: registerDto.fullName,
      email: registerDto.email,
      countryCode: registerDto.countryCode,
      mobileNumber: registerDto.mobileNumber,
      password: hashedPassword,
      role: registerDto.role,
      status: status,
      businessName: registerDto.businessName,
      businessType: registerDto.businessType,
      city: registerDto.city,
      state: registerDto.state,
      pincode: registerDto.pincode,
      gstNumber: registerDto.gstNumber,
      panNumber: registerDto.panNumber,
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

    if (!user || !user.password) {
      throw new UnauthorizedException('Invalid credentials');
    }

    const isPasswordValid = await bcrypt.compare(password, user.password);
    if (!isPasswordValid) {
      throw new UnauthorizedException('Invalid credentials');
    }

    // Check status if vendor
    if (user.role === Role.VENDOR && user.status !== UserStatus.ACTIVE) {
      if (user.status === UserStatus.PENDING) {
        throw new ForbiddenException('Your account is under verification.');
      } else if (user.status === UserStatus.REJECTED) {
        throw new ForbiddenException(
          'Your registration was rejected. Please update your information and submit again.',
        );
      } else if (user.status === UserStatus.SUSPENDED) {
        throw new ForbiddenException('Your account has been suspended. Please contact support.');
      }
    }

    const tokens = await this.generateTokens(user.id, user.email, user.role);
    await this.updateRefreshToken(user.id, tokens.refreshToken);

    return {
      user,
      ...tokens,
    };
  }

  async refresh(userId: string, email: string, role: string) {
    const tokens = await this.generateTokens(userId, email, role);
    await this.updateRefreshToken(userId, tokens.refreshToken);
    return tokens;
  }

  async logout(userId: string) {
    await this.authRepository.updateRefreshToken(userId, null);
  }

  private async generateTokens(userId: string, email: string, role: string) {
    const payload = { sub: userId, email, role };

    const [accessToken, refreshToken] = await Promise.all([
      this.jwtService.signAsync(payload, {
        secret: this.configService.get<string>('jwt.accessSecret') || 'fallback-access-secret',
        expiresIn: (this.configService.get<string>('jwt.accessExpiration') || '15m') as any,
      }),
      this.jwtService.signAsync(payload, {
        secret: this.configService.get<string>('jwt.refreshSecret') || 'fallback-refresh-secret',
        expiresIn: (this.configService.get<string>('jwt.refreshExpiration') || '7d') as any,
      }),
    ]);

    return {
      accessToken,
      refreshToken,
    };
  }

  private async updateRefreshToken(userId: string, refreshToken: string) {
    const saltRounds = 10;
    const hashedToken = await bcrypt.hash(refreshToken, saltRounds);
    await this.authRepository.updateRefreshToken(userId, hashedToken);
  }
}
