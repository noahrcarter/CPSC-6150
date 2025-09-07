import 'package:flutter/material.dart';
import 'quote.dart';
import 'quote_card.dart';

void main() => runApp(MaterialApp(
  theme: ThemeData(
    scaffoldBackgroundColor: Colors.amberAccent,
  ),
    home: QuoteList(),
));

class QuoteList extends StatefulWidget {
  @override
  _QuoteListState createState() => _QuoteListState();
}

class _QuoteListState extends State<QuoteList> {

  List<Quote> quotes = [
    Quote(
        author: 'Oscar Wilde',
        text: 'Be yourself; everyone else is already taken',
        category: 'inspiration',
        created: DateTime(2020, 1, 2, 3, 4)
    ),
    Quote(
        author: 'Oscar Wilde',
        text: 'Be yourself; everyone else is already taken',
        category: 'introspective',
        created: DateTime(2023, 1, 2, 3, 4)
    ),
    Quote(
        author: 'Oscar Wilde',
        text: 'Be yourself; everyone else is already taken',
        category: 'motivation',
        created: DateTime(2025, 1, 2, 3, 4)
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlue[50],
      appBar: AppBar(
        title: Text('Awesome Quotes'),
        centerTitle: true,
        backgroundColor: Colors.redAccent,
      ),
      body: ListView(
        children: quotes.map((quote) => QuoteCard(quote: quote)).toList(),
      ),
    );
  }
}