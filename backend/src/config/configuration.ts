export default () => {
  const nodeEnv = process.env.NODE_ENV || 'production';
  const isProduction = nodeEnv === 'production';

  const jwtAccessSecret =
    process.env.JWT_ACCESS_SECRET || 'super-secret-access-token-key-change-in-production';
  const jwtRefreshSecret =
    process.env.JWT_REFRESH_SECRET || 'super-secret-refresh-token-key-change-in-production';
  const databaseUrl =
    process.env.DATABASE_URL ||
    'postgresql://postgres:Sachit%402026@34.21.175.107:5432/postgres?sslmode=disable';

  return {
    nodeEnv,
    isProduction,
    port: parseInt(process.env.PORT || '8080', 10),
    apiPrefix: process.env.API_PREFIX || 'api/v1',
    corsOrigin: process.env.CORS_ORIGIN || '*',
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
