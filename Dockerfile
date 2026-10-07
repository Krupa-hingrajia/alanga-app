FROM node:20-slim

WORKDIR /app

# Set default production environment variables
ENV NODE_ENV=production
ENV PORT=8080
ENV DATABASE_URL="postgresql://postgres:Sachit%402026@34.21.175.107:5432/postgres?sslmode=disable"
ENV DIRECT_URL="postgresql://postgres:Sachit%402026@34.21.175.107:5432/postgres?sslmode=disable"
ENV JWT_ACCESS_SECRET="super-secret-access-token-key-change-in-production"
ENV JWT_REFRESH_SECRET="super-secret-refresh-token-key-change-in-production"

# Install openssl for Prisma runtime
RUN apt-get update -y && apt-get install -y openssl && rm -rf /var/lib/apt/lists/*

# Copy backend dependencies and schema
COPY backend/package*.json ./
COPY backend/prisma ./prisma/

# Install dependencies
RUN npm install

# Copy source code and config
COPY backend/tsconfig*.json ./
COPY backend/nest-cli.json ./
COPY backend/src ./src/

# Generate Prisma client and build NestJS
RUN npx prisma generate
RUN npm run build

# Create necessary directories
RUN mkdir -p uploads logs

EXPOSE 8080

CMD ["node", "dist/main"]
