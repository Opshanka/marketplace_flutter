import 'package:flutter/material.dart';
import '../models/product.dart';
import '../widgets/product_card.dart';
import '../services/mock_api_service.dart';

class ProductListScreen extends StatefulWidget {
  final String category;
  final List<Product> products;
  final String? searchQuery;

  const ProductListScreen({
    super.key,
    required this.category,
    required this.products,
    this.searchQuery,
  });

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  String selectedSort = 'Default';
  List<Product> displayedProducts = [];
  List<Product> relatedProducts = [];
  String selectedPriceRange = 'All';
  double minPrice = 0;
  double maxPrice = 1000;

  @override
  void initState() {
    super.initState();
    displayedProducts = List.from(widget.products);
    loadRelatedProducts();
  }

  Future<void> loadRelatedProducts() async {
    final allProducts = await MockApiService.fetchProducts();
    setState(() {
      relatedProducts = allProducts
          .where((p) =>
              p.category == widget.category &&
              !widget.products.any((wp) => wp.id == p.id))
          .take(4)
          .toList();
    });
  }

  void sortProducts(String sortType) {
    setState(() {
      selectedSort = sortType;
      
      switch (sortType) {
        case 'Price: Low to High':
          displayedProducts.sort((a, b) => a.price.compareTo(b.price));
          break;
        case 'Price: High to Low':
          displayedProducts.sort((a, b) => b.price.compareTo(a.price));
          break;
        case 'Rating':
          displayedProducts.sort((a, b) => b.rating.compareTo(a.rating));
          break;
        case 'Popular':
          displayedProducts.sort((a, b) => b.reviews.compareTo(a.reviews));
          break;
        case 'Name A-Z':
          displayedProducts.sort((a, b) => a.name.compareTo(b.name));
          break;
        default:
          displayedProducts = List.from(widget.products);
      }
    });
  }

  void filterByPrice(String range) {
    setState(() {
      selectedPriceRange = range;
      
      displayedProducts = widget.products.where((p) {
        switch (range) {
          case 'Under \$50':
            return p.price < 50;
          case '\$50 - \$100':
            return p.price >= 50 && p.price <= 100;
          case '\$100 - \$200':
            return p.price >= 100 && p.price <= 200;
          case 'Over \$200':
            return p.price > 200;
          default:
            return true;
        }
      }).toList();
    });
  }

  void showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return StatefulBuilder(
              builder: (context, setModalState) {
                return SingleChildScrollView(
                  controller: scrollController,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Filters',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  selectedPriceRange = 'All';
                                  displayedProducts = List.from(widget.products);
                                });
                                Navigator.pop(context);
                              },
                              child: const Text('Reset'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        
                        // Price Range
                        const Text(
                          'Price Range',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            'All',
                            'Under \$50',
                            '\$50 - \$100',
                            '\$100 - \$200',
                            'Over \$200'
                          ].map((range) {
                            final isSelected = selectedPriceRange == range;
                            return FilterChip(
                              label: Text(range),
                              selected: isSelected,
                              onSelected: (selected) {
                                setModalState(() {
                                  filterByPrice(range);
                                });
                              },
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 24),
                        
                        // Sort By
                        const Text(
                          'Sort By',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ...['Default', 'Price: Low to High', 'Price: High to Low', 
                            'Rating', 'Popular', 'Name A-Z'].map((sort) {
                          return RadioListTile<String>(
                            title: Text(sort),
                            value: sort,
                            groupValue: selectedSort,
                            onChanged: (value) {
                              if (value != null) {
                                sortProducts(value);
                                Navigator.pop(context);
                              }
                            },
                          );
                        }),
                        const SizedBox(height: 20),
                        
                        // Apply Button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () => Navigator.pop(context),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text('Apply Filters'),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.category),
            if (widget.searchQuery != null)
              Text(
                'Results for "${widget.searchQuery}"',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.tune),
            onPressed: showFilterBottomSheet,
          ),
        ],
      ),
      body: displayedProducts.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shopping_bag_outlined,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No products found',
                    style: theme.textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Try adjusting your filters',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Active Filters Display
                  if (selectedPriceRange != 'All' || selectedSort != 'Default')
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          if (selectedPriceRange != 'All')
                            Chip(
                              label: Text(selectedPriceRange),
                              deleteIcon: const Icon(Icons.close, size: 18),
                              onDeleted: () => filterByPrice('All'),
                            ),
                          if (selectedSort != 'Default')
                            Chip(
                              label: Text(selectedSort),
                              deleteIcon: const Icon(Icons.close, size: 18),
                              onDeleted: () => sortProducts('Default'),
                            ),
                        ],
                      ),
                    ),

                  // Product Count
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      '${displayedProducts.length} ${displayedProducts.length == 1 ? 'product' : 'products'}',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  // Products Grid
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
                    itemCount: displayedProducts.length,
                    itemBuilder: (context, index) {
                      return ProductCard(product: displayedProducts[index]);
                    },
                  ),

                  // Related Products Section
                  if (relatedProducts.isNotEmpty) ...[
                    const SizedBox(height: 32),
                    const Divider(),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        'You May Also Like',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 280,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: relatedProducts.length,
                        itemBuilder: (context, index) {
                          return Container(
                            width: 160,
                            margin: const EdgeInsets.only(right: 12),
                            child: ProductCard(product: relatedProducts[index]),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ],
              ),
            ),
    );
  }
}