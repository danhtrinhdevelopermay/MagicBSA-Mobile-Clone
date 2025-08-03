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

#### 🗄️ Database
```
DATABASE_URL=postgresql://username:password@hostname:port/database_name
```
*(Lấy từ PostgreSQL service trong Render)*

#### 🔒 Security & Server
```
SESSION_SECRET=twink_secure_session_secret_2025_render_deployment_key
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