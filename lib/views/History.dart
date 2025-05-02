import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final orders = [
      {
        'type': 'Dine In',
        'items': 2,
        'price': 26000,
        'status': 'progressing',
        'date': '29 March 2025',
      },
      {
        'type': 'Delivery',
        'items': 2,
        'price': 26000,
        'status': 'completed',
        'date': '29 March 2025',
      },
      {
        'type': 'Delivery',
        'items': 2,
        'price': 26000,
        'status': 'completed',
        'date': '29 March 2025',
      },
      {
        'type': 'Dine In',
        'items': 1,
        'price': 10000,
        'status': 'completed',
        'date': '9 February 2025',
      },
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'History',
                    style: TextStyle(
                      color: Colors.green,
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const Spacer(),
                  SvgPicture.asset('assets/images/handai-logo-filled-hijau.svg', width: 40),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.separated(
                  itemCount: orders.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final order = orders[index];
                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Image.asset('assets/images/MATCHA.png', width: 40, height: 40),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    order['type'] as String,
                                    style: const TextStyle(
                                      color: Colors.green,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  Text(
                                    '${order['items']} items',
                                    style: const TextStyle(fontSize: 13, color: Colors.black87),
                                  ),
                                  Text(
                                    'Rp. ${order['price']}',
                                    style: const TextStyle(fontSize: 13, color: Colors.black87),
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                _buildStatusBadge(order['status'] as String),
                                const SizedBox(height: 8),
                                Text(
                                  order['date'] as String,
                                  style: const TextStyle(fontSize: 13, color: Colors.black54),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    String text;
    switch (status) {
      case 'progressing':
        color = const Color(0xFFF3CB8E);
        text = 'progressing';
        break;
      case 'completed':
      default:
        color = const Color(0xFF22A45D);
        text = 'completed';
        break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
} 