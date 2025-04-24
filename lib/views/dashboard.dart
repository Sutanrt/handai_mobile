import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../utils/config.dart';
import 'package:flutter_svg/flutter_svg.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _selectedIndex = 0;
  List<dynamic> products = [];
  List<Map<String, dynamic>> cart = [];
  int selectedStoreId = 1;

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  Future<void> _fetchProducts() async {
    final url = '${Config.baseUrl}/api/stores/$selectedStoreId/products';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      setState(() {
        products = data;
      });
    } else {
      throw Exception('Failed to load products');
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    const customGreen = Color(0xFF0C9044);
    const customGrey = Color(0xFF3A3A3A);

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              automaticallyImplyLeading: false,
              expandedHeight: MediaQuery.of(context).size.height / 3,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  color: customGrey,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 35,
                            vertical: 50,
                          ),
                          decoration: BoxDecoration(
                            color: customGreen,
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: SvgPicture.asset(
                            'assets/handai-text-logo-wrapped-light.svg',
                            width: 80,
                            height: 80,
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.store, color: Colors.white),
                            const SizedBox(width: 8),
                            const Text(
                              'Lokasi: ',
                              style: TextStyle(color: Colors.white),
                            ),
                            DropdownButton<int>(
                              value: selectedStoreId,
                              dropdownColor: Colors.white,
                              icon: const Icon(
                                Icons.arrow_drop_down,
                                color: Colors.white,
                              ),
                              underline: Container(),
                              items: const [
                                DropdownMenuItem(
                                  value: 1,
                                  child: Text(
                                    "GKU",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                                DropdownMenuItem(
                                  value: 2,
                                  child: Text(
                                    "MSU",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ],
                              onChanged: (value) {
                                if (value != null) {
                                  setState(() {
                                    selectedStoreId = value;
                                  });
                                  _fetchProducts();
                                }
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            SliverList(
              delegate: SliverChildListDelegate([
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                        ),
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      final product = products[index];
                      final name = product['name'] ?? 'No Name';
                      final image = 'assets/Produk/${product['image']}';
                      final variants =
                          product['variants'] as List<dynamic>? ?? [];

                      int displayPrice = 0;

                      if (variants.isNotEmpty) {
                        variants.sort(
                          (a, b) =>
                              (a['price'] as int).compareTo(b['price'] as int),
                        );

                        final cheapest = variants.first;

                        final isPromo =
                            cheapest['is_promo']?.toString().toLowerCase() ==
                            'yes';
                        final int basePrice = cheapest['price'] ?? 0;
                        final int discount = cheapest['price_discount'] ?? 0;

                        displayPrice =
                            isPromo ? (basePrice - discount) : basePrice;
                      }

                      return MenuCard(
                        name,
                        image,
                        price: displayPrice,
                        variants: variants,
                        onAddToCart: (item) {
                          setState(() {
                            cart.add(item);
                          });
                        },
                      );
                    },
                  ),
                ),
              ]),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: customGreen,
        unselectedItemColor: Colors.grey,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'History'),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle),
            label: 'Profile',
          ),
        ],
      ),
      bottomSheet:
          cart.isNotEmpty
              ? Container(
                color: const Color(0xFF0C9044),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${cart.fold<int>(0, (sum, item) => sum + (item['qty'] as int))} Item',
                      style: const TextStyle(color: Colors.white),
                    ),
                    Text(
                      'Rp ${cart.fold<int>(0, (sum, item) => sum + ((item['price'] as int) * (item['qty'] as int)))}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              )
              : null,
    );
  }
}

class MenuCard extends StatelessWidget {
  final String title;
  final String imagePath;
  final int price;
  final List<dynamic> variants;
  final Function(Map<String, dynamic>) onAddToCart;

  const MenuCard(
    this.title,
    this.imagePath, {
    super.key,
    required this.price,
    required this.variants,
    required this.onAddToCart,
  });

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
          Image.asset(
            imagePath,
            height: 80,
            errorBuilder: (context, error, stackTrace) {
              return const Icon(Icons.error, size: 80);
            },
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text('Rp. $price'),
          const SizedBox(height: 8),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0C9044),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                isScrollControlled: true,
                builder:
                    (context) => OrderModal(
                      title: title,
                      variants: variants,
                      onAddToCart: onAddToCart,
                    ),
              );
            },

            child: const Text('ADD +', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

class OrderModal extends StatefulWidget {
  final String title;
  final List<dynamic> variants;
  final Function(Map<String, dynamic>) onAddToCart;

  const OrderModal({
    super.key,
    required this.title,
    required this.variants,
    required this.onAddToCart,
  });

  @override
  State<OrderModal> createState() => _OrderModalState();
}

class _OrderModalState extends State<OrderModal> {
  int quantity = 1;
  String selectedSize = 'Medium';

  late Map<String, int> prices;

  @override
  void initState() {
    super.initState();

    final sorted = List.from(widget.variants)
      ..sort((a, b) => (a['price'] as int).compareTo(b['price'] as int));

    prices = {
      'Small': _getFinalPrice(sorted[0]),
      'Medium':
          sorted.length > 1
              ? _getFinalPrice(sorted[1])
              : _getFinalPrice(sorted[0]),
      'Large':
          sorted.length > 2
              ? _getFinalPrice(sorted[2])
              : _getFinalPrice(sorted.last),
    };
  }

  int _getFinalPrice(Map variant) {
    final base = variant['price'] ?? 0;
    final discount = variant['price_discount'] ?? 0;
    final isPromo = (variant['is_promo']?.toString().toLowerCase() == 'yes');
    return isPromo ? (base - discount) : base;
  }

  @override
  Widget build(BuildContext context) {
    int price = prices[selectedSize] ?? 0;

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Wrap(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Rp ${price * quantity}',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const Divider(height: 30),
          const Text('Type', style: TextStyle(fontWeight: FontWeight.bold)),
          Column(
            children:
                prices.entries.map((entry) {
                  return RadioListTile(
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [Text(entry.key), Text('Rp ${entry.value}')],
                    ),
                    value: entry.key,
                    groupValue: selectedSize,
                    onChanged: (value) {
                      setState(() {
                        selectedSize = value!;
                      });
                    },
                  );
                }).toList(),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: () {
                  if (quantity > 1) setState(() => quantity--);
                },
                icon: const Icon(Icons.remove),
              ),
              Text('$quantity', style: const TextStyle(fontSize: 16)),
              IconButton(
                onPressed: () {
                  setState(() => quantity++);
                },
                icon: const Icon(Icons.add),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0C9044),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              onPressed: () {
                widget.onAddToCart({
                  'title': widget.title,
                  'size': selectedSize,
                  'qty': quantity,
                  'price': prices[selectedSize],
                });
                Navigator.pop(context);
              },
              child: const Text('ADD +', style: TextStyle(color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}
