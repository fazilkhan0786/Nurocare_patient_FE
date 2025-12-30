// lib/patient_dashboard/coupon_store_page/coupon_store_page.dart
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:health_chatbot/common/app_background.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum FilterOption { none, gym, food, medication, equipment }

class CouponItem {
  final String id;
  final String imageUrl;
  final String title;
  final String description;
  final int price;
  int stock;
  final FilterOption category;

  CouponItem({
    required this.id,
    required this.imageUrl,
    required this.title,
    required this.description,
    required this.price,
    required this.stock,
    required this.category,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'imageUrl': imageUrl,
      'title': title,
      'description': description,
      'price': price,
      'stock': stock,
      'category': category.index,
    };
  }

  factory CouponItem.fromMap(Map<String, dynamic> map) {
    return CouponItem(
      id: map['id'],
      imageUrl: map['imageUrl'],
      title: map['title'],
      description: map['description'],
      price: map['price'],
      stock: map['stock'],
      category: FilterOption.values[map['category']],
    );
  }
}

class CouponStoreScreen extends StatefulWidget {
  final Function(int) onNavigate;
  const CouponStoreScreen({super.key, required this.onNavigate});

  @override
  State<CouponStoreScreen> createState() => _CouponStoreScreenState();
}

class _CouponStoreScreenState extends State<CouponStoreScreen> {
  late List<CouponItem> _allItems;
  late List<CouponItem> _filteredItems;
  int _userCareCoins = 0;

  String _searchQuery = '';
  FilterOption _selectedCategory = FilterOption.none;
  bool _sortPriceLowToHigh = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _allItems = [];
    _filteredItems = [];
    _loadInitialData();
    _searchController.addListener(() {
      _searchQuery = _searchController.text;
      _applyFilterAndSearch();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    final prefs = await SharedPreferences.getInstance();
    final int loadedCoins = prefs.getInt('care_coins') ?? 3690;

    List<CouponItem> loadedItems;
    final itemsJson = prefs.getString('coupon_items');
    if (itemsJson != null) {
      final List<dynamic> decodedItems = jsonDecode(itemsJson);
      loadedItems =
          decodedItems.map((item) => CouponItem.fromMap(item)).toList();
    } else {
      loadedItems = _getInitialCouponData();
      await _saveCouponData(loadedItems);
    }

    if (mounted) {
      setState(() {
        _userCareCoins = loadedCoins;
        _allItems = loadedItems;
        _filteredItems = List.from(_allItems);
      });
    }
  }

  Future<void> _saveCouponData(List<CouponItem> items) async {
    final prefs = await SharedPreferences.getInstance();
    final List<Map<String, dynamic>> itemsToSave =
        items.map((item) => item.toMap()).toList();
    await prefs.setString('coupon_items', jsonEncode(itemsToSave));
  }

  Future<void> _updateUserCoins(int newAmount) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('care_coins', newAmount);
    if (mounted) {
      setState(() {
        _userCareCoins = newAmount;
      });
    }
  }

