import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import "package:http/http.dart" as http;
import 'package:flutter_spinkit/flutter_spinkit.dart';

// counter so error test only occurs once
int errorCounter = 0;
// controller for handling text input
final TextEditingController _controller = TextEditingController();
// list and index for seen dogs
List <Dog> dogs = [];
int dogImagesIndex = 0;
bool errorExists = false;

/// Fetch one Product by ID from jsonplaceholder
Future<Product> fetchProduct(int id) async {
  // simulate loading for Loading UX test
  await Future.delayed(const Duration(seconds: 2));

  // Build the request URL like: https://jsonplaceholder.typicode.com/Products/5
  // final uri = Uri.parse('https://jsonplaceholder.typicode.com/Products/$id');
  final uri = Uri.parse('https://api.spacexdata.com/v4/launches/latest');

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

/// Fetch Random dog from https://dog.ceo/api/breeds/image/random
Future<Dog> fetchDog() async {
  // simulate loading for Loading UX test
  await Future.delayed(const Duration(seconds: 2));

  final uri = Uri.parse('https://dog.ceo/api/breeds/image/random');


  // Perform GET request with a 10-second timeout
  final res = await http.get(uri).timeout(const Duration(seconds: 12));

  if (res.statusCode == 200) {
    // Parse the JSON body into a Dart map, then into a Dog object
    return Dog.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
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

class Dog {
  final String image;
  final String status;

  const Dog({ required this.image, required this.status,});

  factory Dog.fromJson(Map<String, dynamic> j) => Dog (
    image: j['message'] as String,
    status: j['status'] as String,
  );
}




void main() => runApp(const MyApp());

class MyApp extends StatefulWidget {
  const MyApp({super.key});
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  void handleError(Object error, [StackTrace? stackTrace]) {
    if (stackTrace != null) {
      debugPrint('stacktrace:\n$stackTrace');
    }

    // try and insert some way of creating UI componenets here
    setState(() {
      errorExists = true;
    });
  }

  // Hold the current fetch operation
  late Future<Dog> _futureDog;

  // Track whether we are in the middle of a fetch
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    // Fetch the very first Product at startup
    _futureDog = fetchDog();
    _logDog();
  }

  /// Helper to load image of first dog
  Future<void> _logDog() async {
    final dog = await _futureDog;
    dogs.add(dog);
  }


  void _next() {
    setState(() {
        _futureDog = Future.value(dogs[dogImagesIndex]);
    });
  }

  void _prev() {

    setState(() {
        _futureDog = Future.value(dogs[dogImagesIndex]);
    });
  }


  void loadDog() async {
    try {
      if (dogImagesIndex == 5) {
        throw Exception('Forced error for testing');
      }
      setState(() {
        _futureDog = fetchDog();
        dogImagesIndex += 1;
      });
      final dog = await _futureDog;
      dogs.add(dog);
    }
    catch (error, stackTrace) {
      handleError(error, stackTrace);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (errorExists == false) {
      return MaterialApp(
        title: 'Random Dogs',
        home: Scaffold(
          backgroundColor: Colors.orange[300],
          appBar: AppBar(
            title: const Text('Random Dogs (Solo App 3)'),
            backgroundColor: Colors.deepPurple[300],
          ),
          body: RefreshIndicator(
            backgroundColor: Colors.orange[300],
            onRefresh: () async {
              loadDog();
            },
            child: FutureBuilder<Dog>(
              future: _futureDog,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting ||
                    _loading) {
                  return ListView(
                    padding: const EdgeInsets.all(16),
                    children: const [
                      Center(child: SpinKitFadingCircle(
                          color: Colors.deepPurple, size: 50.0)),
                    ],
                  );
                }
                if (snapshot.hasError) {
                  handleError(snapshot.error!, snapshot.stackTrace);
                  return const Center(child: Text('something went wrong'));
                }

                final dog = snapshot.data!;
                return ListView(
                    children: [
                      Center(
                        child:
                        Column(
                          children: [
                            Image.network(dog.image, width: 300, height: 300),
                            SizedBox(height: 30),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 150,
                                  child: FloatingActionButton(
                                    onPressed: () {
                                      if (dogImagesIndex > 0) {
                                        dogImagesIndex -= 1;
                                        _prev();
                                      }
                                    },
                                    child: const Text('Previous',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold)),
                                    backgroundColor: Colors.deepPurple[300],
                                  ),
                                ),
                                SizedBox(width: 15),
                                Container(
                                  width: 150,
                                  child: FloatingActionButton(
                                    onPressed: () {
                                      if (dogImagesIndex < (dogs.length - 1)) {
                                        dogImagesIndex += 1;
                                        _next();
                                      }
                                    },
                                    child: const Text('Next', style: TextStyle(
                                        fontWeight: FontWeight.bold)),
                                    backgroundColor: Colors.deepPurple[300],
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 30),
                            Container(
                              width: 300,
                              child: FloatingActionButton(
                                onPressed: () {
                                  loadDog();
                                },
                                child: const Text('New Dog', style: TextStyle(
                                    fontWeight: FontWeight.bold)),
                                backgroundColor: Colors.deepPurple[300],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        children: [
                        ],
                      ),
                    ]
                );
              },
            ),
          ),
        ),
      );
    }
    else {
      return MaterialApp(
        title: 'Random Dogs',
        home: Scaffold(
          backgroundColor: Colors.orange[300],
          appBar: AppBar(
            title: const Text('Random Dogs (Solo App 3)'),
            backgroundColor: Colors.deepPurple[300],
          ),
          body: Column(
            children: [
              Center(
                child:
                  Text(
                      'an error occured, please refresh',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
              ),
              Center(
                child: FloatingActionButton(
                  onPressed: () {
                    errorExists = false;
                    dogImagesIndex = 0;
                    loadDog();
                  },
                  child: const Text('Refresh', style: TextStyle(
                      fontWeight: FontWeight.bold)),
                  backgroundColor: Colors.deepPurple[300],
                ),
              )
            ],
          ),
        ),
      );
    }
  }
}


