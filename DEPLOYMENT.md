# ALANGA Marketplace — Production Deployment Runbook
### Google Play Store Closed Testing (14 Days)

---

## Project Structure

```
Alanga App/
├── backend/                     # NestJS API
│   ├── src/
│   ├── api/index.ts             # Vercel serverless entry
│   ├── ecosystem.config.js      # PM2 configuration
│   ├── .env.development         # Development secrets (git-ignored)
│   ├── .env.production          # Production secrets (git-ignored)
│   └── logs/                    # PM2 log output directory
│
└── frontend/
    ├── customer_app/            # Flutter Customer App
    │   ├── lib/
    │   │   ├── config/
    │   │   │   ├── environment.dart     # Top-level env accessor
    │   │   │   ├── development.dart     # Dev constants
    │   │   │   └── production.dart      # Prod constants
    │   │   └── core/config/
    │   │       └── environment_config.dart  # Core env config
    │   └── android/
    │       ├── key.properties           # ⚠️ Keystore (NOT committed to git)
    │       └── app/
    │           ├── build.gradle.kts
    │           └── proguard-rules.pro
    │
    ├── vendor_app/              # Flutter Vendor App (same structure)
    │
    └── admin_panel/             # Next.js Admin Panel
        ├── .env.local           # Local dev override
        └── .env.production      # Production env
```

---

## 1. Backend Deployment

### Option A — Vercel (Serverless) [Current Setup]

```bash
# 1. Set environment variables in Vercel Dashboard
#    Project Settings → Environment Variables → Add:
NODE_ENV=production
DATABASE_URL=<your_prod_supabase_url>
DIRECT_URL=<your_prod_supabase_direct_url>
JWT_ACCESS_SECRET=<strong_random_secret>
JWT_REFRESH_SECRET=<strong_random_secret>
JWT_ACCESS_EXPIRATION=15m
JWT_REFRESH_EXPIRATION=7d
CORS_ORIGIN=https://admin.alanga.com
API_PREFIX=api/v1

# 2. Deploy
git push origin main   # Vercel auto-deploys on push
```

### Option B — VPS with PM2

```bash
# On your VPS:

# 1. Install dependencies
cd /var/www/alanga-backend
npm ci --production

# 2. Generate Prisma client
npx prisma generate

# 3. Run database migrations
NODE_ENV=production npx prisma migrate deploy

# 4. Build TypeScript
npm run build:prod

# 5. Install PM2 globally (once)
npm install -g pm2

# 6. Create logs directory
mkdir -p logs

# 7. Copy .env.production to .env on the server
cp .env.production .env

# 8. Start with PM2
npm run pm2:start
# or: pm2 start ecosystem.config.js --env production

# 9. Save PM2 process list and set up auto-start
pm2 save
pm2 startup
# Follow the instructions printed by the above command

# Useful PM2 commands:
npm run pm2:logs      # View logs
npm run pm2:restart   # Restart server
npm run pm2:stop      # Stop server
```

### Production Build Commands

```bash
# Full production build (generates Prisma client + compiles TypeScript)
npm run build:prod

# Start production server (after build)
npm run start:prod

# Start with DB migration (recommended for first deploy or schema changes)
npm run start:prod:migrate
```

---

## 2. Database Migration (Production)

```bash
# Run from the backend directory with production env variables loaded:

# Apply pending migrations to production DB
NODE_ENV=production npx prisma migrate deploy

# ⚠️  NEVER run prisma migrate dev in production — it drops and recreates the schema.
# ✅  ALWAYS use prisma migrate deploy in production.

# Verify migration status
NODE_ENV=production npx prisma migrate status
```

---

## 3. Flutter — Customer App Build

### Prerequisites: Keystore Setup

```bash
# Generate a new keystore (run once, keep the .jks file safe)
keytool -genkey -v \
  -keystore ~/alanga-customer-release.jks \
  -alias alanga-customer \
  -keyalg RSA \
  -keysize 2048 \
  -validity 10000

# Create android/key.properties (do NOT commit to git)
cat > frontend/customer_app/android/key.properties << EOF
storePassword=YOUR_KEYSTORE_PASSWORD
keyPassword=YOUR_KEY_PASSWORD
keyAlias=alanga-customer
storeFile=/absolute/path/to/alanga-customer-release.jks
EOF
```

### Build Commands

```bash
cd frontend/customer_app

# Debug APK (development, points to dev API automatically)
flutter build apk --debug

# Debug APK pointing to production API explicitly
flutter build apk --debug --dart-define=ENV=prod

# Release APK (production — signed with release keystore)
flutter build apk --release --dart-define=ENV=prod

# Release APK — specify version
flutter build apk --release --dart-define=ENV=prod \
  --build-name=1.0.0 --build-number=1

# App Bundle (AAB) — required for Google Play Store upload
flutter build appbundle --release --dart-define=ENV=prod \
  --build-name=1.0.0 --build-number=1
```

Output locations:
- APK: `build/app/outputs/flutter-apk/app-release.apk`
- AAB: `build/app/outputs/bundle/release/app-release.aab`

---

## 4. Flutter — Vendor App Build

