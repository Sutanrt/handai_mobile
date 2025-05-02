// Halaman metode pembayaran dan flow pembayaran Handai
// Semua logika pembayaran, popup QR, dan tampilan sukses/gagal ada di sini

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:async';

class PaymentMethodPage extends StatefulWidget {
  // Data order, lokasi, dan total harga diterima dari BasketPage
  final List<Map<String, dynamic>> cart;
  final String locationType; // 'Dine In' atau 'Delivery'
  final String location;
  final String deliveryAddress;
  final int totalPrice;

  const PaymentMethodPage({
    Key? key,
    required this.cart,
    required this.locationType,
    required this.location,
    required this.deliveryAddress,
    required this.totalPrice,
  }) : super(key: key);

  @override
  State<PaymentMethodPage> createState() => _PaymentMethodPageState();
}

class _PaymentMethodPageState extends State<PaymentMethodPage> {
  // State untuk pilihan pembayaran
  String selectedPayment = 'Non-Tunai';
  bool paymentSuccess = false;
  bool paymentFailed = false;

  // State untuk popup QR Non-Tunai
  bool _showQrPopup = false;
  int _qrSeconds = 60;
  Timer? _qrTimer;

  @override
  void initState() {
    super.initState();
    _qrSeconds = 60;
  }

  // Mulai timer QR (1 menit)
  void _startQrTimer() {
    _qrSeconds = 60;
    _qrTimer?.cancel();
    _qrTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted && _showQrPopup) {
        setState(() {
          if (_qrSeconds > 0) {
            _qrSeconds--;
          }
        });
      }
    });
  }

  // Stop timer QR
  void _stopQrTimer() {
    _qrTimer?.cancel();
  }

  // Handler tombol Pay
  void _pay() {
    if (selectedPayment == 'Non-Tunai') {
      // Kalau Non-Tunai, munculkan popup QR
      setState(() {
        _showQrPopup = true;
        _startQrTimer();
      });
    } else {
      // Kalau Tunai, langsung ke halaman sukses Tunai
      setState(() {
        paymentSuccess = false;
        paymentFailed = false;
      });
      Future.delayed(const Duration(seconds: 1), () {
        setState(() {
          paymentSuccess = true;
        });
      });
    }
  }

  // Handler tombol Complete di popup QR
  void _onQrComplete() {
    _stopQrTimer();
    setState(() {
      _showQrPopup = false;
      paymentSuccess = true;
    });
  }

  @override
  void dispose() {
    _stopQrTimer();
    super.dispose();
  }

  void _goToHistory() {
    Navigator.pushReplacementNamed(context, '/history');
  }

  void _retryPayment() {
    setState(() {
      paymentFailed = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Kalau sukses/gagal, tampilkan screen sesuai
    if (paymentSuccess) {
      return _buildSuccessScreen();
    }
    if (paymentFailed) {
      return _buildFailureScreen();
    }
    // Layout utama payment
    return Stack(
      children: [
        Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header dan logo
                  IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.arrow_back),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      SvgPicture.asset('assets/images/handai-logo-filled-hijau.svg', width: 40),
                    ],
                  ),
                  // Judul dan subjudul
                  const Text(
                    'Payment Method',
                    style: TextStyle(
                      color: Colors.green,
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Choose the method you want',
                    style: TextStyle(
                      color: Colors.black54,
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 30),
                  // Pilihan metode pembayaran (Tunai/Non-Tunai)
                  Row(
                    children: [
                      _buildOptionCard(
                        title: 'Tunai',
                        description: 'Lakukan pembayaran di store',
                        imagePath: 'assets/images/cash.png',
                        isSelected: selectedPayment == 'Tunai',
                        onTap: () {
                          setState(() {
                            selectedPayment = 'Tunai';
                          });
                        },
                      ),
                      const SizedBox(width: 15),
                      _buildOptionCard(
                        title: 'Non-Tunai',
                        description: 'Lakukan pembayaran sekarang',
                        imagePath: 'assets/images/qris.png',
                        isSelected: selectedPayment == 'Non-Tunai',
                        onTap: () {
                          setState(() {
                            selectedPayment = 'Non-Tunai';
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  // QR Non-Tunai sekarang muncul di popup, bukan di sini
                  const Divider(),
                  // Ringkasan pembayaran
                  const Text(
                    'Payment Summary',
                    style: TextStyle(
                      color: Colors.green,
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _buildSummaryRow('Price', 'Rp. ${widget.totalPrice}'),
                  _buildSummaryRow('Delivery fee', 'Rp. 0'),
                  _buildSummaryRow('Discount', 'Rp. 0'),
                  const SizedBox(height: 10),
                  _buildSummaryRow('Total Price', 'Rp. ${widget.totalPrice}', isBold: true),
                  const SizedBox(height: 20),
                  // Tombol Pay
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _showQrPopup ? Colors.grey : Colors.black,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: _showQrPopup ? null : _pay,
                      child: const Text(
                        'Pay',
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        // Popup QR Non-Tunai
        if (_showQrPopup) _buildQrPopup(context),
      ],
    );
  }

  // Widget kartu pilihan metode pembayaran
  Widget _buildOptionCard({
    required String title,
    required String description,
    required String imagePath,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? Colors.green : Colors.grey.shade300,
              width: isSelected ? 2 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Image.asset(
                imagePath,
                width: 50,
              ),
              const SizedBox(width: 4),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    description,
                    style: const TextStyle(
                      fontSize: 7,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget baris ringkasan pembayaran
  Widget _buildSummaryRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
          Text(value, style: TextStyle(fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
        ],
      ),
    );
  }

  // Popup QR untuk pembayaran Non-Tunai
  Widget _buildQrPopup(BuildContext context) {
    final minutes = (_qrSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (_qrSeconds % 60).toString().padLeft(2, '0');
    return Center(
      child: Material(
        color: Colors.black.withOpacity(0.2),
        child: Center(
          child: Container(
            width: 300,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Payment',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
                const SizedBox(height: 12),
                // Ganti ke .jpg sesuai asset terbaru
                Image.asset('assets/images/qris-qr.png', width: 140, height: 140),
                const SizedBox(height: 12),
                const Text(
                  'Scan Here!',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Time occurs: '),
                    Text(
                      '$minutes:$seconds',
                      style: const TextStyle(
                        color: Color(0xFF22A45D),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF22A45D),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: _onQrComplete,
                    child: const Text('Complete', style: TextStyle(fontSize: 16)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Screen sukses pembayaran (Tunai & Non-Tunai)
  Widget _buildSuccessScreen() {
    if (selectedPayment == 'Tunai') {
      // Sukses Tunai (warna coklat muda)
      return Scaffold(
        backgroundColor: const Color(0xFFF3CB8E),
        body: SafeArea(
          child: Stack(
            children: [
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 120,
                      height: 120,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Icon(Icons.check, color: Color(0xFFF3CB8E), size: 70),
                      ),
                    ),
                    const SizedBox(height: 32),
                    const Text(
                      'We received your order',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Please go to the cashier!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 24,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: _goToHistory,
                      child: const Text(
                        'Go to History',
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }
    // Sukses Non-Tunai (warna hijau)
    return Scaffold(
      backgroundColor: const Color(0xFF22A45D), // Handai green
      body: SafeArea(
        child: Stack(
          children: [
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Icon(Icons.check, color: Color(0xFF22A45D), size: 70),
                    ),
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    'Payment Successful',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Thank you for buying\nour product!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 24,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: _goToHistory,
                    child: const Text(
                      'Go to History',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Screen gagal pembayaran (belum dipakai, bisa dikembangkan)
  Widget _buildFailureScreen() {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.cancel, color: Colors.red, size: 80),
            const SizedBox(height: 24),
            const Text('Payment Failed', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('Please try again or change payment method!'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _retryPayment,
              child: const Text('Re-Pay'),
            ),
          ],
        ),
      ),
    );
  }
}
