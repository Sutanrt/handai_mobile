import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _selectedIndex = 0;
  List<Map<String, dynamic>> cart = [];

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
                      children: [
                        Container(
                          margin: const EdgeInsets.only(top: 16, bottom: 16),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: customGreen,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SvgPicture.asset(
                                'assets/handai-text-logo-wrapped-light.svg',
                                width: 40,
                                height: 40,
                              ),
                            ],
                          ),
                        ),
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
                  child: GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    children: [
                      MenuCard(
                        'Choco Latte',
                        'assets/Produk/Choco-Latte.png',
                        onAddToCart: (item) {
                          setState(() {
                            cart.add(item);
                          });
                        },
                      ),
                      MenuCard(
                        'Kopi Susu Gula Aren',
                        'assets/Produk/Kopi-Susu-Gula-Aren.png',
                        onAddToCart: (item) {
                          setState(() {
                            cart.add(item);
                          });
                        },
                      ),
                      MenuCard(
                        'Matcha Latte',
                        'assets/Produk/Matcha-Latte.png',
                        onAddToCart: (item) {
                          setState(() {
                            cart.add(item);
                          });
                        },
                      ),
                      MenuCard(
                        'Red Velvet Latte',
                        'assets/Produk/Red-Velvet-Latte.png',
                        onAddToCart: (item) {
                          setState(() {
                            cart.add(item);
                          });
                        },
                      ),
                      MenuCard(
                        'Sparklime',
                        'assets/Produk/SPARKLIME.png',
                        onAddToCart: (item) {
                          setState(() {
                            cart.add(item);
                          });
                        },
                      ),
                      MenuCard(
                        'Susu Kurma',
                        'assets/Produk/SUSU-KURMA.png',
                        onAddToCart: (item) {
                          setState(() {
                            cart.add(item);
                          });
                        },
                      ),
                      MenuCard(
                        'Taro Latte',
                        'assets/Produk/TARO-LATTE.png',
                        onAddToCart: (item) {
                          setState(() {
                            cart.add(item);
                          });
                        },
                      ),
                      MenuCard(
                        'Vanilla Regal',
                        'assets/Produk/VANILA-REGAL.png',
                        onAddToCart: (item) {
                          setState(() {
                            cart.add(item);
                          });
                        },
                      ),
                    ],
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
  final Function(Map<String, dynamic>) onAddToCart;

  const MenuCard(
    this.title,
    this.imagePath, {
    super.key,
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
          Image.asset(imagePath, height: 80),
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
                    (context) =>
                        OrderModal(title: title, onAddToCart: onAddToCart),
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
  final Function(Map<String, dynamic>) onAddToCart;

  const OrderModal({super.key, required this.title, required this.onAddToCart});

  @override
  State<OrderModal> createState() => _OrderModalState();
}

class _OrderModalState extends State<OrderModal> {
  int quantity = 1;
  String selectedSize = 'Medium';

  final Map<String, int> prices = {
    'Small': 10000,
    'Medium': 13000,
    'Large': 16000,
  };

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
          const Text('Lorem sum Lorem sum'),
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
