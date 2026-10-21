FROM node:20-slim

WORKDIR /app

# Install openssl for Prisma runtime
RUN apt-get update -y && apt-get install -y openssl && rm -rf /var/lib/apt/lists/*

# Copy backend dependencies and schema
COPY package*.json ./
COPY prisma ./prisma/

# Install ALL dependencies (including @nestjs/cli for nest build)
RUN npm install --include=dev

# Copy source code and config
COPY tsconfig*.json ./
COPY nest-cli.json ./
COPY src ./src/

# Generate Prisma client and build NestJS
RUN npx prisma generate
RUN npm run build

# Set production environment variables
ENV NODE_ENV=production
ENV PORT=8080
ENV DATABASE_URL="postgresql://postgres:Sachit%402026@34.21.175.107:5432/postgres?sslmode=disable"
ENV DIRECT_URL="postgresql://postgres:Sachit%402026@34.21.175.107:5432/postgres?sslmode=disable"
ENV JWT_ACCESS_SECRET="super-secret-access-token-key-change-in-production"
ENV JWT_REFRESH_SECRET="super-secret-refresh-token-key-change-in-production"
ENV RAZORPAY_KEY_ID="rzp_test_TqRtFWjJIKDH13"
ENV RAZORPAY_KEY_SECRET="KRjkCVv3TDPl6A2KZHCU3ck2"
ENV CASHFREE_APP_ID="cf_app_placeholder"
ENV CASHFREE_SECRET_KEY="cf_secret_placeholder"
ENV CASHFREE_ENV="TEST"

# Create necessary directories
RUN mkdir -p uploads logs

EXPOSE 8080

CMD ["sh", "-c", "if [ -f dist/src/main.js ]; then node dist/src/main.js; else node dist/main.js; fi"]
