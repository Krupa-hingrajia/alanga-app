export default () => {
  const nodeEnv = process.env.NODE_ENV || 'development';
  const isProduction = nodeEnv === 'production';

  const jwtAccessSecret = process.env.JWT_ACCESS_SECRET;
  const jwtRefreshSecret = process.env.JWT_REFRESH_SECRET;
  const databaseUrl = process.env.DATABASE_URL;

  // Enforce required environment variables during startup
  if (!jwtAccessSecret) {
    throw new Error('FATAL: JWT_ACCESS_SECRET environment variable is missing.');
  }
  if (!jwtRefreshSecret) {
    throw new Error('FATAL: JWT_REFRESH_SECRET environment variable is missing.');
  }
  if (!databaseUrl) {
    throw new Error('FATAL: DATABASE_URL environment variable is missing.');
  }

  return {
    nodeEnv,
    isProduction,
    port: parseInt(process.env.PORT || '3000', 10),
    apiPrefix: process.env.API_PREFIX || 'api/v1',
    corsOrigin: process.env.CORS_ORIGIN || (isProduction ? '' : '*'),
    database: {
      url: databaseUrl,
      directUrl: process.env.DIRECT_URL || databaseUrl,
    },
    jwt: {
      accessSecret: jwtAccessSecret,
      accessExpiration: process.env.JWT_ACCESS_EXPIRATION || '15m',
      refreshSecret: jwtRefreshSecret,
      refreshExpiration: process.env.JWT_REFRESH_EXPIRATION || '7d',
    },
  };
};
