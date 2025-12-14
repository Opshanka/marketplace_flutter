import '../models/product.dart';
import '../models/category.dart';
import 'package:flutter/material.dart';

class MockApiService {
  static Future<List<Product>> fetchProducts() async {
    await Future.delayed(const Duration(seconds: 1));
    
    return [
      Product(
        id: '1',
        name: 'Wireless Headphones',
        description: 'Premium noise-cancelling wireless headphones with 30-hour battery life and superior sound quality.',
        price: 299.99,
        imageUrl: 'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=800',
        category: 'Electronics',
        rating: 4.8,
        reviews: 2341,
        isFeatured: true,
      ),
      Product(
        id: '2',
        name: 'Smart Watch Pro',
        description: 'Advanced fitness tracking, heart rate monitoring, and smartphone notifications on your wrist.',
        price: 399.99,
        imageUrl: 'https://images.unsplash.com/photo-1523275335684-37898b6baf30?w=800',
        category: 'Electronics',
        rating: 4.6,
        reviews: 1823,
        isFeatured: true,
      ),
      Product(
        id: '3',
        name: 'Leather Backpack',
        description: 'Genuine leather backpack with laptop compartment, perfect for work and travel.',
        price: 129.99,
        imageUrl: 'https://images.unsplash.com/photo-1553062407-98eeb64c6a62?w=800',
        category: 'Fashion',
        rating: 4.7,
        reviews: 856,
      ),
      Product(
        id: '4',
        name: 'Running Shoes',
        description: 'Lightweight running shoes with advanced cushioning technology for ultimate comfort.',
        price: 159.99,
        imageUrl: 'https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=800',
        category: 'Sports',
        rating: 4.9,
        reviews: 3421,
        isFeatured: true,
      ),
      Product(
        id: '5',
        name: 'Coffee Maker Pro',
        description: 'Professional-grade coffee maker with programmable settings and thermal carafe.',
        price: 249.99,
        imageUrl: 'https://images.unsplash.com/photo-1517668808822-9ebb02f2a0e6?w=800',
        category: 'Home',
        rating: 4.5,
        reviews: 672,
      ),
      Product(
        id: '6',
        name: 'Yoga Mat Premium',
        description: 'Extra thick yoga mat with superior grip and cushioning for all types of yoga practice.',
        price: 49.99,
        imageUrl: 'https://images.unsplash.com/photo-1601925260368-ae2f83cf8b7f?w=800',
        category: 'Sports',
        rating: 4.8,
        reviews: 1234,
      ),
    ];
  }

  static List<Category> getCategories() {
    return [
      Category(
        id: '1',
        name: 'Electronics',
        icon: Icons.devices,
        color: const Color(0xFF6366F1),
      ),
      Category(
        id: '2',
        name: 'Fashion',
        icon: Icons.checkroom,
        color: const Color(0xFFEC4899),
      ),
      Category(
        id: '3',
        name: 'Home',
        icon: Icons.home,
        color: const Color(0xFF8B5CF6),
      ),
      Category(
        id: '4',
        name: 'Sports',
        icon: Icons.sports_basketball,
        color: const Color(0xFF10B981),
      ),
      Category(
        id: '5',
        name: 'Books',
        icon: Icons.menu_book,
        color: const Color(0xFFF59E0B),
      ),
      Category(
        id: '6',
        name: 'Beauty',
        icon: Icons.spa,
        color: const Color(0xFFEF4444),
      ),
    ];
  }
}