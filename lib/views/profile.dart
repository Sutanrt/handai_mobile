import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  final Map<String, dynamic> userData;

  const ProfilePage({super.key, required this.userData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profil Pengguna')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            _buildProfileItem("Nama", userData['name']),
            _buildProfileItem("Email", userData['email']),
            _buildProfileItem("No. HP", userData['phone']),
            _buildProfileItem("Alamat", userData['address']),
            _buildProfileItem("Tanggal Daftar", userData['created_at']),
            // Tambah sesuai field lain yang tersedia
          ],
        ),
      ),
    );
  }

  Widget _buildProfileItem(String label, dynamic value) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        title: Text(label),
        subtitle: Text(value?.toString() ?? '-'),
      ),
    );
  }
}
