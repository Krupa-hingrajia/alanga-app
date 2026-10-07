# Build stage
FROM node:20-slim AS builder

WORKDIR /app

# Install openssl for Prisma
RUN apt-get update -y && apt-get install -y openssl

COPY package*.json ./
COPY prisma ./prisma/

RUN npm install

COPY tsconfig*.json ./
COPY nest-cli.json ./
COPY src ./src/

RUN npx prisma generate
RUN npm run build

# Production stage
FROM node:20-slim AS runner

WORKDIR /app

ENV NODE_ENV=production
ENV PORT=8080

# Install openssl for Prisma runtime
RUN apt-get update -y && apt-get install -y openssl && rm -rf /var/lib/apt/lists/*

COPY package*.json ./
COPY prisma ./prisma/

RUN npm install --omit=dev
RUN npx prisma generate

COPY --from=builder /app/dist ./dist

RUN mkdir -p uploads logs

EXPOSE 8080

CMD ["node", "dist/main"]
