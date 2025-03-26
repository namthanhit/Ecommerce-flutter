import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecommerce/common/helper/navigator/app_navigator.dart';
import 'package:ecommerce/common/widgets/appbar/app_bar.dart';
import 'package:ecommerce/presentation/auth/pages/siginin.dart';
import 'package:ecommerce/presentation/settings/widgets/my_favorties_tile.dart';
import 'package:ecommerce/presentation/settings/widgets/my_orders_tile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  Map<String, dynamic>? userData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  // 🛠 Lấy dữ liệu user từ Firestore
  Future<void> _fetchUserData() async {
    try {
      var currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        var userDoc = await FirebaseFirestore.instance.collection('Users').doc(currentUser.uid).get();
        if (userDoc.exists) {
          setState(() {
            userData = userDoc.data();
            isLoading = false;
          });
        }
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _handleSignOut(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      AppNavigator.pushAndRemove(context, SigninPage());
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error signing out: ${e.toString()}')),
      );
    }
  }

  // ⚡ Mở bottom sheet chỉnh sửa thông tin (VẪN HIỂN THỊ ẢNH nhưng không có chức năng chỉnh sửa)
  void _editProfile() {
    TextEditingController nameController =
    TextEditingController(text: "${userData?['firstName']} ${userData?['lastName']}");
    TextEditingController emailController = TextEditingController(text: userData?['email']);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (context) {
        return Padding(
          padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, top: 20, left: 16, right: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 40,
                backgroundImage: userData!['image'] != null && userData!['image'].isNotEmpty
                    ? NetworkImage(userData!['image'])
                    : const AssetImage('assets/images/profile2.png') as ImageProvider,
              ),
              const SizedBox(height: 10),
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: "Full Name", border: OutlineInputBorder()),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: emailController,
                decoration: InputDecoration(labelText: "Email", border: OutlineInputBorder()),
              ),
              const SizedBox(height: 15),
              ElevatedButton(
                onPressed: () => _updateUserInfo(nameController.text, emailController.text),
                child: const Text("Save Changes"),
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  // ✅ Cập nhật tên và email người dùng
  Future<void> _updateUserInfo(String newName, String newEmail) async {
    List<String> names = newName.split(" ");
    String firstName = names.first;
    String lastName = names.length > 1 ? names.sublist(1).join(" ") : "";

    User? user = FirebaseAuth.instance.currentUser;
    String userId = user!.uid;

    // Cập nhật email
    try {
      if (newEmail != user.email) {
        await user.verifyBeforeUpdateEmail(newEmail);
        await FirebaseFirestore.instance.collection('Users').doc(userId).update({'email': newEmail});
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to update email: $e")));
      return;
    }

    // Cập nhật tên
    await FirebaseFirestore.instance.collection('Users').doc(userId).update({
      'firstName': firstName,
      'lastName': lastName,
    });

    setState(() {
      userData!['firstName'] = firstName;
      userData!['lastName'] = lastName;
      userData!['email'] = newEmail;
    });

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Profile updated!")));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const BasicAppbar(title: Text('Settings')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            isLoading ? const Center(child: CircularProgressIndicator()) : _buildUserInfo(),
            const SizedBox(height: 30),
            const MyFavortiesTile(),
            const SizedBox(height: 15),
            const MyOrdersTile(),
            const SizedBox(height: 30),
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

  Widget _buildUserInfo() {
    if (userData == null) {
      return const Center(child: Text('No user data found.'));
    }

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundImage: userData!['image'] != null && userData!['image'].isNotEmpty
                  ? NetworkImage(userData!['image'])
                  : const AssetImage('assets/images/profile2.png') as ImageProvider,
            ),
            const SizedBox(width: 16),
            GestureDetector(
              onTap: _editProfile,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "${userData!['firstName']} ${userData!['lastName']}",
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(userData!['email'] ?? 'No email', style: TextStyle(color: Colors.grey[700])),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
