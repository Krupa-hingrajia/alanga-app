# Build stage
FROM node:20-slim AS builder

WORKDIR /app

# Install openssl for Prisma
RUN apt-get update -y && apt-get install -y openssl

# Copy backend configuration and source
COPY backend/package*.json ./
COPY backend/prisma ./prisma/

RUN npm ci

COPY backend/tsconfig*.json ./
COPY backend/nest-cli.json ./
COPY backend/src ./src/

RUN npx prisma generate
RUN npm run build
RUN npm prune --production

# Production stage
FROM node:20-slim AS runner

WORKDIR /app

ENV NODE_ENV=production

# Install openssl for Prisma runtime
RUN apt-get update -y && apt-get install -y openssl && rm -rf /var/lib/apt/lists/*

# Copy production artifacts from builder
COPY --from=builder /app/package*.json ./
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/prisma ./prisma
COPY --from=builder /app/dist ./dist

RUN mkdir -p uploads logs

EXPOSE 8080

CMD ["node", "dist/main"]
