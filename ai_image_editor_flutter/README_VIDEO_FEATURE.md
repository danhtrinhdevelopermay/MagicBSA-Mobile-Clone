# AI Video Creation Feature - Guide

## Tổng quan

Tính năng AI tạo video từ ảnh được thiết kế để cho phép người dùng gửi yêu cầu tạo video từ ảnh tĩnh. Hệ thống hoạt động theo mô hình xử lý thủ công bởi admin team để đảm bảo chất lượng cao.

## Cách hoạt động

### 1. Banner System
- Hiển thị banner slide trên trang chủ để quảng bá tính năng mới
- Auto-sliding với thời gian 4 giây giữa các banner
- Tap để điều hướng đến trang tạo video

### 2. Video Creation Process
1. **Chọn ảnh**: Upload ảnh từ thư viện (tối đa 10MB)
2. **Chọn phong cách**: 6 phong cách có sẵn (Cinematic, Anime, Realistic, v.v.)
3. **Chọn thời lượng**: 3s, 5s, hoặc 10s
4. **Điền thông tin**: Họ tên, email, số điện thoại (tùy chọn)
5. **Mô tả bổ sung**: Yêu cầu đặc biệt (tùy chọn)
6. **Gửi yêu cầu**: Submit form và nhận xác nhận

### 3. Admin Processing
- Yêu cầu được gửi đến server admin
- Admin team xử lý thủ công bằng các tool AI chuyên nghiệp
- Kết quả được gửi về email trong vòng 24-48 giờ

## Technical Implementation

### Models
- `EventBanner`: Quản lý thông tin banner
- `VideoJob`: Lưu trữ thông tin yêu cầu tạo video

### Services
- `BannerService`: API service cho banner và video job
  - `getActiveBanners()`: Lấy banner đang hoạt động
  - `submitVideoJob()`: Gửi yêu cầu tạo video
  - `getVideoJobStatus()`: Kiểm tra trạng thái (future feature)

### UI Components
- `EventBannerSlider`: Widget hiển thị banner với animation
- `AIVideoCreationScreen`: Form nhập liệu hoàn chỉnh

## Configuration

### API Endpoints
```dart
// Base URL cần được cấu hình trong BannerService
static const String _baseUrl = 'https://your-admin-api.com/api';

// Endpoints:
// GET /banners/active - Lấy banner
// POST /video-jobs - Gửi yêu cầu video
// GET /video-jobs/{id} - Kiểm tra trạng thái
```

### Dependencies Added
```yaml
cached_network_image: ^3.3.1  # Cho banner images
```

## Usage Instructions

### Cho người dùng cuối:
1. Mở app và xem banner trên trang chủ
2. Tap vào banner "AI Tạo Video Từ Ảnh"
3. Chọn ảnh từ thư viện
4. Chọn phong cách và thời lượng video
5. Điền thông tin liên hệ
6. Gửi yêu cầu và chờ email kết quả

### Cho admin team:
1. Nhận yêu cầu qua API endpoint
2. Download ảnh gốc và thông tin yêu cầu
3. Sử dụng tool AI để tạo video theo yêu cầu
4. Upload video kết quả và gửi email cho user

## Future Enhancements

1. **Real-time Status**: Thêm tính năng theo dõi trạng thái real-time
2. **Push Notifications**: Thông báo khi video hoàn thành
3. **History**: Lịch sử các yêu cầu đã gửi
4. **Preview**: Xem trước video ngay trong app
5. **Auto Processing**: Tích hợp AI API để xử lý tự động

## Testing

Để test tính năng:
1. Chạy app với `flutter run`
2. Kiểm tra banner hiển thị trên trang chủ
3. Tap banner và test flow tạo video
4. Verify form validation
5. Test submit (sẽ fail nếu chưa có API endpoint thật)

## Notes

- Hiện tại sử dụng fallback data cho banner khi API không khả dụng
- Video processing được xử lý thủ công bởi admin
- Cần cấu hình API endpoints thật để hoạt động hoàn chỉnh
- Form validation đảm bảo data integrity trước khi submit