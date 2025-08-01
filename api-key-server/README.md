# ClipDrop API Key Server

Simple Node.js server để cung cấp API keys cho Flutter app AI Image Editor.

## Features

- ✅ REST API endpoint để cung cấp API keys
- ✅ Web interface để quản lý API keys
- ✅ File-based configuration (config.json)
- ✅ CORS support cho Flutter app
- ✅ Health check endpoint

## Installation

```bash
cd api-key-server
npm install
```

## Usage

### Development
```bash
npm run dev
```

### Production
```bash
npm start
```

Server sẽ chạy trên port 3001 (hoặc PORT environment variable).

## API Endpoints

### GET /api/config/clipdrop-keys
Trả về API keys cho Flutter app.

Response:
```json
{
  "primary": "your-primary-api-key",
  "backup": "your-backup-api-key", 
  "status": "active",
  "lastUpdated": "2025-08-01T14:30:00.000Z"
}
```

### POST /api/config/clipdrop-keys
Cập nhật API keys.

Request body:
```json
{
  "primary": "new-primary-key",
  "backup": "new-backup-key",
  "status": "active"
}
```

### GET /health
Health check endpoint.

### GET /
Web interface để quản lý API keys.

## Configuration

API keys được lưu trong file `config.json`:

```json
{
  "clipdrop": {
    "primary": "your-primary-api-key",
    "backup": "your-backup-api-key",
    "status": "active",
    "lastUpdated": "2025-08-01T14:30:00.000Z"
  }
}
```

## Flutter Integration

Flutter app sẽ fetch API keys từ endpoint:
```
https://your-server.com/api/config/clipdrop-keys
```

Cập nhật URL trong `ai_image_editor_flutter/lib/services/clipdrop_service.dart`:
```dart
static const String _serverBaseUrl = 'https://your-server.com';
```

## Deployment

1. Deploy server lên platform như Heroku, Railway, hoặc VPS
2. Cập nhật URL trong Flutter app
3. Truy cập web interface để quản lý API keys
4. Flutter app sẽ tự động lấy keys mới nhất

## Security Notes

- API keys được lưu dưới dạng plain text trong config.json
- Đảm bảo file config.json không được commit vào git
- Sử dụng HTTPS trong production
- Có thể thêm authentication cho web interface nếu cần