import { Injectable, UnauthorizedException, ConflictException, ForbiddenException } from '@nestjs/common';
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
      this.configService.get<string>('JWT_SECRET') ||
      'super-secret-access-token-key-change-in-production';

    const refreshSecret =
      this.configService.get<string>('jwt.refreshSecret') ||
      this.configService.get<string>('JWT_REFRESH_SECRET') ||
      'super-secret-refresh-token-key-change-in-production';

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
}
