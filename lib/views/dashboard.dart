import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'dart:convert';
import 'dart:typed_data';
import '../utils/config.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:html' as html;

const double maxDistanceKm = 20.0;

class DashboardPage extends StatefulWidget {
  const DashboardPage({Key? key}) : super(key: key);

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class Variant {
  final int id;
  final int price;
  final int priceDiscount;
  final String isPromo;
  final int finalPrice;
  final int stock;
  final bool isSoldOut;
  final int quantity;
  final List<Map<String, String>> options;

  Variant({
    required this.id,
    required this.price,
    required this.priceDiscount,
    required this.isPromo,
    required this.finalPrice,
    required this.stock,
    required this.isSoldOut,
    required this.quantity,
    required this.options,
  });

  factory Variant.fromJson(Map<String, dynamic> json) => Variant(
    id: json['id'],
    price: json['price'],
    priceDiscount: json['price_discount'],
    isPromo: json['isPromo'],
    finalPrice: json['final_price'],
    stock: json['stock'],
    isSoldOut: json['isSoldOut'],
    quantity: json['quantity'],
    options: List<Map<String, String>>.from(
      (json['variant_options'] as List).map(
        (o) => {
          'attribute': o['attribute'] as String,
          'value': o['value'] as String,
        },
      ),
    ),
  );
}

class Product {
  final int id;
  final String name;
  final String imageUrlMobile;
  final bool isPromo;
  final bool isSoldOut;
  final int price;
  final int? normalPrice;
  final List<Variant> variants;

  Product({
    required this.id,
    required this.name,
    required this.imageUrlMobile,
    required this.isPromo,
    required this.isSoldOut,
    required this.price,
    this.normalPrice,
    required this.variants,
  });

  factory Product.fromJson(Map<String, dynamic> json) => Product(
    id: json['id'],
    name: json['name'],
    imageUrlMobile: json['image_url_mobile'],
    isPromo: json['isPromo'] == 'yes',
    isSoldOut: json['isSoldOut'],
    price: json['price'],
    normalPrice: json['normal_price'],
    variants:
        (json['variants'] as List).map((v) => Variant.fromJson(v)).toList(),
  );
}

class CachedImageMemory extends StatefulWidget {
  final String imageUrl;
  final double? width, height;
  final BoxFit? fit;

  const CachedImageMemory({
    Key? key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit,
  }) : super(key: key);

  @override
  _CachedImageMemoryState createState() => _CachedImageMemoryState();
}

class _CachedImageMemoryState extends State<CachedImageMemory> {
  Uint8List? _bytes;
  bool _loading = true;

  String get _storageKey => 'img_cache_${widget.imageUrl}';

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  Future<void> _loadImage() async {
    // 1. Cek dulu di localStorage (web only)
    if (kIsWeb) {
      final stored = html.window.localStorage[_storageKey];
      if (stored != null) {
        final bytes = base64Decode(stored);
        setState(() {
          _bytes = bytes;
          _loading = false;
        });
        return;
      }
    }

    // 2. Kalau gak ada, fetch dari network
    try {
      final resp = await http.get(Uri.parse(widget.imageUrl));
      if (resp.statusCode == 200) {
        final bytes = resp.bodyBytes;
        // 3. Simpan di localStorage
        if (kIsWeb) {
          final encoded = base64Encode(bytes);
          html.window.localStorage[_storageKey] = encoded;
        }
        setState(() {
          _bytes = bytes;
          _loading = false;
        });
      } else {
        setState(() => _loading = false);
      }
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_bytes == null) {
      return const Icon(Icons.broken_image, size: 80);
    }
    return Image.memory(
      _bytes!,
      width: widget.width,
      height: widget.height,
      fit: widget.fit,
    );
  }
}

class _DashboardPageState extends State<DashboardPage> {
  int _selectedIndex = 0;
  List<Map<String, dynamic>> stores = [];
  List<Product> products = [];
  List<Map<String, dynamic>> cart = [];
  int? selectedStoreId;
  bool loadingStores = true;
  bool loadingProducts = false;
  double? deviceLat;
  double? deviceLng;

  @override
  void initState() {
    super.initState();
    _initLocationAndStores();
  }

