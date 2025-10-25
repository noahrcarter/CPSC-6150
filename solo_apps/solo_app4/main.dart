import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';


Future<void> saveCount(int count) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setInt('count', count);
}
Future<void> saveHighScore(int highScore) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setInt('highScore', highScore);
}
Future<void> saveScoreList(List<String> scoreList) async{
  final prefs = await SharedPreferences.getInstance();
  final jsonStringList = jsonEncode(scoreList);
  await prefs.setString('scoreList', jsonStringList);
}


Future<int> loadCount() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getInt('count') ?? 5;
}
Future<int> loadHighScore() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getInt('highScore') ?? 5;
}
Future<List<String>> loadScoreList() async {
  final prefs = await SharedPreferences.getInstance();
  final jsonListString = prefs.getString('scoreList');
  if (jsonListString == null) return [];
  final List<dynamic> decoded = jsonDecode(jsonListString);

  return decoded.map((e) => e as String).toList();
}





class CountProvider with ChangeNotifier {
  int _count = 0;
  int _highScore = 0;
  List<String> _scoreList = [];
  bool _prAchieved = false;

  int get count => _count;
  int get highScore => _highScore;
  List<String> get scoreList => _scoreList;
  bool get pr_Achieved => _prAchieved;

  CountProvider() {
    _loadHighScore();
    _loadScoreList();
  }

  // reset all values for testing
  void reset() {
    _highScore = 0;
    _scoreList = [];
    _count = 0;
    _prAchieved = false;
    notifyListeners();
  }


  void restart() {
    _scoreList.add(_count.toString());
    saveScoreList(_scoreList);
    _count = 0;
    _prAchieved = false;
    notifyListeners();
  }

  bool update() {
    bool pr = false;
    _count++;

    if (_count > _highScore) {
      _highScore = _count;
      saveHighScore(_count);
      // pr = true;

      if(!_prAchieved) {
        _prAchieved = true;
        pr = true;

      }
    }

    notifyListeners();

    return pr;
  }

  void _loadCount() async {
    _count = await loadCount();
    notifyListeners();
  }
  void _loadHighScore() async {
    _highScore = await loadHighScore();
    notifyListeners();
  }
  void _loadScoreList() async {
    _scoreList = await loadScoreList();
    notifyListeners();
  }
}

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => CountProvider(),
      child: const MyApp()),
    );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(

        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {

    final countProvider = Provider.of<CountProvider>(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text("Solo App 4"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('Current Score: ',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            Text(
              '${countProvider.count}',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            SizedBox(
              height: 20,
            ),
            Text(
                'High Score:',
                style: Theme.of(context).textTheme.headlineMedium,
            ),
            Text(
              '${countProvider.highScore}',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            SizedBox(
              height: 20,
            ),
            Text(
                'History: ',
                style: Theme.of(context).textTheme.headlineSmall,
            ),
            Container(
              constraints: BoxConstraints(maxHeight: 200),

              child: ListView.builder(
                  itemCount: countProvider.scoreList.length,
                  itemBuilder: (context, index) {
                    final score = countProvider.scoreList[index];
                    return ListTile(
                      title: Center(child: Text(
                          '$score',
                          style: Theme.of(context).textTheme.headlineSmall,
                      )),
                    );
                  }
              ),
            )
          ],
        ),
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FloatingActionButton(
            onPressed: () {
              final isPr = countProvider.update();
              if (isPr){
                showDialog(
                  context: context,
                  builder: (context) =>
                      AlertDialog(
                        title: const Text('New High Score Achieved !'),
                        content: Text(
                            'You reached a high score: ${countProvider.highScore}'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text('Continue'),
                          ),
                        ],
                      ),
                );
              }
            },
            child: const Icon(Icons.add),
          ),
          SizedBox(
            width: 20,
          ),
          SizedBox(
            width: 20,
          ),
          FloatingActionButton(
            onPressed: countProvider.restart,
            child: const Icon(Icons.refresh),
          ),
          SizedBox(
            width: 20,
          ),
          ElevatedButton(
            onPressed: countProvider.reset,
            child: const Text('Reload'),
          )
        ],
      ),
    );
  }


}