  Future<void> _addCouponToWallet(CouponItem item) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> walletItems = prefs.getStringList('my_coupons') ?? [];
    if (!walletItems.contains(item.id)) {
      walletItems.add(item.id);
    }
    await prefs.setStringList('my_coupons', walletItems);
  }

  void _handlePurchase(CouponItem item) {
    // This logic is now inside the "Confirm Purchase" button's onPressed
    _addCouponToWallet(item).then((_) {
      Navigator.of(context).pop(); // Close the purchase dialog
      if (item.stock <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Sorry, this item is out of stock.'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      if (_userCareCoins >= item.price) {
        final newCoinAmount = _userCareCoins - item.price;
        _updateUserCoins(newCoinAmount);

        setState(() {
          final itemIndex = _allItems.indexWhere((i) => i.id == item.id);
          if (itemIndex != -1) {
            _allItems[itemIndex].stock--;
          }
        });
        _saveCouponData(_allItems);
        _applyFilterAndSearch();

        _showSuccessDialog();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content:
                Text('You do not have enough CareCoins for this purchase.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    });
  }

  void _applyFilterAndSearch() {
    List<CouponItem> tempItems = List.from(_allItems);
    if (_selectedCategory != FilterOption.none) {
      tempItems = tempItems
          .where((item) => item.category == _selectedCategory)
          .toList();
    }
    if (_searchQuery.isNotEmpty) {
      tempItems = tempItems
          .where((item) =>
              item.title.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
    }
    if (_sortPriceLowToHigh) {
      tempItems.sort((a, b) => a.price.compareTo(b.price));
    }
    if (mounted) {
      setState(() {
        _filteredItems = tempItems;
      });
    }
  }

  void _clearFilters() {
    setState(() {
      _searchController.clear();
      _searchQuery = '';
      _selectedCategory = FilterOption.none;
      _sortPriceLowToHigh = false;
    });
    _applyFilterAndSearch();
  }

  void _showPurchaseDialog(CouponItem item) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          contentPadding: const EdgeInsets.all(20),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Image.asset(
                  item.imageUrl,
                  height: 150,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => const SizedBox(
                      height: 150, child: Center(child: Icon(Icons.error))),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                item.title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                item.description,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14, color: Colors.black54),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Image.asset('assets/icons/coins.png',
                          width: 30, height: 30),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.price.toString(),
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Text(
                            'CareCoins',
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                    ],
                  ),
                  ElevatedButton(
                    onPressed: () => _handlePurchase(item),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF38B6FF),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                    ),
                    child: const Column(
                      children: [
                        Text('Confirm',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        Text('Purchase',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ],
              )
            ],
          ),
        );
      },
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: const BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Coupon Added',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Successful in wallet',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF38BDF8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                          widget.onNavigate(3);
                        },
                        child: const Text(
                          'See in wallet',
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: IconButton(
                  icon: const Icon(Icons.close),
                  splashRadius: 20,
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2EB5FA),
      appBar: _CustomAppBar(
        careCoins: _userCareCoins,
      ),
      body: Stack(
        children: [
          const AppBackground(),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  const Color(0xFF2EB5FA).withAlpha(150),
                  Colors.white.withAlpha(150),
                ],
              ),
            ),
          ),
          Column(
            children: [
              _buildSearchBar(),
              Expanded(
                child: _filteredItems.isEmpty
                    ? const Center(
                        child: Text(
                          'No items found.',
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        itemCount: _filteredItems.length,
                        itemBuilder: (context, index) {
                          final item = _filteredItems[index];
                          return _buildCouponCard(item);
                        },
                      ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    // --- FIX: Added Text Shadow to hintText ---
    const textShadow = [
      Shadow(blurRadius: 1.0, color: Colors.black26, offset: Offset(1, 1))
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 50,
              decoration: BoxDecoration(
                color: const Color(0xFF38B6FF),
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(350),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                style:
                    const TextStyle(color: Colors.white, shadows: textShadow),
                decoration: const InputDecoration(
                  hintText: 'Search.......',
                  hintStyle:
                      TextStyle(color: Colors.white70, shadows: textShadow),
                  prefixIcon: Icon(Icons.search, color: Colors.white),
                  border: InputBorder.none,
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          PopupMenuButton<dynamic>(
            onSelected: (value) {
              if (value == 'clear') {
                _clearFilters();
              } else if (value == 'price_sort') {
                setState(() {
                  _sortPriceLowToHigh = !_sortPriceLowToHigh;
                });
                _applyFilterAndSearch();
              } else if (value is FilterOption) {
                setState(() {
                  _selectedCategory = value;
                });
                _applyFilterAndSearch();
              }
            },
            icon: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(850),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(FontAwesomeIcons.sliders, color: Colors.black),
            ),
            itemBuilder: (BuildContext context) => <PopupMenuEntry<dynamic>>[
              CheckedPopupMenuItem<String>(
                value: 'price_sort',
                checked: _sortPriceLowToHigh,
                child: const Text('Price: Low to High'),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem<FilterOption>(
                value: FilterOption.none,
                child: Text('All Categories'),
              ),
              const PopupMenuItem<FilterOption>(
                value: FilterOption.gym,
                child: Text('Gym'),
              ),
              const PopupMenuItem<FilterOption>(
                value: FilterOption.food,
                child: Text('Food'),
              ),
              const PopupMenuItem<FilterOption>(
                value: FilterOption.medication,
                child: Text('Medication'),
              ),
              const PopupMenuItem<FilterOption>(
                value: FilterOption.equipment,
                child: Text('Equipment'),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem<String>(
                value: 'clear',
                child: Row(
                  children: [
                    Icon(Icons.clear_all, color: Colors.redAccent),
                    SizedBox(width: 8),
                    Text('Clear All Filters'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCouponCard(CouponItem item) {
    // --- FIX: Added Text Shadow ---
    const textShadow = [
      Shadow(blurRadius: 2.0, color: Colors.black26, offset: Offset(1.0, 1.0))
    ];

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 8,
      shadowColor: Colors.black.withAlpha(700),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Image.asset(
                  item.imageUrl,
                  height: 150,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 150,
                      color: Colors.grey[200],
                      child: const Center(
                        child: Icon(Icons.image_not_supported,
                            color: Colors.grey, size: 50),
                      ),
                    );
                  },
                ),
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withAlpha(150),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${item.stock} left',
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          shadows: textShadow),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              item.title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
                shadows: textShadow,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              item.description,
              style: const TextStyle(
                  fontSize: 14, color: Colors.black54, shadows: textShadow),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Image.asset('assets/icons/coins.png',
                        width: 24, height: 24),
                    const SizedBox(width: 8),
                    Text(
                      item.price.toString(),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        shadows: textShadow,
                      ),
                    ),
                  ],
                ),
                ElevatedButton(
                  onPressed: () {
                    _showPurchaseDialog(item);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF38B6FF),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 30, vertical: 12),
                    elevation: 8,
                    shadowColor: Colors.black.withAlpha(200),
                  ),
                  child: const Text(
                    'Purchase',
                    style: TextStyle(shadows: textShadow),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  List<CouponItem> _getInitialCouponData() {
    return [
      CouponItem(
        id: 'protein_1',
        imageUrl:
            'assets/images/360_F_317254576_lKDALRrvGoBr7gQSa1k4kJBx7O2D15dc.jpg',
        title: 'Harsheyl\'s 100gr Protein',
        description: 'Best protein to hit the gym buy now before it gets over',
        price: 1000,
        stock: 100,
        category: FilterOption.gym,
      ),
      CouponItem(
        id: 'purifier_1',
        imageUrl: 'assets/images/istockphoto-869939818-612x612.jpg',
        title: 'Aqua Guard Water Purifier',
        description: 'Pure and safe water for a healthy family life.',
        price: 1500,
        stock: 50,
        category: FilterOption.equipment,
      ),
      CouponItem(
        id: 'scale_1',
        imageUrl:
            'assets/images/360_F_317254576_lKDALRrvGoBr7gQSa1k4kJBx7O2D15dc.jpg',
        title: 'Digital Weighing Scale',
        description: 'Track your fitness journey with precision.',
        price: 800,
        stock: 120,
        category: FilterOption.equipment,
      ),
      CouponItem(
        id: 'meal_plan_1',
        imageUrl: 'assets/images/istockphoto-869939818-612x612.jpg',
        title: 'Healthy Meal Plan',
        description: 'A week of healthy and delicious meals delivered to you.',
        price: 1200,
        stock: 75,
        category: FilterOption.food,
      ),
      CouponItem(
        id: 'vitamin_d_1',
        imageUrl:
            'assets/images/360_F_317254576_lKDALRrvGoBr7gQSa1k4kJBx7O2D15dc.jpg',
        title: 'Vitamin D Supplements',
        description: 'Essential medication for bone health.',
        price: 500,
        stock: 200,
        category: FilterOption.medication,
      ),
    ];
  }
}

class _CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final int careCoins;
  const _CustomAppBar({required this.careCoins});

  @override
  Widget build(BuildContext context) {
    const appBarTextShadow = [
      Shadow(blurRadius: 1.0, color: Colors.black26, offset: Offset(0.5, 0.5))
    ];

    return AppBar(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
      ),
      backgroundColor: const Color(0xFF76E8E8),
      automaticallyImplyLeading: false,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(400),
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                )
              ],
            ),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(50),
              ),
              child: const Icon(
                FontAwesomeIcons.store,
                color: Colors.black,
                size: 24,
              ),
            ),
          ),
          const SizedBox(width: 12),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'NuroCare',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  shadows: appBarTextShadow,
                ),
              ),
              Text(
                'Coupon Store',
                style: TextStyle(
                    color: Colors.black87,
                    fontSize: 15,
                    shadows: appBarTextShadow),
              ),
            ],
          ),
        ],
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16.0),
          child: Row(
            children: [
              Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.orange.withAlpha(20),
                        blurRadius: 8,
                        spreadRadius: 2,
                      )
                    ],
                  ),
                  child: Image.asset('assets/icons/coins.png',
                      width: 24, height: 24)),
              const SizedBox(width: 8),
              Text(
                careCoins.toString(),
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  shadows: appBarTextShadow,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(60.0);
}
