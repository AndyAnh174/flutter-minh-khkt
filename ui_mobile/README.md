# UI Mobile - Giám sát tư thế ngồi học, kiểm soát truy cập và định vị an toàn cho học sinh

## Giới thiệu
Đây là ứng dụng di động Flutter sử dụng AI/ML để giám sát tư thế ngồi học, kiểm soát truy cập và định vị an toàn dành cho học sinh. Ứng dụng giúp phát hiện hình ảnh từ camera nhằm nhận diện tư thế ngồi, trạng thái mắt (ngủ/gần ngủ) và ghi nhận lịch sử truy cập/an toàn.

- Nhận diện trực tiếp từ camera, cảnh báo khi phát hiện ngồi sai tư thế hoặc buồn ngủ.
- Lưu lại lịch sử các phiên sử dụng, có thể xem chi tiết cảnh báo từng phiên.
- Quản lý truy cập và hỗ trợ các chức năng định vị an toàn (có thể mở rộng).
- Hỗ trợ đa nền tảng: Android, iOS, Windows, Linux, MacOS, Web (Flutter Multiplatform).
- Giao diện hiện đại, dễ sử dụng, hỗ trợ tiếng Việt.

## Tác giả
- **Trịnh Nguyễn Tường Vy** – 10A3 THPT Vũng Tàu
- **Nguyễn Nam Khánh** – 10A3 THPT Vũng Tàu

## Đề tài
**Giám sát tư thế ngồi học, kiểm soát truy cập và định vị an toàn cho học sinh**

Dự án thực hiện dưới đề tài Khoa học kỹ thuật cấp học sinh năm 2025, với mục tiêu hỗ trợ sử dụng AI phục vụ sức khoẻ, an ninh và an toàn học đường.

## Chức năng chính
- Nhận diện tư thế ngồi qua ML Kit Pose Detection
- Nhận diện trạng thái mắt nhắm/mở
- Cảnh báo bằng văn bản và âm thanh (Text-to-speech)
- Lưu và xem lại lịch sử các phiên sử dụng
- Quản lý truy cập học sinh
- Định vị an toàn (có thể mở rộng/phát triển thêm)
- Tuỳ chỉnh tham số cảnh báo & FPS cho camera

## Hướng dẫn sử dụng
1. Cài đặt Flutter, Android Studio hoặc VSCode (có plugin Dart + Flutter)
2. Mở thư mục `ui_mobile`, chạy lệnh `flutter pub get`
3. Chạy app: `flutter run`
4. Cho phép app truy cập camera khi được yêu cầu

Mọi góp ý hay hỗ trợ, vui lòng liên hệ tác giả hoặc giáo viên hướng dẫn tại lớp 10A3 THPT Vũng Tàu.
