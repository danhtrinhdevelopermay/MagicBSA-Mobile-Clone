# Lời nhắc và Hướng dẫn cho Thay đổi Code

## Nguyên tắc quan trọng khi thay đổi code:

1. **Git Push thủ công**: Khi có thay đổi code, luôn thực hiện lệnh git push thủ công để đồng bộ với repository.
   - Thực hiện push tất cả code từ thư mục gốc mà không cần `cd`
   - Sử dụng lệnh: `git add . && git commit -m "Update: [mô tả thay đổi]" && git push`

2. **Bảo vệ APK Build**: Đảm bảo rằng việc phát triển ứng dụng hoặc thay đổi không ảnh hưởng đến quá trình build APK.
   - Kiểm tra tính tương thích build sau mỗi thay đổi lớn
   - Duy trì cấu trúc project Flutter không bị ảnh hưởng

3. **Cập nhật tài liệu**: Khi có thay đổi kiến trúc quan trọng, cập nhật file replit.md
   - Ghi chú ngày thay đổi
   - Mô tả chi tiết các thay đổi và lý do
   - Cập nhật phần "Recent Changes" và "System Architecture"

4. **Đồng bộ với Backend**: Khi có thay đổi liên quan đến backend web (Express.js), đảm bảo:
   - API endpoints hoạt động chính xác
   - Database schema được cập nhật đúng
   - Email service hoạt động bình thường

## Quy trình làm việc:

1. Thực hiện thay đổi code
2. Test cục bộ để đảm bảo hoạt động
3. Cập nhật tài liệu nếu cần
4. Commit và push code
5. Kiểm tra build process vẫn hoạt động

## Lưu ý đặc biệt:

- Project này có 2 phần chính: Flutter app (Android) và Web backend (Express.js)
- Luôn đảm bảo cả 2 phần đều hoạt động sau thay đổi
- Ưu tiên sự ổn định của APK build process