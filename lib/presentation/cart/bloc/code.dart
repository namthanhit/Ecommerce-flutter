import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase Authentication

class OrderCodeHelper {
  static const String _key = 'last_order_number';
  static const String _userKey = 'user_id'; // Lưu user ID để xác định tài khoản

  /// 🔥 Lấy mã đơn hàng tiếp theo (tự động lấy user ID)
  static Future<String> getNextOrderCode() async {
    final prefs = await SharedPreferences.getInstance();
    final user = FirebaseAuth.instance.currentUser; // Lấy user hiện tại

    if (user == null) {
      throw Exception("User chưa đăng nhập!");
    }

    String userId = user.uid; // Lấy ID của user

    // Kiểm tra nếu userId thay đổi thì reset mã đơn hàng
    String? lastUserId = prefs.getString(_userKey);
    if (lastUserId == null || lastUserId != userId) {
      await prefs.setString(_userKey, userId);
      await prefs.setInt(_key, 0); // Reset số đơn về 0
    }

    int lastOrderNumber = prefs.getInt(_key) ?? 0;
    lastOrderNumber++;

    // Lưu lại số đơn hàng mới
    await prefs.setInt(_key, lastOrderNumber);

    // Tạo mã đơn dạng ORD-001, ORD-002...
    return "ORD-${lastOrderNumber.toString().padLeft(3, '0')}";
  }
}
