# 🌐 Twink Video Backend - Web Configuration

## 📋 Tổng quan

Web backend đã được cấu hình để xử lý yêu cầu tạo video AI từ mobile app Flutter. Hệ thống bao gồm:

- **Express.js API** để nhận yêu cầu từ mobile app
- **PostgreSQL Database** để lưu trữ yêu cầu và banner
- **SendGrid Email** để thông báo cho admin
- **File Upload** để xử lý ảnh từ mobile app
- **Admin Dashboard** để quản lý yêu cầu

## 🏗️ Cấu trúc Backend

```
web-backend/
├── server/
│   ├── index.ts          # Main server file
│   ├── routes.ts         # API endpoints
│   ├── storage.ts        # Database operations
│   ├── emailService.ts   # Email notifications
│   └── db.ts            # Database connection
├── shared/
│   └── schema.ts        # Database schema & validation
├── client/              # Simple admin frontend
├── uploads/             # Uploaded images storage
└── start-server.js      # Server starter script
```

## 🚀 Khởi động Backend

### Cách 1: Sử dụng Node.js script
```bash
node start-server.js
```

### Cách 2: Sử dụng TSX trực tiếp
```bash
tsx server/index.ts
```

### Cách 3: Sử dụng npm (nếu có script)
```bash
npm run dev
```

## 📡 API Endpoints

### 🎬 Video Job APIs

| Method | Endpoint | Mô tả |
|--------|----------|-------|
| `POST` | `/api/video-jobs` | Gửi yêu cầu tạo video từ mobile app |
| `GET` | `/api/video-jobs/:id` | Lấy trạng thái yêu cầu video |
| `GET` | `/api/admin/video-jobs` | [Admin] Xem tất cả yêu cầu |
| `PATCH` | `/api/admin/video-jobs/:id` | [Admin] Cập nhật trạng thái |

### 📱 Event Banner APIs

| Method | Endpoint | Mô tả |
|--------|----------|-------|
| `GET` | `/api/event-banners` | Lấy banner cho mobile app |
| `GET` | `/api/admin/event-banners` | [Admin] Quản lý banner |
| `POST` | `/api/admin/event-banners` | [Admin] Tạo banner mới |

### 🔧 System APIs

| Method | Endpoint | Mô tả |
|--------|----------|-------|
| `GET` | `/api/health` | Health check |

## 📱 Tích hợp với Mobile App Flutter

### 1. Cấu hình URL API trong mobile app

Cập nhật base URL trong Flutter app để trỏ đến web backend:

```dart
// lib/services/video_service.dart
class VideoService {
  static const String baseUrl = 'https://your-backend-domain.com'; // Hoặc http://localhost:3000 cho development
  
  Future<Map<String, dynamic>> submitVideoJob({
    required String userName,
    required String userEmail,
    String? userPhone,
    required String videoStyle,
    required int videoDuration,
    required File imageFile,
    String? description,
  }) async {
    var uri = Uri.parse('$baseUrl/api/video-jobs');
    var request = http.MultipartRequest('POST', uri);
    
    // Add form fields
    request.fields['userName'] = userName;
    request.fields['userEmail'] = userEmail;
    request.fields['videoStyle'] = videoStyle;
    request.fields['videoDuration'] = videoDuration.toString();
    if (userPhone != null) request.fields['userPhone'] = userPhone;
    if (description != null) request.fields['description'] = description;
    
    // Add image file
    request.files.add(await http.MultipartFile.fromPath('image', imageFile.path));
    
    var response = await request.send();
    // Handle response...
  }
}
```

### 2. Cập nhật Banner Service

```dart
// lib/services/banner_service.dart
class BannerService {
  static const String baseUrl = 'https://your-backend-domain.com';
  
  Future<List<EventBanner>> getEventBanners() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/event-banners'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return (data['data'] as List)
              .map((banner) => EventBanner.fromJson(banner))
              .toList();
        }
      }
    } catch (e) {
      print('Error fetching banners: $e');
    }
    
    // Fallback to local data if API fails
    return _getLocalBanners();
  }
}
```

## 🔐 Cấu hình Environment Variables

Tạo file `.env` trong thư mục root:

```env
# Database
DATABASE_URL=postgresql://username:password@localhost:5432/twink_video_db

# Email Service
SENDGRID_API_KEY=your_sendgrid_api_key
ADMIN_EMAIL=admin@twink.ai
FROM_EMAIL=noreply@twink.ai

# Session Security
SESSION_SECRET=your_session_secret_here

# URLs
ADMIN_PANEL_URL=https://your-admin-panel.com
APP_URL=https://twink.ai

# Server
PORT=3000
NODE_ENV=production
```

## 📧 Cấu hình SendGrid Email

1. **Đăng ký SendGrid account**
2. **Tạo API Key** với Full Access
3. **Verify sender email** trong SendGrid dashboard
4. **Cập nhật SENDGRID_API_KEY** trong environment variables

## 🗄️ Database Schema

Database đã được thiết lập với các bảng:

### `video_jobs` table
```sql
- id (UUID, Primary Key)
- user_name, user_email, user_phone
- video_style, video_duration
- image_url, image_file_name
- description, status
- admin_notes, processed_video_url
- created_at, updated_at, completed_at
```

### `event_banners` table
```sql
- id (UUID, Primary Key)
- title, description
- image_url, action_url, action_text
- is_active, priority
- created_at, updated_at
```

## 🔄 Workflow Xử lý Video

1. **Mobile app** gửi yêu cầu với ảnh đến `/api/video-jobs`
2. **Backend** lưu yêu cầu vào database và gửi email thông báo cho admin
3. **Admin** nhận email và xử lý video thủ công
4. **Admin** cập nhật trạng thái qua API với link video hoàn thành
5. **Backend** gửi email kết quả cho người dùng
6. **Mobile app** có thể check trạng thái qua API

## 🚀 Deploy Backend

### Option 1: Deploy trên Replit
1. Push code lên repository
2. Tạo Replit project từ GitHub
3. Cấu hình environment variables
4. Deploy và lấy public URL

### Option 2: Deploy trên Railway/Vercel
1. Connect GitHub repository
2. Cấu hình build commands
3. Set environment variables
4. Deploy và cấu hình domain

### Option 3: VPS/Cloud Server
1. Setup Node.js environment
2. Install dependencies
3. Configure nginx reverse proxy
4. Setup SSL certificate
5. Start server với PM2

## 🧪 Testing APIs

### Test Health Check
```bash
curl http://localhost:3000/api/health
```

### Test Video Job Submission
```bash
curl -X POST http://localhost:3000/api/video-jobs \
  -F "userName=Test User" \
  -F "userEmail=test@example.com" \
  -F "videoStyle=cinematic" \
  -F "videoDuration=5" \
  -F "image=@/path/to/image.jpg" \
  -F "description=Test video creation"
```

### Test Event Banners
```bash
curl http://localhost:3000/api/event-banners
```

## 🐛 Troubleshooting

### Database Connection Issues
- Kiểm tra DATABASE_URL format
- Verify database server đang chạy
- Check network connectivity

### Email không gửi được
- Verify SENDGRID_API_KEY
- Check sender email được verify
- Review SendGrid dashboard logs

### File Upload Issues
- Check uploads/ directory permissions
- Verify file size limits
- Check disk space

## 📞 Support

Khi gặp vấn đề:
1. Check server logs cho detailed errors
2. Verify environment variables
3. Test individual API endpoints
4. Check database connection
5. Review email service configuration

Backend đã sẵn sàng để nhận yêu cầu từ mobile app và xử lý workflow tạo video AI!