export default () => {
  const nodeEnv = process.env.NODE_ENV || 'development';
  const isProduction = nodeEnv === 'production';

  // In production, JWT secrets must be explicitly set — no insecure fallbacks.
  const jwtAccessSecret = process.env.JWT_ACCESS_SECRET;
  const jwtRefreshSecret = process.env.JWT_REFRESH_SECRET;

  if (isProduction) {
    if (!jwtAccessSecret) {
      throw new Error('JWT_ACCESS_SECRET environment variable is required in production.');
    }
    if (!jwtRefreshSecret) {
      throw new Error('JWT_REFRESH_SECRET environment variable is required in production.');
    }
    if (!process.env.DATABASE_URL) {
      throw new Error('DATABASE_URL environment variable is required in production.');
    }
  }

  return {
    nodeEnv,
    isProduction,
    port: parseInt(process.env.PORT || '3000', 10),
    apiPrefix: process.env.API_PREFIX || 'api/v1',
    corsOrigin: process.env.CORS_ORIGIN || (isProduction ? '' : '*'),
    database: {
      url: process.env.DATABASE_URL,
      directUrl: process.env.DIRECT_URL || process.env.DATABASE_URL,
    },
    jwt: {
      accessSecret: jwtAccessSecret || 'dev-access-secret-change-in-production',
      accessExpiration: process.env.JWT_ACCESS_EXPIRATION || '15m',
      refreshSecret: jwtRefreshSecret || 'dev-refresh-secret-change-in-production',
      refreshExpiration: process.env.JWT_REFRESH_EXPIRATION || '7d',
    },
  };
};
