// main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CartModel()),
        // You could add more models here later (e.g., UserModel, ThemeModel).
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mini Cart — Provider (3 layers)',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const HomeScreen(),
    );
  }
}

/* ---------------------- Shared State (Business Logic) ---------------------- */

class CartModel extends ChangeNotifier {
  final Map<String, double> _productPrices = {
    'Apples': 1.50,
    'Bananas': 0.99,
    'Cookies': 3.25,
    'Milk': 2.25,
    'Bread': 2.00,
  };

  final Map<String, String> _productDescription = {
    'Apples': "Apples are red, round, and ripe",
    'Bananas': "Bananas got potassium",
    'Cookies': "Cookies are the best ",
    'Milk': "Milk is overrated but its good",
    'Bread': "Its bread...Nothing fancy here",
  };

  final List<String> _items = [];
  List<String> get items => List.unmodifiable(_items);
  int get count => _items.length;
  double? getPrice(String item) => _productPrices[item];
  String? getDescription(String item) => _productDescription[item];


  double get totalPrice => _items.fold(
    0.0,
        (sum, item) => sum + (_productPrices[item] ?? 0),
  );

  void add(String item) { _items.add(item); notifyListeners(); }
  void remove(String item) { _items.remove(item); notifyListeners(); }
}
/* --------------------------------- UI ------------------------------------- */

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final products = const ['Apples', 'Bananas', 'Cookies', 'Milk', 'Bread'];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Shop — Provider (3 layers)'),
        actions: [
          // Only this badge needs to react to changes ⇒ watch()
          InkWell(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CartScreen()),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  const Icon(Icons.shopping_cart, size: 28),
                  Positioned(
                    right: 0,
                    child: CircleAvatar(
                      radius: 10,
                      backgroundColor: Colors.red,
                      child: Text(
                        context.watch<CartModel>().count.toString(), // 👈 watch
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),

      // ⬇️ No callbacks passed. ProductList can access CartModel via context.
      body: ProductList(products: products),
    );
  }
}

// Middle layer — doesn’t need cart or callbacks anymore
class ProductList extends StatelessWidget {
  const ProductList({super.key, required this.products});
  final List<String> products;

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: products.map((p) => ProductTile(name: p)).toList(),
    );
  }
}

// Leaf widget — directly updates shared state
class ProductTile extends StatelessWidget {
  const ProductTile({super.key, required this.name});
  final String name;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => ProductDetailScreen(name: name)),
          ),
        child: Text(name)
      ),
      trailing: ElevatedButton(
        // Action only; button itself doesn’t need to rebuild ⇒ read()
        onPressed: () => context.read<CartModel>().add(name), // 👈 read
        child: const Text('Add'),
      ),
    );
  }
}

class ProductDetailScreen extends StatelessWidget {
  final String name;
  const ProductDetailScreen({super.key, required this.name});

  @override
  Widget build(BuildContext context) {
    final description = context.read<CartModel>().getDescription(name);
    final price = context.read<CartModel>().getPrice(name);


    return Scaffold (
      appBar: AppBar(title: Text(name)), 
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, 
            children: [
              Text(
                name, 
                style: Theme.of(context).textTheme.headlineMedium, 
              ),
              const SizedBox(height: 12),
              Text(description!),
              const SizedBox(height: 12),
              Text('Price: \$${price?.toStringAsFixed(2) ?? 'N/A'}'),
              const Spacer(),
              ElevatedButton(
                onPressed: () {
                  context.read<CartModel>().add(name);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('$name added to cart'))
                  );
                },
                child: const Text('Add to Cart'),
              ),
            ],
        )
      )
    );
  }
}

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Whole screen should update when the cart changes ⇒ watch()
    final cart = context.watch<CartModel>(); // 👈 watch
    final total = context.watch<CartModel>().totalPrice;

    return Scaffold(
      appBar: AppBar(title: const Text('Your Cart')),
      body: ListView.builder(
        itemCount: cart.items.length,
        itemBuilder: (context, index) {
          final item = cart.items[index];
          return ListTile(
            title: Text(item),
            trailing: IconButton(
              icon: const Icon(Icons.remove_circle_outline),
              // Action only ⇒ read()
              onPressed: () =>
                  context.read<CartModel>().remove(item), // 👈 read
            ),
          );
        },
      ),
      bottomNavigationBar: BottomAppBar(

        child: Padding (
          padding: const EdgeInsets.all(16),
          child: Text (
            'Total: \$${total.toStringAsFixed(2)}',
          )
        )
      )
    );
  }
}
