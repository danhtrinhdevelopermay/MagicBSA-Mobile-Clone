# Build Instructions - Twink AI v1.1.0

## 🚀 Hướng dẫn Build APK

### Yêu cầu hệ thống
- Flutter SDK 3.22.0+
- Android SDK 34
- Java 17
- Git

### Các bước build

1. **Clone repository**
```bash
git clone https://github.com/danhtrinhdevelopermay/MagicBSA-Mobile-Clone.git
cd MagicBSA-Mobile-Clone/ai_image_editor_flutter
```

2. **Cài đặt dependencies**
```bash
flutter pub get
```

3. **Clean build (nếu cần)**
```bash
flutter clean
flutter pub get
```

4. **Build APK**
```bash
# Build release APK
flutter build apk --release

# Hoặc build split APKs cho optimize kích thước
flutter build apk --split-per-abi --release
```

5. **Tìm file APK**
- APK sẽ được tạo tại: `build/app/outputs/flutter-apk/`
- File: `app-release.apk` hoặc `app-arm64-v8a-release.apk`

### 🔧 Giải quyết vấn đề cài đặt

#### Lỗi xung đột version
```bash
# Option 1: Gỡ app cũ hoàn toàn
adb uninstall com.brightstartsacademy.ai.twink

# Option 2: Force install (có thể mất data)
adb install -r app-release.apk
```

#### Lỗi permissions
- Bật "Unknown sources" trong Settings > Security
- Cho phép cài đặt từ nguồn không xác định

#### Debugging
```bash
# Check connected devices
flutter devices

# Install và run debug
flutter run --debug

# Check logs
flutter logs
```

### 📱 Version Info

**Current Version: 1.1.0+2**
- Version Name: 1.1.0 (hiển thị cho user)
- Version Code: 2 (Android internal)
- Package: com.brightstartsacademy.ai.twink

### 🆕 Changelog Version 1.1.0

**Tính năng mới:**
- Banner slide system với auto-rotation
- AI Video Creation từ ảnh với 6 styles
- Enhanced UI/UX với animations
- Form validation và error handling
- Admin-based video processing workflow

**Technical Updates:**
- Updated dependencies (cached_network_image)
- Improved state management
- Better API service architecture
- Enhanced error handling

### 🚨 Important Notes

1. **Signing**: Hiện tại dùng debug signing. Cho production cần proper signing config.

2. **API Keys**: App cần API keys để hoạt động đầy đủ:
   - ClipDrop API key
   - Hugging Face API key
   - Admin server endpoints

3. **Dependencies**: Tất cả dependencies đã được test và compatible.

4. **Performance**: App optimized cho Android devices từ API 21+.

### 📞 Support

Nếu gặp vấn đề khi build hoặc cài đặt:
1. Check Flutter doctor: `flutter doctor`
2. Verify Android SDK setup
3. Clear Flutter cache: `flutter clean`
4. Rebuild: `flutter pub get && flutter build apk --release`

Chúc bạn build thành công! 🎉