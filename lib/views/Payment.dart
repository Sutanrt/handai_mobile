import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'webviewpaymentstatus.dart';

class PaymentMethodPage extends StatelessWidget {
  const PaymentMethodPage({super.key});

  Future<void> _payWithMidtrans(BuildContext context, String method) async {
    try {
      // Panggil endpoint server kamu untuk generate Snap Token
      final response = await http.post(
        Uri.parse('https://your-server.com/api/create-snap'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'payment_type': method,
          'amount': 10000, // contoh harga, ganti sesuai kebutuhan
        }),
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        final snapUrl = body['redirect_url'];

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => WebViewPaymentPage(paymentUrl: snapUrl),
          ),
        );
      } else {
        throw 'Failed to create Snap Token';
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Metode Pembayaran'),
        backgroundColor: Colors.green,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildPaymentOption(
            context,
            title: 'Transfer Bank',
            description: 'Bayar melalui ATM, M-Banking, atau Internet Banking',
            assetPath: 'assets/images/bank-transfer.png',
            method: 'bank_transfer',
          ),
          const SizedBox(height: 16),
          _buildPaymentOption(
            context,
            title: 'E-Wallet (GoPay, ShopeePay, dll)',
            description: 'Bayar instan melalui dompet digital',
            assetPath: 'assets/images/e-wallet.png',
            method: 'e_wallet',
          ),
          const SizedBox(height: 16),
          _buildPaymentOption(
            context,
            title: 'Kartu Kredit/Debit',
            description: 'Bayar menggunakan kartu Visa/Mastercard',
            assetPath: 'assets/images/credit-card.png',
            method: 'credit_card',
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentOption(BuildContext context, {
    required String title,
    required String description,
    required String assetPath,
    required String method,
  }) {
    return GestureDetector(
      onTap: () => _payWithMidtrans(context, method),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.green),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Image.asset(
              assetPath,
              width: 60,
              height: 60,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}