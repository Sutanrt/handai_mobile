import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dashboard.dart';

class BasketPage extends StatefulWidget {
  const BasketPage({super.key});

  @override
  State<BasketPage> createState() => _BasketPageState();
}

class _BasketPageState extends State<BasketPage> {
  String selectedOption = 'Dine In';
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
                    title: 'Dine In',
                    description: 'Dapat diambil di store',
                    imagePath: 'assets/images/handai-dinein.png',
                    isSelected: selectedOption == 'Dine In',
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
                              icon: Icon(Icons.edit),
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

              Card(
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Image.asset(
                            'assets/images/MATCHA.png',
                            width: 50,
                            height: 130,
                          ),
                          SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Matcha Latte',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 22,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Text(
                                'Size: Medium',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w300,
                                ),
                              ),
                              Row(
                                children: [
                                  Text(
                                    'Rp 13.000',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 20,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(width: 100),
                                  IconButton(
                                    onPressed: () {},
                                    icon: Icon(Icons.edit),
                                  )
                                ],
                              )
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
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
              _buildPaymentRow('Price', 'Rp. 26.000'),
              _buildPaymentRow('Delivery fee', 'Rp. 0'),
              _buildPaymentRow('Discount', 'Rp. 0'),
              const SizedBox(height: 10),
              _buildPaymentRow(
                'Total Price',
                'Rp. 26.000',
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
                    // Aksi checkout
                  },
                  child: const Text(
                    'Checkout',
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
