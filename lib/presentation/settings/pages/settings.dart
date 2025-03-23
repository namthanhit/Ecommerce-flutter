import 'package:ecommerce/common/helper/navigator/app_navigator.dart';
import 'package:ecommerce/common/widgets/appbar/app_bar.dart';
import 'package:ecommerce/presentation/auth/pages/siginin.dart';
import 'package:ecommerce/presentation/settings/widgets/my_orders_tile.dart';
import 'package:ecommerce/presentation/settings/widgets/my_favorties_tile.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Firebase Auth để đăng xuất

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  // Hàm handle sign out
  Future<void> _handleSignOut(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut(); // Đăng xuất tài khoản

      // Điều hướng về trang đăng nhập và clear tất cả các route trước đó
      AppNavigator.pushAndRemove(
        context,
        SigninPage(),
      );
    } catch (e) {
      // Có thể show dialog báo lỗi nếu cần
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error signing out: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const BasicAppbar(
        title: Text('Settings'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const MyFavortiesTile(),
            const SizedBox(height: 15),
            const MyOrdersTile(),
            const SizedBox(height: 30),

            // Nút Đăng xuất
            ElevatedButton.icon(
              onPressed: () => _handleSignOut(context),
              icon: const Icon(Icons.logout),
              label: const Text('Sign Out'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
