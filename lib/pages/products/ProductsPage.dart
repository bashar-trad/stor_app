import 'package:stor/pages/shared/layout/PageLayout.dart';
import 'package:stor/pages/shared/models/products_response.dart';
import 'package:stor/pages/shared/widgets/ProductWidget.dart';
import 'package:stor/services/api.dart';
import 'package:flutter/material.dart';

class ProductsPage extends StatefulWidget {
  const ProductsPage({super.key});

  @override
  State<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  List<Product> products = [];
  List<Product> filteredProducts = [];
  bool isLoading = false;
  String searchQuery = '';
  List<String> selectedCategories = [];
  List<String> categories = [];

  @override
  void initState() {
    super.initState();
    init();
  }

  @override
  Widget build(BuildContext context) {
    return PageLayout(
      title: 'Products Page',
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          labelText: 'Search',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          suffixIcon: Icon(Icons.search),
                        ),
                        onChanged: (value) {
                          setState(() {
                            searchQuery = value;
                            filterProducts();
                          });
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: categories.map((category) {
                      final isSelected = selectedCategories.contains(category);
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            if (isSelected) {
                              selectedCategories.remove(category);
                            } else {
                              selectedCategories.add(category);
                            }
                            filterProducts();
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          decoration: BoxDecoration(
                            color: isSelected ? Colors.blue : Colors.grey[300],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            category,
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.black,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : Container(
                    color: Colors.grey[200],
                    alignment: Alignment.center,
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 30),
                      itemCount: filteredProducts.length,
                      itemBuilder: (context, index) {
                        return SizedBox(
                          height: 300,
                          child: ProductWidget(
                            product: filteredProducts[index],
                            isGrid: false,
                          ),
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Future<void> init() async {
    setState(() => isLoading = true);

    try {
      products = await Api.fetchProducts();
      filteredProducts = products;
      categories = await Api.fetchCategories();
      print('Loaded products: ${products.length}');
      print('Loaded categories: ${categories.length}');
    } catch (e) {
      print('Error loading data: $e');
    }

    setState(() => isLoading = false);
  }

  void filterProducts() {
    List<Product> tempProducts = products;

    if (searchQuery.isNotEmpty) {
      tempProducts = tempProducts.where((product) {
        return product.title.toLowerCase().contains(searchQuery.toLowerCase());
      }).toList();
    }

    if (selectedCategories.isNotEmpty) {
      tempProducts = tempProducts.where((product) {
        return selectedCategories.contains(product.category);
      }).toList();
    }

    setState(() {
      filteredProducts = tempProducts;
    });
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Select Categories'),
              content: SingleChildScrollView(
                child: Wrap(
                  spacing: 8.0,
                  runSpacing: 8.0,
                  children: categories.map((category) {
                    final isSelected = selectedCategories.contains(category);
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          if (isSelected) {
                            selectedCategories.remove(category);
                          } else {
                            selectedCategories.add(category);
                          }
                          filterProducts();
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.blue : Colors.grey[300],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          category,
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.black,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Done'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
