import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/mock_api_service.dart';
import '../widgets/product_card.dart';
import '../widgets/search_suggestion_item.dart';
import 'package:shimmer/shimmer.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Product> allProducts = [];
  List<Product> filteredProducts = [];
  List<String> searchHistory = [];
  List<String> popularSearches = [
    'Headphones',
    'Smart Watch',
    'Running Shoes',
    'Backpack',
    'Coffee Maker',
  ];
  bool isLoading = true;
  bool isSearching = false;
  String selectedFilter = 'All';

  @override
  void initState() {
    super.initState();
    loadProducts();
    loadSearchHistory();
  }

  Future<void> loadProducts() async {
    setState(() => isLoading = true);
    final products = await MockApiService.fetchProducts();
    setState(() {
      allProducts = products;
      filteredProducts = products;
      isLoading = false;
    });
  }

  void loadSearchHistory() {
    // In a real app, load from SharedPreferences
    searchHistory = ['Wireless Headphones', 'Yoga Mat', 'Smart Watch'];
  }

  void saveToSearchHistory(String query) {
    if (query.isNotEmpty && !searchHistory.contains(query)) {
      setState(() {
        searchHistory.insert(0, query);
        if (searchHistory.length > 10) {
          searchHistory.removeLast();
        }
      });
      // In a real app, save to SharedPreferences
    }
  }

  void performSearch(String query) {
    if (query.isEmpty) {
      setState(() {
        filteredProducts = allProducts;
        isSearching = false;
      });
      return;
    }

    setState(() => isSearching = true);
    
    final lowercaseQuery = query.toLowerCase();
    final results = allProducts.where((product) {
      final nameMatch = product.name.toLowerCase().contains(lowercaseQuery);
      final categoryMatch = product.category.toLowerCase().contains(lowercaseQuery);
      final descriptionMatch = product.description.toLowerCase().contains(lowercaseQuery);
      
      return nameMatch || categoryMatch || descriptionMatch;
    }).toList();

    // Sort by relevance (name matches first)
    results.sort((a, b) {
      final aNameMatch = a.name.toLowerCase().contains(lowercaseQuery);
      final bNameMatch = b.name.toLowerCase().contains(lowercaseQuery);
      
      if (aNameMatch && !bNameMatch) return -1;
      if (!aNameMatch && bNameMatch) return 1;
      return 0;
    });

    setState(() {
      filteredProducts = results;
    });

    saveToSearchHistory(query);
  }

  void applyFilter(String filter) {
    setState(() {
      selectedFilter = filter;
      
      if (filter == 'All') {
        performSearch(_searchController.text);
      } else if (filter == 'Price: Low to High') {
        filteredProducts.sort((a, b) => a.price.compareTo(b.price));
      } else if (filter == 'Price: High to Low') {
        filteredProducts.sort((a, b) => b.price.compareTo(a.price));
      } else if (filter == 'Rating') {
        filteredProducts.sort((a, b) => b.rating.compareTo(a.rating));
      } else if (filter == 'Popular') {
        filteredProducts.sort((a, b) => b.reviews.compareTo(a.reviews));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Search products...',
            border: InputBorder.none,
            hintStyle: TextStyle(color: Colors.grey[400]),
          ),
          onChanged: performSearch,
          onSubmitted: (value) => performSearch(value),
        ),
        actions: [
          if (_searchController.text.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                _searchController.clear();
                performSearch('');
              },
            ),
        ],
      ),
      body: Column(
        children: [
          // Filter Chips
          if (isSearching)
            Container(
              height: 50,
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  'All',
                  'Price: Low to High',
                  'Price: High to Low',
                  'Rating',
                  'Popular'
                ].map((filter) {
                  final isSelected = selectedFilter == filter;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(filter),
                      selected: isSelected,
                      onSelected: (selected) => applyFilter(filter),
                      backgroundColor: theme.colorScheme.surfaceVariant,
                      selectedColor: theme.colorScheme.primaryContainer,
                      labelStyle: TextStyle(
                        color: isSelected
                            ? theme.colorScheme.onPrimaryContainer
                            : theme.colorScheme.onSurfaceVariant,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),

          // Content
          Expanded(
            child: isLoading
                ? _buildLoadingState()
                : isSearching
                    ? _buildSearchResults()
                    : _buildSearchSuggestions(),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.65,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: 6,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSearchSuggestions() {
    final theme = Theme.of(context);
    
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Recent Searches
          if (searchHistory.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Recent Searches',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() => searchHistory.clear());
                    },
                    child: const Text('Clear All'),
                  ),
                ],
              ),
            ),
            ...searchHistory.map((query) => SearchSuggestionItem(
                  icon: Icons.history,
                  title: query,
                  onTap: () {
                    _searchController.text = query;
                    performSearch(query);
                  },
                  onDelete: () {
                    setState(() => searchHistory.remove(query));
                  },
                )),
            const Divider(height: 32),
          ],

          // Popular Searches
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Popular Searches',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ...popularSearches.map((query) => SearchSuggestionItem(
                icon: Icons.trending_up,
                iconColor: Colors.orange,
                title: query,
                onTap: () {
                  _searchController.text = query;
                  performSearch(query);
                },
              )),
          const SizedBox(height: 16),

          // Trending Products
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Trending Products',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(
            height: 250,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: allProducts.take(5).length,
              itemBuilder: (context, index) {
                return Container(
                  width: 160,
                  margin: const EdgeInsets.only(right: 12),
                  child: ProductCard(product: allProducts[index]),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildSearchResults() {
    if (filteredProducts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No products found',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Try searching with different keywords',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            '${filteredProducts.length} ${filteredProducts.length == 1 ? 'result' : 'results'} found',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.65,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: filteredProducts.length,
            itemBuilder: (context, index) {
              return ProductCard(product: filteredProducts[index]);
            },
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}