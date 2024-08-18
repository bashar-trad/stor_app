import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class OrdersPage extends StatefulWidget {
  const OrdersPage({Key? key}) : super(key: key);

  @override
  _OrdersPageState createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  late Future<List<Map<String, dynamic>>> _cartFuture;
  Database? _database;

  @override
  void initState() {
    super.initState();
    _cartFuture = _loadCartData();
  }

  Future<void> _initDatabase() async {
    if (_database != null) {
      return;
    }
    String path = join(await getDatabasesPath(), 'cart_database.db');
    _database = await openDatabase(
      path,
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE cart(id INTEGER PRIMARY KEY AUTOINCREMENT, productTitle TEXT, quantity INTEGER, price REAL, thumbnail TEXT)',
        );
      },
      version: 1,
    );
  }

  Future<List<Map<String, dynamic>>> _loadCartData() async {
    await _initDatabase();
    final List<Map<String, dynamic>> maps = await _database!.query(
      'cart',
      orderBy: 'id DESC', // Order by ID, latest first
    );
    return maps;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Cart'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _cartFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            final cartItems = snapshot.data!;
            if (cartItems.isEmpty) {
              return const Center(child: Text('No items in cart'));
            }

            return ListView.builder(
              itemCount: cartItems.length,
              itemBuilder: (context, index) {
                final item = cartItems[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        
                        item['thumbnail'] != null && item['thumbnail'].isNotEmpty
                            ? Image.network(
                                item['thumbnail'],
                                height: 100,
                                width: 100,
                                fit: BoxFit.cover,
                              )
                            : Container(
                                height: 100,
                                width: 100,
                                color: Colors.grey[200],
                                child: const Icon(Icons.image, color: Colors.grey, size: 50),
                              ),

                        const SizedBox(width: 8.0),

                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item['productTitle'] ?? 'No title',
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              Text(
                                '${item['quantity']} x ${item['price'].toStringAsFixed(2)} \$',
                                style: const TextStyle(fontSize: 14),
                              ),
                              const SizedBox(height: 4.0),
                              Text(
                                'Total: ${(item['quantity'] * item['price']).toStringAsFixed(2)} \$',
                                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          } else {
            return const Center(child: Text('No items in cart'));
          }
        },
      ),
    );
  }
}
