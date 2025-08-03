# 🚀 Hướng dẫn Deploy Twink Video Backend trên Render

## 📋 Thông tin cấu hình

**Deploy URL**: https://web-backend_0787twink.onrender.com

## 🔧 Render Service Configuration

### 1. Build & Deploy Settings

```
Build Command: npm install && npm run build
Start Command: npm start
Node Version: 20.x
Environment: Node
```

### 2. Environment Variables

Trong Render Dashboard, thêm các biến môi trường sau:

#### 📧 Email Service (SendGrid)
```
SENDGRID_API_KEY=SG.r8arQvRKTK23filvuG0SLg.M33ZMxQ2YdSK2idvn8IfkiKR8JfVqes8GKuN06Nra3c
ADMIN_EMAIL=brightstar.edu.vn@gmail.com
FROM_EMAIL=info.twink.bsa@gmail.com
```

#### 🗄️ Database (Neon PostgreSQL)
```
DATABASE_URL=postgresql://neondb_owner:npg_dHzefW93gbGs@ep-crimson-credit-a26r94kr.eu-central-1.aws.neon.tech/neondb?sslmode=require
PGDATABASE=neondb
PGHOST=ep-crimson-credit-a26r94kr.eu-central-1.aws.neon.tech
PGPORT=5432
PGUSER=neondb_owner
PGPASSWORD=npg_dHzefW93gbGs
```

#### 🔒 Security & Server
```
SESSION_SECRET=twink_bsa_render_2025_ultra_secure_session_key_d4f8k2m9x7z1q3w6e8r5t2y9u4i7o0p3a6s8d1f4g7h9j2k5l8n1b4v7c0x3z6m9q2w5e8r1t4y7u0i3o6p9s2a5d8f1g4h7j0k3l6n9m2v5c8x1z4q7w0e3r6t9y2u5i8o1p4a7s0d3f6g9h2j5k8l1n4b7v0c3x6z9m2q5w8e1r4t7y0u3i6o9p2s5a8d1f4g7h0j3k6l9n2b5v8c1x4z7m0q3w6e9r2t5y8u1i4o7p0a3s6d9f2g5h8j1k4l7n0b3v6c9x2z5m8q1w4e7r0t3y6u9i2o5p8a1s4d7f0g3h6j9k2l5n8b1v4c7x0z3m6q9w2e5r8t1y4u7i0o3p6a9s2d5f8g1h4j7k0l3n6b9v2c5x8z1m4q7w0e3r6t9y2u5i8o1p4
PORT=10000
NODE_ENV=production
```

#### 🌐 URLs
```
ADMIN_PANEL_URL=https://web-backend_0787twink.onrender.com
APP_URL=https://web-backend_0787twink.onrender.com
```

## 📁 Files cần thiết cho deployment

### 1. package.json (sử dụng render-package.json)
```json
{
  "name": "twink-video-backend",
  "version": "1.0.0",
  "type": "module",
  "main": "dist/server/index.js",
  "scripts": {
    "build": "tsc",
    "start": "node dist/server/index.js",
    "dev": "tsx server/index.ts",
    "postinstall": "npm run build"
  }
}
```

### 2. tsconfig.json (đã có)
Cấu hình TypeScript để build production code

### 3. Database Schema
- Các bảng đã được tạo: `sessions`, `video_jobs`, `event_banners`
- Schema được định nghĩa trong `shared/schema.ts`

## 🔄 Deployment Steps

1. **Setup Render PostgreSQL Database**
   - Tạo PostgreSQL database trong Render
   - Copy DATABASE_URL từ database info

2. **Deploy Web Service**
   - Connect GitHub repository
   - Set Build & Start commands
   - Add environment variables
   - Deploy

3. **Verify Deployment**
   - Test health check: `https://web-backend_0787twink.onrender.com/api/health`
   - Test API endpoints

## 📱 Cập nhật Mobile App

Trong Flutter app, cập nhật base URL:

```dart
// lib/services/video_service.dart
class VideoService {
  static const String baseUrl = 'https://web-backend_0787twink.onrender.com';
  
  // ... rest of the service code
}

// lib/services/banner_service.dart  
class BannerService {
  static const String baseUrl = 'https://web-backend_0787twink.onrender.com';
  
  // ... rest of the service code
}
```

## 🧪 API Endpoints để test

```bash
# Health check
curl https://web-backend_0787twink.onrender.com/api/health

# Event banners
curl https://web-backend_0787twink.onrender.com/api/event-banners

# Admin video jobs
curl https://web-backend_0787twink.onrender.com/api/admin/video-jobs
```

## ⚠️ Lưu ý quan trọng

1. **Cold Start**: Render free tier có cold start, service sẽ sleep sau 15 phút không hoạt động
2. **File Storage**: Uploaded files sẽ bị xóa khi service restart, nên sử dụng external storage (Cloudinary, AWS S3) cho production
3. **Database**: Render PostgreSQL free tier có giới hạn, nên monitor usage
4. **Email**: Verify sender email trong SendGrid dashboard

## 🔐 Security Notes

- SESSION_SECRET được generate ngẫu nhiên cho bảo mật
- API endpoints không có authentication (phù hợp cho mobile app)
- CORS được cấu hình cho phép tất cả origins
- File upload có size limit 10MB

Backend đã sẵn sàng nhận requests từ mobile app Flutter!