# Stage 1: Build NestJS backend
FROM node:20-alpine AS builder

WORKDIR /app

# Copy package and schema from backend directory
COPY backend/package*.json ./
COPY backend/prisma ./prisma/

RUN npm ci

# Copy backend source and build
COPY backend/tsconfig*.json ./
COPY backend/nest-cli.json ./
COPY backend/src ./src/

RUN npx prisma generate
RUN npm run build

# Stage 2: Production Runner
FROM node:20-alpine AS runner

WORKDIR /app

ENV NODE_ENV=production

COPY backend/package*.json ./
COPY backend/prisma ./prisma/

RUN npm ci --only=production && npx prisma generate

COPY --from=builder /app/dist ./dist

RUN mkdir -p uploads logs

EXPOSE 8080

CMD ["node", "dist/main"]
