import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'Payment.dart';
import 'dashboard.dart';

class BasketPage extends StatefulWidget {
  final List<Map<String, dynamic>> cart;

  const BasketPage({Key? key, required this.cart}) : super(key: key);

  @override
  State<BasketPage> createState() => _BasketPageState();
}

class _BasketPageState extends State<BasketPage> {
  String selectedOption = 'Pickup';
  String selectedLocation = 'Pilih Lokasi';
  String deliveryAddress = '';

  void _selectLocation() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        List<String> locations = ['Store GKU', 'Store MSU'];
        return ListView.builder(
          itemCount: locations.length,
          itemBuilder: (context, index) {
            return ListTile(
              title: Text(locations[index]),
              onTap: () {
                setState(() {
                  selectedLocation = locations[index];
                });
                Navigator.pop(context);
              },
            );
          },
        );
      },
    );
    
  }
    Widget _buildPaymentRow(String label, String amount, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              fontSize: 16,
            ),
          ),
          Text(
            amount,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    final totalPrice = widget.cart.fold<int>(
      0,
      (sum, item) => sum + ((item['price'] as int) * (item['qty'] as int)),
    );

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea( 
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const DashboardPage()),
                  );
                },
                icon: Icon(Icons.arrow_back),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  SvgPicture.asset('assets/images/handai-logo-filled-hijau.svg', width: 40),
                ],
              ),
              const Text(
                'Location',
                style: TextStyle(
                  color: Colors.green,
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 30),
              Row(
                children: [
                  _buildOptionCard(
                    title: 'Pickup',
                    description: 'Dapat diambil di store',
                    imagePath: 'assets/images/handai-dinein.png',
                    isSelected: selectedOption == 'Pickup',
                    onTap: () {
                      setState(() {
                        selectedOption = 'Dine In';
                      });
                    },
                  ),
                  const SizedBox(width: 15),
                  _buildOptionCard(
                    title: 'Delivery',
                    description: 'Dapat di kirim ke alamatmu',
                    imagePath: 'assets/images/handai-delivery.png',
                    isSelected: selectedOption == 'Delivery',
                    onTap: () {
                      setState(() {
                        selectedOption = 'Delivery';
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 15),

              Card(
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Image.asset('assets/images/image 300.png'),
                          const SizedBox(width: 8),
                          const Text(
                            'Location',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Spacer(),
                          if (selectedOption != 'Delivery')
                            IconButton(
                              onPressed: _selectLocation,
                              icon: Icon(Icons.arrow_drop_down),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      if (selectedOption == 'Delivery')
                        TextField(
                          onChanged: (value) {
                            setState(() {
                              deliveryAddress = value;
                            });
                          },
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: 'Masukkan alamat pengiriman',
                          ),
                        )
                      else
                        Text(selectedLocation),
                    ],
                  ),
                ),
              ),

              Divider(),

              const Text(
                'Order Details',
                style: TextStyle(
                  color: Colors.green,
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 5),

              Expanded(
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: AlwaysScrollableScrollPhysics(), // Biar ikut scroll parent
                  itemCount: widget.cart.length,
                  separatorBuilder: (context, index) => Divider(
                    thickness: 1,
                    color: Colors.grey.shade300,
                  ),
                  itemBuilder: (context, index) {
                    final item = widget.cart[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.asset(
                              'assets/images/MATCHA.png',
                              width: 70,
                              height: 70,
                              fit: BoxFit.cover,
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item['product_name'],
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  item['variant_summary'] ?? '',
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 14,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    RichText(
                                      text: TextSpan(
                                        children: [
                                          TextSpan(
                                            text: 'Rp ${item['price']}',
                                            style: TextStyle(
                                              color: Colors.redAccent,
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          TextSpan(
                                            text: '  x${item['qty']}',
                                            style: TextStyle(
                                              color: Colors.grey.shade700,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    IconButton(
                                      onPressed: () {
                                        // Tambahkan fitur edit di sini
                                      },
                                      icon: Icon(Icons.edit, size: 20, color: Colors.grey),
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 20),
              Divider(),

              // Voucher Redeem
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Voucher Redeem',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: 'enter here',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () {
                          // Logika submit voucher nanti di sini
                        },
                        child: const Text('submit'),
                      )
                    ],
                  )
                ],
              ),

              const SizedBox(height: 30),
              Divider(),

              // Payment Summary
              const Text(
                'Payment Summary',
                style: TextStyle(
                  color: Colors.green,
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 10),
              _buildPaymentRow('Price', 'Rp. $totalPrice'),
              _buildPaymentRow('Delivery fee', 'Rp. 0'),
              _buildPaymentRow('Discount', 'Rp. 0'),
              const SizedBox(height: 10),
              _buildPaymentRow(
                'Total Price',
                'Rp. $totalPrice',
                isBold: true,
              ),

              const SizedBox(height: 20),
              SizedBox(
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
                  onPressed: () {
                    Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const PaymentMethodPage()),
                  );
                  },
                  child: const Text(
                    'Select Payment',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

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
}
