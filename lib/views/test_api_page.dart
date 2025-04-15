import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../utils/config.dart';

class TestApiPage extends StatefulWidget {
  @override
  _TestApiPageState createState() => _TestApiPageState();
}

class _TestApiPageState extends State<TestApiPage> {
  String _message = '';
  bool _isLoading = false;

  Future<void> _fetchTestData() async {
    setState(() {
      _isLoading = true;
      _message = '';
    });

    try {
      final response = await http.get(Uri.parse('${Config.baseUrl}/api/test'));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _isLoading = false;
          _message = data['message']; // Menampilkan pesan dari API
        });
      } else {
        setState(() {
          _isLoading = false;
          _message = 'Failed to load data';
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _message = 'Error: $e';
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchTestData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Test API')),
      body: Center(
        child: _isLoading ? CircularProgressIndicator() : Text(_message),
      ),
    );
  }
}