```bash
cd frontend/vendor_app

# Same keystore setup required (see Customer App section above)
# Create android/key.properties with vendor keystore details

# Release APK
flutter build apk --release --dart-define=ENV=prod \
  --build-name=1.0.0 --build-number=1

# App Bundle (AAB) for Google Play
flutter build appbundle --release --dart-define=ENV=prod \
  --build-name=1.0.0 --build-number=1
```

---

## 5. Admin Panel Build

```bash
cd frontend/admin_panel

# Install dependencies
npm ci

# Build for production (uses .env.production automatically)
npm run build

# Start production server
npm run start
```

---

## 6. Environment Variable Summary

### Backend (set in .env.production or Vercel Dashboard)

| Variable | Description | Example |
|----------|-------------|---------|
| `NODE_ENV` | Environment | `production` |
| `PORT` | Server port | `3000` |
| `API_PREFIX` | API path prefix | `api/v1` |
| `CORS_ORIGIN` | Allowed CORS origin(s) | `https://admin.alanga.com` |
| `DATABASE_URL` | Supabase pooler URL | `postgresql://...?pgbouncer=true` |
| `DIRECT_URL` | Supabase direct URL | `postgresql://...` |
| `JWT_ACCESS_SECRET` | JWT signing secret | Strong random 64+ char string |
| `JWT_REFRESH_SECRET` | Refresh token secret | Strong random 64+ char string |
| `JWT_ACCESS_EXPIRATION` | Access token lifetime | `15m` |
| `JWT_REFRESH_EXPIRATION` | Refresh token lifetime | `7d` |

### Generate Strong JWT Secrets

```bash
# Run this to generate secure secrets:
openssl rand -base64 64
```

### Flutter Apps (compile-time via --dart-define)

| Key | Value | Purpose |
|-----|-------|---------|
| `ENV` | `prod` or `dev` | Override environment |
| `LOCAL_IP` | `192.168.x.x` | Override dev API IP |

---

## 7. CORS Configuration

In production, CORS is restricted to specific origins set via `CORS_ORIGIN`.

```
# Allow only admin panel:
CORS_ORIGIN=https://admin.alanga.com

# Allow multiple origins (comma-separated — update configuration.ts if needed):
CORS_ORIGIN=https://admin.alanga.com,https://www.alanga.com
```

> **Note:** Flutter mobile apps (Android/iOS) are native HTTP clients — they are **not** subject to CORS. CORS only applies to web browsers (admin panel).

---

## 8. Swagger API Docs

- **Development**: Available at `http://localhost:3000/api/v1/docs`
- **Production**: **Disabled** (returns 404) — not exposed for security

---

## 9. Google Play Closed Testing Checklist

### Pre-Build
- [ ] Backend deployed and responding at production URL (`https://alanga-app.vercel.app/api/v1`)
- [ ] Production DB URL and JWT secrets set in Vercel Dashboard / server env
- [ ] `prisma migrate deploy` run against production DB
- [ ] CORS_ORIGIN set to admin panel production domain

### APK/AAB Build
- [ ] Keystore created and `key.properties` configured for each app
- [ ] `ProductionConfig.apiBaseUrl` in `production.dart` points to correct production URL
- [ ] Release APK/AAB built with `--dart-define=ENV=prod`
- [ ] `versionCode` incremented from previous release (start at `1`)
- [ ] `versionName` set correctly (e.g., `"1.0.0"`)
- [ ] `debugShowCheckedModeBanner: false` ✅ (already set in both apps)
- [ ] No hardcoded localhost/dev URLs remaining in the code

### Testing Before Upload
- [ ] Install release APK on physical Android device (not emulator)
- [ ] App launches without crash
- [ ] Login / Register works → API calls reach production backend
- [ ] Images load correctly (URLs resolve to production server)
- [ ] No debug logs visible to users in the UI

### Google Play Console
- [ ] App created in Play Console (Internal / Closed Testing track selected)
- [ ] Release AAB uploaded to **Closed Testing** track
- [ ] Tester email addresses added to Closed Testing group
- [ ] Tester invite link sent to testers
- [ ] App reviewed (Closed Testing doesn't require full review, but Google does a basic check)

### Post-Deploy Verification
- [ ] Swagger at `/api/v1/docs` returns **404** in production ✅
- [ ] Backend logs show `[production]` mode
- [ ] PM2 / Vercel shows healthy deployment

---

## 10. Security Checklist

- [ ] `.env`, `.env.production`, `.env.development` added to `.gitignore`
- [ ] `key.properties` (keystore config) added to `.gitignore`
- [ ] `*.jks` (keystore file) added to `.gitignore`
- [ ] JWT secrets are minimum 64 characters, randomly generated
- [ ] No hardcoded credentials in any source file
- [ ] Swagger is disabled in production
- [ ] Database errors do not expose schema details in production
- [ ] Verbose NestJS logs disabled in production

---

## 11. Version Increment Guide (For Future Releases)

```bash
# In each app's build.gradle.kts:
versionCode = 2   # Increment by 1 for every upload to Play Console
versionName = "1.0.1"   # Semantic version visible to users

# In pubspec.yaml:
version: 1.0.1+2   # format: versionName+versionCode
```

---

*Generated for ALANGA Marketplace — Closed Testing Phase*
