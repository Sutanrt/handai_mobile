import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;
import 'navbar.dart';
import '../utils/config.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Map<String, dynamic>? userData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchUserProfile();
  }

  Future<void> fetchUserProfile() async {
    try {
      final response = await http.get(
        Uri.parse('${Config.baseUrl}/api/user/profile'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer YOUR_TOKEN_HERE',
        },
      );

      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        setState(() {
          userData = json['data'];
          isLoading = false;
        });
      } else {
        print('Gagal ambil data: ${response.statusCode}');
      }
    } catch (e) {
      print('Error saat fetch data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0C9044),
      bottomNavigationBar: const Navbar(currentIndex: 2),
      body: SafeArea(
        child:
            isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView(
                  padding: const EdgeInsets.all(24),
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        SvgPicture.asset(
                          'assets/handai-logo-light.svg',
                          width: 40,
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Profil Pengguna',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 30),
                    _buildProfileItem("Nama", userData?['name']),
                    _buildProfileItem("Email", userData?['email']),
                    _buildProfileItem("No. HP", userData?['phone']),
                    _buildProfileItem("Dibuat oleh", userData?['created_by']),
                  ],
                ),
      ),
    );
  }

  Widget _buildProfileItem(String label, dynamic value) {
    return Card(
      color: Colors.white,
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        title: Text(label),
        subtitle: Text(value?.toString() ?? '-'),
      ),
    );
  }
}
