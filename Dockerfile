# Build stage
FROM node:20-slim AS builder

WORKDIR /app

# Install openssl for Prisma
RUN apt-get update -y && apt-get install -y openssl

# Copy backend configuration and source
COPY backend/package*.json ./
COPY backend/prisma ./prisma/

RUN npm install

COPY backend/tsconfig*.json ./
COPY backend/nest-cli.json ./
COPY backend/src ./src/

RUN npx prisma generate
RUN npm run build

# Production stage
FROM node:20-slim AS runner

WORKDIR /app

ENV NODE_ENV=production
ENV PORT=8080

# Install openssl for Prisma runtime
RUN apt-get update -y && apt-get install -y openssl && rm -rf /var/lib/apt/lists/*

# Copy package and prisma files to install production dependencies and generate client
COPY backend/package*.json ./
COPY backend/prisma ./prisma/

RUN npm install --omit=dev
RUN npx prisma generate

# Copy compiled backend dist
COPY --from=builder /app/dist ./dist

RUN mkdir -p uploads logs

EXPOSE 8080

CMD ["node", "dist/main"]
