import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../models/category.dart';
import '../services/mock_api_service.dart';
import '../widgets/category_card.dart';
import '../widgets/product_card.dart';
import '../widgets/featured_banner.dart';
import '../providers/theme_provider.dart';
import 'product_list_screen.dart';
import '../widgets/search_bar_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Product> products = [];
  List<Category> categories = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    final fetchedProducts = await MockApiService.fetchProducts();
    final fetchedCategories = MockApiService.getCategories();
    
    setState(() {
      products = fetchedProducts;
      categories = fetchedCategories;
      isLoading = false;
    });
  }

  // Shuffle the list to mix up products
  List<Product> getShuffledProducts(List<Product> productList) {
    final shuffled = List<Product>.from(productList);
    shuffled.shuffle();
    return shuffled;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    // Separate featured and non-featured products
    final featuredProducts = products.where((p) => p.isFeatured).toList();
    
    // Shuffle the non-featured products for variety
    final shuffledProducts = getShuffledProducts(products);
    
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    theme.colorScheme.primary,
                    theme.colorScheme.secondary,
                  ],
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.shopping_bag, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            Text(
              'MO Marketplace',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(themeProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode),
            onPressed: () => themeProvider.toggleTheme(),
          ),
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.shopping_cart_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: loadData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Search Bar
                    const SearchBarWidget(),

                    // Featured Banner
                    const FeaturedBanner(),

                    // Categories Section
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Categories',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              // Navigate to all categories
                            },
                            child: const Text('See All'),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 100,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: categories.length,
                        itemBuilder: (context, index) {
                          return CategoryCard(
                            category: categories[index],
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ProductListScreen(
                                    category: categories[index].name,
                                    products: products
                                        .where((p) => p.category == categories[index].name)
                                        .toList(),
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Featured Products Section
                    if (featuredProducts.isNotEmpty) ...[
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Featured Products',
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ProductListScreen(
                                      category: 'Featured',
                                      products: featuredProducts,
                                    ),
                                  ),
                                );
                              },
                              child: const Text('View All'),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.65,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                        ),
                        itemCount: featuredProducts.length,
                        itemBuilder: (context, index) {
                          return ProductCard(product: featuredProducts[index]);
                        },
                      ),
                      const SizedBox(height: 32),
                    ],

                    // Divider with "More Products" label
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          Expanded(
                            child: Divider(
                              color: Colors.grey[300],
                              thickness: 1,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              'MORE TO EXPLORE',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Divider(
                              color: Colors.grey[300],
                              thickness: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // All Products Section (Excluding Featured)
                    if (shuffledProducts.isNotEmpty) ...[
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'All Products',
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primaryContainer,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                '${shuffledProducts.length} items',
                                style: TextStyle(
                                  color: theme.colorScheme.onPrimaryContainer,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // All Products Grid (Non-Featured Only)
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.65,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                        ),
                        itemCount: shuffledProducts.length,
                        itemBuilder: (context, index) {
                          return ProductCard(product: shuffledProducts[index]);
                        },
                      ),
                    ],
                    const SizedBox(height: 24),

                    // Newsletter/Footer Section (Optional)
                    Container(
                      margin: const EdgeInsets.all(16),
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            theme.colorScheme.primary.withOpacity(0.1),
                            theme.colorScheme.secondary.withOpacity(0.1),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.local_offer,
                            size: 48,
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Get Special Offers',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Subscribe to our newsletter and get exclusive deals',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            decoration: InputDecoration(
                              hintText: 'Enter your email',
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              suffixIcon: Container(
                                margin: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primary,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.arrow_forward,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
    );
  }
}