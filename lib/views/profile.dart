import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'navbar.dart';
import '../utils/config.dart';
import 'login.dart'; // Import login page for redirection if token is invalid

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Map<String, dynamic>? userData;
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    fetchUserProfile();
  }

  Future<void> fetchUserProfile() async {
    try {
      // Get the token from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null) {
        setState(() {
          isLoading = false;
          errorMessage = 'Token tidak ditemukan. Silahkan login kembali.';
        });
        return;
      }

      // Make API request with the stored token
      final response = await http.get(
        Uri.parse('${Config.baseUrl}/api/profile'), // Match your Laravel route
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
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
      } else if (response.statusCode == 401) {
        // Token expired or invalid, clear it and redirect to login
        await prefs.remove('auth_token');
        setState(() {
          isLoading = false;
          errorMessage = 'Sesi login telah berakhir. Silahkan login kembali.';
        });

        // Show alert and redirect to login page after delay
        _showSessionExpiredDialog();
      } else {
        setState(() {
          isLoading = false;
          errorMessage = 'Gagal ambil data: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'Error saat fetch data: $e';
      });
      print('Error saat fetch data: $e');
    }
  }

  void _showSessionExpiredDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Sesi Berakhir'),
          content: const Text(
            'Sesi login Anda telah berakhir. Silahkan login kembali.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                );
              },
              child: const Text('Login'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0C9044),
      bottomNavigationBar: const Navbar(currentIndex: 2),
      body: SafeArea(
        child:
            isLoading
                ? const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                )
                : errorMessage != null
                ? _buildErrorView()
                : _buildProfileView(),
      ),
    );
  }

  Widget _buildErrorView() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 80, color: Colors.white),
          const SizedBox(height: 16),
          Text(
            errorMessage!,
            style: const TextStyle(color: Colors.white, fontSize: 18),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              setState(() {
                isLoading = true;
                errorMessage = null;
              });
              fetchUserProfile();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF0C9044),
            ),
            child: const Text('Coba Lagi'),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileView() {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            SvgPicture.asset('assets/handai-logo-light.svg', width: 40),
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
        const SizedBox(height: 30),
        ElevatedButton(
          onPressed: () async {
            // Logout functionality
            final prefs = await SharedPreferences.getInstance();
            await prefs.remove('auth_token');

            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const LoginPage()),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: Colors.red,
          ),
          child: const Text('Logout'),
        ),
      ],
    );
  }

  Widget _buildProfileItem(String label, dynamic value) {
    return Card(
      color: Colors.white,
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        title: Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF0C9044),
          ),
        ),
        subtitle: Text(
          value?.toString() ?? '-',
          style: const TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}
