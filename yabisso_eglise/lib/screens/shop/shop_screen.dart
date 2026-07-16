import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class ShopScreen extends StatefulWidget {
  const ShopScreen({super.key});

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
  String _selectedCategory = 'all';
  final List<Map<String, dynamic>> _cart = [];

  static const _categories = {
    'all': 'Tous',
    'books': 'Livres',
    'audio': 'Audio',
    'merch': 'Articles',
    'gifts': 'Cadeaux',
  };

  static const _products = [
    {'id': '1', 'name': 'Bible du croyant', 'category': 'books', 'price': 15000.0, 'description': 'Bible annotée en français', 'icon': Icons.book},
    {'id': '2', 'name': 'Cahier de prières', 'category': 'books', 'price': 5000.0, 'description': 'Guide de prière quotidienne', 'icon': Icons.menu_book},
    {'id': '3', 'name': 'CD Louange 2024', 'category': 'audio', 'price': 3000.0, 'description': 'Album de louange Yabisso', 'icon': Icons.album},
    {'id': '4', 'name': 'USB Message pastoral', 'category': 'audio', 'price': 5000.0, 'description': 'Compilation de messages', 'icon': Icons.usb},
    {'id': '5', 'name': 'T-shirt Yabisso', 'category': 'merch', 'price': 8000.0, 'description': 'T-shirt officiel de l\'église', 'icon': Icons.checkroom},
    {'id': '6', 'name': 'Mug Paroles de Vie', 'category': 'merch', 'price': 4000.0, 'description': 'Mug avec versets bibliques', 'icon': Icons.coffee},
    {'id': '7', 'name': 'Pendentif croix', 'category': 'gifts', 'price': 12000.0, 'description': 'Pendentif en argent', 'icon': Icons.diamond},
    {'id': '8', 'name': 'Horloge murale église', 'category': 'gifts', 'price': 25000.0, 'description': 'Horloge officielle', 'icon': Icons.access_time},
  ];

  List<Map<String, dynamic>> get _filteredProducts {
    if (_selectedCategory == 'all') return _products;
    return _products.where((p) => p['category'] == _selectedCategory).toList();
  }

  void _addToCart(Map<String, dynamic> product) {
    setState(() {
      final existing = _cart.indexWhere((item) => item['id'] == product['id']);
      if (existing >= 0) {
        _cart[existing]['quantity'] = (_cart[existing]['quantity'] as int) + 1;
      } else {
        _cart.add({...product, 'quantity': 1});
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${product['name']} ajouté au panier'),
        backgroundColor: AppColors.secondary,
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _removeFromCart(int index) {
    setState(() => _cart.removeAt(index));
  }

  double get _total => _cart.fold(0, (sum, item) => sum + (item['price'] as double) * (item['quantity'] as int));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        title: const Text('Boutique'),
        actions: [
          if (_cart.isNotEmpty)
            Badge(
              label: Text('${_cart.length}', style: const TextStyle(color: Colors.white, fontSize: 10)),
              child: IconButton(
                icon: const Icon(Icons.shopping_cart),
                onPressed: () => _showCartSheet(),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: _categories.entries.map((entry) {
                final isSelected = _selectedCategory == entry.key;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(entry.value),
                    selected: isSelected,
                    onSelected: (_) => setState(() => _selectedCategory = entry.key),
                    backgroundColor: Colors.white,
                    selectedColor: AppColors.primary,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : AppColors.onSurface,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(12),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.78,
              ),
              itemCount: _filteredProducts.length,
              itemBuilder: (context, index) {
                final product = _filteredProducts[index];
                return Card(
                  clipBehavior: Clip.antiAlias,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [AppColors.secondaryContainer.withValues(alpha: 0.3), AppColors.secondaryContainer.withValues(alpha: 0.1)],
                            ),
                          ),
                          child: Icon(product['icon'] as IconData, color: AppColors.secondary, size: 40),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              product['name'] as String,
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              product['description'] as String,
                              style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                              maxLines: 1,
                            ),
                            const SizedBox(height: 4),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '${(product['price'] as double).toInt()} FC',
                                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.secondary),
                                ),
                                GestureDetector(
                                  onTap: () => _addToCart(product),
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: AppColors.primary,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(Icons.add, color: Colors.white, size: 16),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showCartSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          padding: const EdgeInsets.all(20),
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.7,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Panier', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              if (_cart.isEmpty)
                const Text('Votre panier est vide')
              else ...[
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: _cart.length,
                    itemBuilder: (context, index) {
                      final item = _cart[index];
                      return ListTile(
                        title: Text(item['name']),
                        subtitle: Text('${item['quantity']}x ${item['price']} FC'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove_circle_outline, size: 20),
                              onPressed: () {
                                setModalState(() {
                                  if (item['quantity'] > 1) {
                                    item['quantity'] = (item['quantity'] as int) - 1;
                                  } else {
                                    _cart.removeAt(index);
                                  }
                                });
                              },
                            ),
                            Text('${item['quantity']}'),
                            IconButton(
                              icon: const Icon(Icons.add_circle_outline, size: 20),
                              onPressed: () {
                                setModalState(() {
                                  item['quantity'] = (item['quantity'] as int) + 1;
                                });
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    Text(
                      '${_total.toInt()} FC',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.secondary),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Commande confirmée!'), backgroundColor: Colors.green),
                      );
                      setState(() => _cart.clear());
                    },
                    child: const Text('Passer la commande'),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
