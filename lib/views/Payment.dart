import 'package:flutter/material.dart';
import 'basket.dart';

class PaymentMethodPage extends StatelessWidget {
  const PaymentMethodPage({Key? key}) : super(key: key);

  void _payWithCash(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Pembayaran Cash dipilih')),
    );
    // TODO: Implementasi logika cash payment
  }

  void _payWithGopay(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Pembayaran Gopay dipilih')),
    );
    // TODO: Integrasi Midtrans Snap untuk Gopay
  }

  void _payWithQRIS(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Pembayaran QRIS dipilih')),
    );
    // TODO: Integrasi Midtrans Snap untuk QRIS
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Metode Pembayaran'),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildPaymentOption(
              context,
              label: 'Cash',
              imageAsset: 'assets/images/cash.png', // pastikan ada gambar cash
              onTap: () => _payWithCash(context),
            ),
            const SizedBox(height: 20),
            _buildPaymentOption(
              context,
              label: 'Gopay',
              imageAsset: 'assets/images/gopay.png', // pastikan ada gambar gopay
              onTap: () => _payWithGopay(context),
            ),
            const SizedBox(height: 20),
            _buildPaymentOption(
              context,
              label: 'QRIS',
              imageAsset: 'assets/images/qris.png', // pastikan ada gambar qris
              onTap: () => _payWithQRIS(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentOption(BuildContext context, {required String label, required String imageAsset, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Image.asset(imageAsset, width: 50, height: 50),
            const SizedBox(width: 20),
            Text(
              label,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            )
          ],
        ),
      ),
    );
  }
}
