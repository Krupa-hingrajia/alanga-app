import { Injectable, UnauthorizedException } from '@nestjs/common';
import { PassportStrategy } from '@nestjs/passport';
import { ExtractJwt, Strategy } from 'passport-jwt';
import { ConfigService } from '@nestjs/config';
import { Request } from 'express';
import { UsersService } from '../../users/services/users.service';

@Injectable()
export class JwtRefreshStrategy extends PassportStrategy(Strategy, 'jwt-refresh') {
  constructor(
    private readonly configService: ConfigService,
    private readonly usersService: UsersService,
  ) {
    const refreshSecret =
      configService.get<string>('jwt.refreshSecret') ||
      configService.get<string>('JWT_REFRESH_SECRET');

    if (!refreshSecret) {
      throw new Error('JWT refresh secret is not configured.');
    }

    super({
      jwtFromRequest: ExtractJwt.fromExtractors([
        ExtractJwt.fromAuthHeaderAsBearerToken(),
        (req: Request) => {
          return req?.body?.refreshToken || null;
        },
      ]),
      ignoreExpiration: false,
      secretOrKey: refreshSecret,
      passReqToCallback: true,
    });
  }

  async validate(req: Request, payload: { sub: string; email: string; role: string }) {
    const refreshToken =
      req.get('Authorization')?.replace('Bearer ', '').trim() ||
      (req.body && req.body.refreshToken);

    if (!refreshToken) {
      throw new UnauthorizedException('Refresh token is required');
    }

    const user = await this.usersService.findById(payload.sub);
    if (!user) {
      throw new UnauthorizedException('Access denied. Invalid or expired session.');
    }

    return user;
  }
}
