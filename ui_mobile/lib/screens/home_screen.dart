import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Giám sát tư thế ngồi học, kiểm soát truy cập và định vị an toàn cho học sinh'),
        backgroundColor: Colors.blue,
        elevation: 0.5,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFe3f2fd), Color(0xFF90caf9)],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 4,
                    child: ListTile(
                      leading: const Icon(Icons.camera_alt, color: Colors.blueAccent, size: 32),
                      title: const Text('Bắt đầu phiên Live', style: TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: const Text('Theo dõi tư thế và trạng thái mắt'),
                      onTap: () => Navigator.pushNamed(context, '/live'),
                      trailing: const Icon(Icons.chevron_right),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 4,
                    child: ListTile(
                      leading: const Icon(Icons.history, color: Colors.deepPurple, size: 32),
                      title: const Text('Lịch sử phiên', style: TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: const Text('Xem lại các phiên đã thực hiện'),
                      onTap: () => Navigator.pushNamed(context, '/history'),
                      trailing: const Icon(Icons.chevron_right),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 4,
                    child: ListTile(
                      leading: const Icon(Icons.settings, color: Colors.teal, size: 32),
                      title: const Text('Cài đặt', style: TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: const Text('Chỉnh thông số và tuỳ chọn ứng dụng'),
                      onTap: () => Navigator.pushNamed(context, '/settings'),
                      trailing: const Icon(Icons.chevron_right),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Thêm nút giới thiệu dự án & tác giả
                  Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 2,
                    child: ListTile(
                      leading: const Icon(Icons.info_outline, color: Colors.orange, size: 32),
                      title: const Text('Giới thiệu dự án & tác giả', style: TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: const Text('Thông tin về đề tài, nhóm tác giả'),
                      onTap: () => showDialog(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: const Text('Giới thiệu đề tài'),
                          content: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Text(
                                  'Đề tài: Giám sát tư thế ngồi học, kiểm soát truy cập và định vị an toàn cho học sinh\n\n'
                                  'Tác giả: Trịnh Nguyễn Tường Vy và Nguyễn Nam Khánh\n'
                                  'Lớp 10A3 THPT Vũng Tàu\n\n'
                                  'Ứng dụng sử dụng AI nhận diện tư thế - trạng thái học sinh qua camera, cảnh báo sai tư thế/ngủ gật, lưu lại lịch sử và hướng tới bảo vệ an toàn học đường.\n'
                                  'Có thể tùy chỉnh thông số trong phần Cài đặt, dữ liệu hiển thị lịch sử để phụ huynh/giáo viên giám sát.',
                                ),
                              ],
                            ),
                          ),
                          actions: [
                            TextButton(
                              child: const Text('Đóng'),
                              onPressed: () => Navigator.of(context).pop(),
                            ),
                          ],
                        ),
                      ),
                      trailing: const Icon(Icons.chevron_right),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}


