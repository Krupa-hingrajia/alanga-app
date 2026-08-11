import { Controller, Post, Body, Get, UseGuards, HttpCode, HttpStatus, ForbiddenException } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiResponse, ApiBearerAuth } from '@nestjs/swagger';
import { AuthService } from '../auth/services/auth.service';
import { LoginDto } from '../auth/dto/login.dto';
import { RefreshTokenDto } from '../auth/dto/refresh-token.dto';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { JwtRefreshGuard } from '../auth/guards/jwt-refresh.guard';
import { RolesGuard } from '../../common/guards/roles.guard';
import { Roles } from '../../common/decorators/roles.decorator';
import { CurrentUser } from '../../common/decorators/current-user.decorator';
import { Role } from '@prisma/client';

@ApiTags('Admin Authentication')
@Controller('admin/auth')
export class AdminAuthController {
  constructor(private readonly authService: AuthService) {}

  @Post('login')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Admin login', description: 'Authenticates an administrator using email/password or mobile/password.' })
  @ApiResponse({ status: 200, description: 'Admin successfully authenticated' })
  @ApiResponse({ status: 401, description: 'Invalid credentials' })
  @ApiResponse({ status: 403, description: 'Access denied. Administrator privileges required.' })
  async login(@Body() loginDto: LoginDto) {
    const result = await this.authService.login(loginDto);
    if (result.user.role !== Role.ADMIN) {
      throw new ForbiddenException('Access denied. Administrator privileges required.');
    }
    return {
      success: true,
      message: 'Admin login successful',
      data: result,
      statusCode: HttpStatus.OK,
    };
  }

  @Get('profile')
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles(Role.ADMIN)
  @ApiBearerAuth('access-token')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Get admin profile', description: 'Retrieves details of the currently authenticated administrator.' })
  @ApiResponse({ status: 200, description: 'Profile retrieved successfully' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  @ApiResponse({ status: 403, description: 'Access denied. Administrator privileges required.' })
  async getProfile(@CurrentUser() admin: any) {
    return {
      success: true,
      message: 'Admin profile retrieved successfully',
      data: admin,
      statusCode: HttpStatus.OK,
    };
  }

  @Post('logout')
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles(Role.ADMIN)
  @ApiBearerAuth('access-token')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Admin logout', description: 'Revokes the admin refresh token and invalidates session.' })
  @ApiResponse({ status: 200, description: 'Logout successful' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  async logout(@CurrentUser('id') adminId: string) {
    await this.authService.logout(adminId);
    return {
      success: true,
      message: 'Admin logout successful',
      data: {},
      statusCode: HttpStatus.OK,
    };
  }

  @Post('refresh')
  @UseGuards(JwtRefreshGuard)
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Refresh admin tokens', description: 'Generates new tokens using a valid refresh token.' })
  @ApiResponse({ status: 200, description: 'Tokens successfully refreshed' })
  @ApiResponse({ status: 401, description: 'Invalid refresh token' })
  @ApiResponse({ status: 403, description: 'Access denied. Administrator privileges required.' })
  async refresh(@CurrentUser() user: any, @Body() refreshTokenDto: RefreshTokenDto) {
    if (user.role !== Role.ADMIN) {
      throw new ForbiddenException('Access denied. Administrator privileges required.');
    }
    const result = await this.authService.refresh(user.id, user.email, user.role);
    return {
      success: true,
      message: 'Tokens refreshed successfully',
      data: result,
      statusCode: HttpStatus.OK,
    };
  }
}