  Future<void> _initLocationAndStores() async {
    try {
      var perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      if (!mounted) return;
      setState(() {
        deviceLat = pos.latitude;
        deviceLng = pos.longitude;
      });

      final url =
          '${Config.baseUrl}/api/stores/nearby?lat=${pos.latitude}&lng=${pos.longitude}';
      final resp = await http.get(Uri.parse(url));
      if (resp.statusCode != 200) throw Exception('Server error');

      final data = json.decode(resp.body) as List<dynamic>;
      final mapped =
          data.map<Map<String, dynamic>>((s) {
            final raw = s['distance'];
            final dist =
                (raw != null) ? (raw as num).toDouble() : double.infinity;
            return {
              'id': s['id'] as int,
              'name': s['store_name'] as String,
              'distance': dist,
            };
          }).toList();

      if (!mounted) return;
      setState(() {
        stores = mapped;
        final inRange =
            stores.where((s) => s['distance'] <= maxDistanceKm).toList();
        if (inRange.isNotEmpty) {
          selectedStoreId = inRange.first['id'] as int;
          _fetchProducts();
        }
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal load store: $e')));
      }
    } finally {
      if (mounted) setState(() => loadingStores = false);
    }
  }

  Future<void> _fetchProducts() async {
    if (selectedStoreId == null) return;
    setState(() => loadingProducts = true);

    final url = '${Config.baseUrl}/api/stores/$selectedStoreId/products';
    final resp = await http.get(Uri.parse(url));

    if (resp.statusCode == 200) {
      final data = json.decode(resp.body) as Map<String, dynamic>;
      final rawProducts = data['products'] as List;
      setState(() {
        products =
            rawProducts
                .map((p) => Product.fromJson(p as Map<String, dynamic>))
                .toList();
        loadingProducts = false;
      });
    } else {
      setState(() => loadingProducts = false);
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
                        // Logo
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
                        if (deviceLat != null && deviceLng != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            'Your location: '
                            '${deviceLat!.toStringAsFixed(6)}, '
                            '${deviceLng!.toStringAsFixed(6)}',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                        ],
                        loadingStores
                            ? const CircularProgressIndicator(
                              color: Colors.white,
                            )
                            : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.store, color: Colors.white),
                                const SizedBox(width: 8),
                                const Text(
                                  'Pilih Store: ',
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
                                  items:
                                      stores.map((s) {
                                        final id = s['id']!;
                                        final name = s['name']!;
                                        final dist = s['distance']!;
                                        final enabled = dist <= maxDistanceKm;
                                        return DropdownMenuItem<int>(
                                          value: id,
                                          enabled: enabled,
                                          child: Text(
                                            '$name (${dist.toStringAsFixed(2)} km)',
                                            style: TextStyle(
                                              color:
                                                  enabled
                                                      ? Colors.black
                                                      : Colors.grey,
                                            ),
                                          ),
                                        );
                                      }).toList(),
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

            if (loadingProducts)
              SliverFillRemaining(
                hasScrollBody: false,
                child: Center(child: CircularProgressIndicator()),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.7,
                  ),
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final product = products[index];

                    final proxyUrl =
                        product.imageUrlMobile.isNotEmpty
                            ? '${Config.baseUrl}/api/image-proxy?file=${Uri.encodeComponent(product.imageUrlMobile)}'
                            : null;

                    final imageWidget =
                        proxyUrl != null
                            ? Image.network(
                              proxyUrl,
                              height: 80,
                              fit: BoxFit.cover,
                              errorBuilder:
                                  (_, __, ___) => Image.asset(
                                    'assets/Produk/Image-not-found.png',
                                    height: 80,
                                    fit: BoxFit.cover,
                                  ),
                            )
                            : Image.asset(
                              'assets/Produk/Image-not-found.png',
                              height: 80,
                              fit: BoxFit.cover,
                            );

                    return MenuCard(
                      title: product.name,
                      imageWidget: imageWidget,
                      price: product.price,
                      variants: product.variants,
                      onAddToCart: (item) => setState(() => cart.add(item)),
                    );
                  }, childCount: products.length),
                ),
              ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: customGreen,
        unselectedItemColor: Colors.grey,
        items: const [
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
                color: customGreen,
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

class NetworkImageBypass extends StatefulWidget {
  final String imageUrl;
  const NetworkImageBypass({Key? key, required this.imageUrl})
    : super(key: key);

  @override
  _NetworkImageBypassState createState() => _NetworkImageBypassState();
}

class _NetworkImageBypassState extends State<NetworkImageBypass> {
  Uint8List? _bytes;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchBytes();
  }

  Future<void> _fetchBytes() async {
    try {
      final resp = await http.get(Uri.parse(widget.imageUrl));
      if (resp.statusCode == 200) {
        setState(() {
          _bytes = resp.bodyBytes;
          _loading = false;
        });
      } else {
        setState(() => _loading = false);
      }
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const CircularProgressIndicator();
    if (_bytes == null) return const Icon(Icons.broken_image, size: 80);
    return Image.memory(_bytes!, fit: BoxFit.cover);
  }
}

class MenuCard extends StatelessWidget {
  final String title;
  final Widget imageWidget;
  final int price;
  final List<Variant> variants;
  final void Function(Map<String, dynamic>) onAddToCart;

  const MenuCard({
    Key? key,
    required this.title,
    required this.imageWidget,
    required this.price,
    required this.variants,
    required this.onAddToCart,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(2, 2)),
        ],
      ),
      child: Column(
        children: [
          SizedBox(height: 80, child: Center(child: imageWidget)),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text('Rp. $price', style: const TextStyle(fontSize: 12)),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0C9044),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                  ),
                  isScrollControlled: true,
                  builder:
                      (_) => OrderModal(
                        title: title,
                        variants: variants,
                        onAddToCart: onAddToCart,
                      ),
                );
              },
              child: const Text('ADD +', style: TextStyle(color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}

class OrderModal extends StatefulWidget {
  final String title;
  final List<Variant> variants;
  final void Function(Map<String, dynamic>) onAddToCart;

  const OrderModal({
    Key? key,
    required this.title,
    required this.variants,
    required this.onAddToCart,
  }) : super(key: key);

  @override
  State<OrderModal> createState() => _OrderModalState();
}

class _OrderModalState extends State<OrderModal> {
  int quantity = 1;
  int? selectedVariantId;

  @override
  void initState() {
    super.initState();
    if (widget.variants.isNotEmpty) {
      selectedVariantId = widget.variants.first.id;
    }
  }

  @override
  Widget build(BuildContext context) {
    final variants = widget.variants;
    if (variants.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(20),
        child: Text('Tidak ada variant tersedia.'),
      );
    }

    final sel = variants.firstWhere((v) => v.id == selectedVariantId);
    final basePrice = sel.price;
    final discount = sel.priceDiscount;
    final isPromo = sel.isPromo == 'yes';
    final finalPrice = isPromo ? basePrice - discount : basePrice;
    final summary = sel.options
        .map((o) => '${o['attribute']}: ${o['value']}')
        .join(', ');

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        left: 20,
        right: 20,
        top: 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
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

          // Total price
          Text(
            'Rp ${finalPrice * quantity}',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const Divider(height: 30),

          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Pilih Variant:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          ...variants.map((v) {
            final promo = v.isPromo == 'yes';
            final fp = promo ? v.price - v.priceDiscount : v.price;
            final opts = v.options
                .map((o) => '${o['attribute']}: ${o['value']}')
                .join(', ');
            return RadioListTile<int>(
              title: Text(
                '$opts — Rp $fp${promo ? ' (disc Rp ${v.priceDiscount})' : ''}',
                style:
                    promo
                        ? const TextStyle(color: const Color(0xFF0C9044))
                        : null,
              ),
              value: v.id,
              groupValue: selectedVariantId,
              onChanged: (val) => setState(() => selectedVariantId = val),
            );
          }),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.remove),
                onPressed: () {
                  if (quantity > 1) setState(() => quantity--);
                },
              ),
              Text('$quantity', style: const TextStyle(fontSize: 16)),
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: () => setState(() => quantity++),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Add to cart button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0C9044),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              onPressed: () {
                widget.onAddToCart({
                  'product_id': sel.id,
                  'variant_id': sel.id,
                  'product_name': widget.title,
                  'variant_summary': summary,
                  'qty': quantity,
                  'price': finalPrice,
                  'normal_price': basePrice,
                });
                Navigator.pop(context);
              },
              child: const Text(
                'ADD TO CART',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
