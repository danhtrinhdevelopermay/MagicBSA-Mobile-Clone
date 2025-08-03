# 🔧 Fix Lỗi Build trên Render - "Missing script: build"

## 🚨 Vấn đề
Render đang sử dụng `package.json` gốc thay vì file production phù hợp, nên không có script "build".

## ✅ Giải pháp

### Cách 1: Sửa package.json gốc trực tiếp

Copy nội dung từ `package.json.production` vào `package.json` chính:

```bash
# Backup package.json cũ
cp package.json package.json.backup

# Copy production config
cp package.json.production package.json
```

### Cách 2: Thay đổi Build Command trên Render

Trong Render Dashboard:

**Build Command:** 
```bash
cp package.json.production package.json && cp tsconfig.json.production tsconfig.json && npm install && npm run build
```

**Start Command:**
```bash
npm start
```

## 📋 Build Commands chi tiết

### Build Command (recommended):
```bash
npm install && tsc && npm run db:push
```

### Hoặc đơn giản hơn:
```bash
npm install && npm run build
```

### Start Command:
```bash
node dist/server/index.js
```

## 🔧 Environment Variables cần thiết

Đảm bảo tất cả env vars đã được set trên Render:

```
NODE_ENV=production
PORT=10000
DATABASE_URL=postgresql://neondb_owner:npg_dHzefW93gbGs@ep-crimson-credit-a26r94kr.eu-central-1.aws.neon.tech/neondb?sslmode=require
SENDGRID_API_KEY=SG.r8arQvRKTK23filvuG0SLg.M33ZMxQ2YdSK2idvn8IfkiKR8JfVqes8GKuN06Nra3c
FROM_EMAIL=info.twink.bsa@gmail.com
ADMIN_EMAIL=brightstar.edu.vn@gmail.com
SESSION_SECRET=twink_bsa_render_2025_ultra_secure_session_key_d4f8k2m9x7z1q3w6e8r5t2y9u4i7o0p3a6s8d1f4g7h9j2k5l8n1b4v7c0x3z6m9q2w5e8r1t4y7u0i3o6p9s2a5d8f1g4h7j0k3l6n9m2v5c8x1z4q7w0e3r6t9y2u5i8o1p4a7s0d3f6g9h2j5k8l1n4b7v0c3x6z9m2q5w8e1r4t7y0u3i6o9p2s5a8d1f4g7h0j3k6l9n2b5v8c1x4z7m0q3w6e9r2t5y8u1i4o7p0a3s6d9f2g5h8j1k4l7n0b3v6c9x2z5m8q1w4e7r0t3y6u9i2o5p8a1s4d7f0g3h6j9k2l5n8b1v4c7x0z3m6q9w2e5r8t1y4u7i0o3p6a9s2d5f8g1h4j7k0l3n6b9v2c5x8z1m4q7w0e3r6t9y2u5i8o1p4
```

## 📂 File Structure cần thiết

```
Project Root/
├── package.json          # Production config (fixed)
├── tsconfig.json         # TypeScript config
├── server/               # Source code
│   ├── index.ts
│   ├── routes.ts
│   ├── storage.ts
│   ├── db.ts
│   └── emailService.ts
├── shared/
│   └── schema.ts
└── dist/                 # Compiled output (created during build)
    └── server/
        └── index.js
```

## 🚀 Steps để fix ngay

1. **Trên Render Dashboard:**
   - Go to your service settings
   - Update Build Command: `npm install && npm run build`
   - Update Start Command: `npm start`

2. **Redeploy:**
   - Trigger manual deploy

3. **Monitor logs:**
   - Watch build logs để đảm bảo TypeScript compile thành công

## ⚡ Quick Fix Commands

Nếu cần fix nhanh từ Replit, chạy:

```bash
# Replace package.json với production version
cp package.json.production package.json

# Replace tsconfig.json với production version
cp tsconfig.json.production tsconfig.json

# Test build locally
npm install
npm run build

# Push changes
git add .
git commit -m "fix: Update package.json for Render deployment with build script"
git push origin main
```

Sau đó trigger redeploy trên Render.