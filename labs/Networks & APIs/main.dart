import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import "package:http/http.dart" as http;
import 'package:flutter_spinkit/flutter_spinkit.dart';

// counter so error test only occurs once
int errorCounter = 0;
// controller for handling text input
final TextEditingController _controller = TextEditingController();

/// Fetch one Product by ID from jsonplaceholder
Future<Product> fetchProduct(int id) async {
  // simulate loading for Loading UX test
  await Future.delayed(const Duration(seconds: 2));

  // Build the request URL like: https://jsonplaceholder.typicode.com/Products/5
  // final uri = Uri.parse('https://jsonplaceholder.typicode.com/Products/$id');
  final uri = Uri.parse('https://dummyjson.com/products/$id');

  // Force error for testing on id 3
  if (id == 3 && errorCounter == 0) {
    errorCounter += 1;
    throw Exception('forced error for testing on ID $id');
  }

  // Perform GET request with a 10-second timeout
  final res = await http.get(uri).timeout(const Duration(seconds: 12));

  if (res.statusCode == 200) {
    // Parse the JSON body into a Dart map, then into an Product object
    return Product.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
  } else {
    // If server response wasn’t 200, throw an exception
    throw Exception('Failed to load Product (HTTP ${res.statusCode})');
  }
}

/// Simple Dart model for an Product record
class Product {
  final int id;
  final String title;
  final String brand;
  final num price;   // int or double
  final num rating;
  final String thumbnail;
  static const int minId = 1;
  static const int maxId = 194; // adjust per API

  const Product({
    required this.id, required this.title, required this.brand,
    required this.price, required this.rating, required this.thumbnail,
  });

  factory Product.fromJson(Map<String, dynamic> j) => Product(
    id: j['id'] as int,
    title: j['title'] as String? ?? 'Untitled',
    brand: j['brand'] as String? ?? 'Unknown',
    price: (j['price'] as num?)?.toDouble() ?? 0.0,
    rating: (j['rating'] as num?)?.toDouble() ?? 0.0,
    thumbnail: j['thumbnail'] as String ?? '',
  );
}



void main() => runApp(const MyApp());

/// Root widget (needs to be stateful so we can track current Product id)
class MyApp extends StatefulWidget {
  const MyApp({super.key});
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  static const int minId = 1;
  static const int maxId = 194;

  // Track the current Product id
  int _currentId = minId;

  // Hold the current fetch operation
  late Future<Product> _futureProduct;

  // Track whether we are in the middle of a fetch
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    // Fetch the very first Product at startup
    _futureProduct = fetchProduct(_currentId);
  }

  /// Helper to load any given id and update state
  void _loadId(int id) {
    setState(() {
      // Clamp ID within range
      _currentId = id.clamp(minId, maxId);
      _loading = true;

      // Start fetching. whenComplete runs after success OR error.
      _futureProduct = fetchProduct(_currentId).whenComplete(() {
        if (mounted) {
          setState(() {
            _loading = false;
          });
        }
      });
    });

  }


  /// Go forward to the next Product (wrap at max → min)
  void _next() => _loadId((_currentId + 1) > maxId ? minId : _currentId + 1);

  /// Go backward to the previous Product (wrap at min → max)
  void _prev() => _loadId((_currentId - 1) < minId ? maxId : _currentId - 1);

  /// go to specific product id
  void go_to_id() {
    final input = _controller.text.trim();
    if (input.isNotEmpty) {
      final parsedInput = int.tryParse(input);
      if (parsedInput != null) {
        _loadId(parsedInput);
      } else {
        print('Invalid input: Not a number');
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Products Prev/Next Demo',
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.deepPurple),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Products Demo'),
          actions: [
            // Prev button in the AppBar
            IconButton(
              onPressed: _loading ? null : _prev,
              tooltip: 'Previous Product',
              icon: const Icon(Icons.navigate_before),
            ),
            // Next button in the AppBar
            IconButton(
              onPressed: _loading ? null : _next,
              tooltip: 'Next Product',
              icon: const Icon(Icons.navigate_next),
            ),
          ],
        ),
        body: RefreshIndicator(
          onRefresh: () async {
            setState(() {
              // _loadId(_currentId);
              // _loading = true;
              _futureProduct = fetchProduct(_currentId);
            });
            await _futureProduct;
          },
          child: FutureBuilder<Product>(
            future: _futureProduct,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting || _loading) {
                return ListView(
                  padding: const EdgeInsets.all(16),
                  children: const [
                    Center(child: SpinKitFadingCircle(color: Colors.deepPurple, size: 50.0)),
                  ],
                );
              }
              if (snapshot.hasError) {
                return ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Error: ${snapshot.error}', textAlign: TextAlign.center),
                        const SizedBox(height: 12),
                        FilledButton.icon(
                          onPressed: () => _loadId(_currentId),
                          icon: const Icon(Icons.refresh),
                          label: const Text('Retry'),
                        ),
                      ],
                    ),
                  ],
                );
              }

              final product = snapshot.data!;
              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Card(
                    margin: const EdgeInsets.all(16),
                    child: ListTile(
                      leading: product.thumbnail.isNotEmpty
                          ? Image.network(product.thumbnail, width: 56, height: 56)
                          : CircleAvatar(child: Text('${product.id}')),
                      title: Text(product.title),
                      subtitle: Text('id: ${product.id}'),
                      trailing: FilledButton(
                        onPressed: _loading ? null : _next,
                        child: const Text('Next'),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),

        ),


        // Bottom bar with both Prev and Next buttons
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              FilledButton(
                onPressed: _loading ? null : _prev,
                child: const Text('Prev'),
              ),
              Flexible(
                child: TextField(
                  controller: _controller,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'product ID',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: go_to_id,
                child: const Text('Go'),
              ),
              FilledButton(
                onPressed: _loading ? null : _next,
                child: const Text('Next'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}