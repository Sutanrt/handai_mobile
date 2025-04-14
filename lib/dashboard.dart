import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'basket.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.green,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      SvgPicture.asset(
                        'assets/handai-logo-light.svg',
                        width: 40,
                        height: 40,
                      ),
                      const SizedBox(width: 8),
                      SvgPicture.asset(
                        'assets/handai-text-light.svg',
                        width: 120,
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.shopping_cart, color: Colors.white),
                    onPressed: () {
                      Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const BasketPage(),
                      ),
                    );
                    },
                  ),
                ],
              ),
            ),

            // Search Bar
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const TextField(
                  decoration: InputDecoration(
                    hintText: 'Search',
                    border: InputBorder.none,
                    icon: Icon(Icons.search),
                  ),
                ),
              ),
            ),

            // Grid Menu
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  children: const [
                    // Semua pakai SVG
                    MenuCard('Choco Latte', 'assets/Produk/Choco Latte.svg'),
                    MenuCard(
                      'Kopi Susu Gula Aren',
                      'assets/Produk/Kopi Susu Gula Aren.svg',
                    ),
                    MenuCard('Matcha Latte', 'assets/Produk/Matcha Latte.svg'),
                    MenuCard(
                      'Red Velvet Latte',
                      'assets/Produk/Red Velvet Latte.svg',
                    ),
                    MenuCard('Sparklime', 'assets/Produk/SPARKLIME.svg'),
                    MenuCard('Susu Kurma', 'assets/Produk/SUSU KURMA.svg'),
                    MenuCard('Taro Latte', 'assets/Produk/TARO LATTE.svg'),
                    MenuCard('Vanilla Regal', 'assets/Produk/VANILA REGAL.svg'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MenuCard extends StatelessWidget {
  final String title;
  final String imagePath;

  const MenuCard(this.title, this.imagePath, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(2, 2)),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(imagePath, height: 80),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const Text('Lorem sum lorem sum', textAlign: TextAlign.center),
          const SizedBox(height: 8),
          const Text('Rp. 10.000'),
          const SizedBox(height: 8),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () {
              // TODO: Tambahkan aksi ke keranjang
            },
            child: const Text('ADD +'),
          ),
        ],
      ),
    );
  }
}
