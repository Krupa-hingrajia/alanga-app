# Stage 1: Build
FROM node:20-alpine AS builder

WORKDIR /app

# Install dependencies needed for build
COPY package*.json ./
COPY prisma ./prisma/

RUN npm ci

# Copy source files and build
COPY tsconfig*.json ./
COPY nest-cli.json ./
COPY src ./src/

RUN npx prisma generate
RUN npm run build

# Stage 2: Production Runner
FROM node:20-alpine AS runner

WORKDIR /app

ENV NODE_ENV=production

# Copy package files and install only production dependencies
COPY package*.json ./
COPY prisma ./prisma/

RUN npm ci --only=production && npx prisma generate

# Copy built application from builder
COPY --from=builder /app/dist ./dist

# Create uploads directory
RUN mkdir -p uploads logs

EXPOSE 8080

CMD ["node", "dist/main"]
