import 'package:flutter/material.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      color: Colors.lightBlue[100],
      home: const MyHomePage(title: 'Solo App 2 (BMI Calculator)'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}



class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();

    int _tapCount = 0;
    Color _backgroundColor = Colors.blueAccent;
    Color _textColor = Colors.black;
    String input = '';
    int height = 0;
    int weight = 0;
    double bmi = 0;
    String errors = '';

    List<Color> colorsList = [?Colors.lightBlue[100], ?Colors.red[300], ?Colors.yellow[200], Colors.deepPurple, ?Colors.green[900]];
    void _handleTap(){
      setState(() {
        _tapCount += 1;
        _backgroundColor = colorsList[_tapCount % 5];
        if (_backgroundColor == Colors.deepPurple || _backgroundColor == Colors.green[900]){
          _textColor = Colors.white;
        }
        else {
          _textColor = Colors.black;
        }
      });
    }

    void _handleHeight(String value){
      final parsedHeight = int.tryParse(value);
      if (parsedHeight != null) {
        height = parsedHeight;
        setState(() {
          errors = "";
        });
      }
      else {
        setState(() {
          bmi = 0;
          errors = "Invalid input: Please enter only numbers";
        });
      }
    }

    void _handleWeight(String value){
      final parsedWeight = int.tryParse(value);
      if (parsedWeight != null) {
        weight = parsedWeight;
        setState(() {
          errors = "";
        });
      }
      else {
        setState(() {
          bmi = 0;
          errors = "Invalid input: Please enter only numbers";
        });
      }
    }

    double calculateBMI(height, weight) {
      bmi = (weight/(height*height)*703);
      return bmi;
    }

    @override
  Widget build(BuildContext context) {

    return GestureDetector(
      onTap: _handleTap,
      child: Scaffold(
        backgroundColor: _backgroundColor,
        appBar: AppBar(

          backgroundColor: Colors.grey[300],

          title: Text(widget.title),
        ),
        body: ListView(
          padding: EdgeInsets.all(16),
          children: [
            Text(
              '*** BMI is a flawed statistic and should not be used to determine overall physical health ***',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: _textColor,
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _heightController,
              style: TextStyle(
                color: _textColor,
              ),
              decoration: InputDecoration(
                labelText: 'height (inches)',
                labelStyle: TextStyle(
                    color: _textColor,
                    fontSize: 18
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: _textColor,
                    width: 2,
                  ),
                ),
              ),
              onSubmitted: _handleHeight,
            ),

            SizedBox(height: 10),
            TextField(
              controller: _weightController,
              style: TextStyle(
                color: _textColor,
              ),
              decoration: InputDecoration(
                labelText: 'weight (pounds)',
                labelStyle: TextStyle(
                    color: _textColor,
                    fontSize: 18
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: _textColor,
                    width: 2,
                  ),
                ),
              ),
              onSubmitted: _handleWeight,
            ),

            SizedBox(height: 20),
            FloatingActionButton.extended(
              onPressed: () {
                _handleHeight(_heightController.text);
                _handleWeight(_weightController.text);

                if (height > 0 && weight > 0 && errors == '') {
                  setState(() {
                    calculateBMI(height, weight);
                  });
                }
              },
              label: Text('Calculate'),
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
            ),

            SizedBox(height: 20),
            Text (
              (bmi == 0 ? '' : 'BMI = ${bmi.toStringAsFixed(2)}'),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                color: _textColor,
              ),
            ),
            SizedBox(height: 50),
            Text (
              (errors.length == 0 ? '' : '$errors'),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                color: _textColor,
              ),
            )
            // DropdownButton <String> (
            //   value: _backgroundColor,
            //   items: colorsList.keys.map((String name) {
            //     return DropdownMenuItem<String> (
            //       value: name,
            //       child: Text(
            //         name,
            //         style: TextStyle(color: colorsList[name])
            //       ),
            //     }
            //     )
            //   })
            // )
          ],
        ),
      ),
    );
  }
}
