import 'package:flutter/material.dart';
import 'like_button.dart';
import 'quote.dart';

class QuoteCard extends StatelessWidget {

  final Quote quote;
  QuoteCard({ required this.quote });

  @override
  Widget build(BuildContext context) {

    Color cardColor;
    double elevation;
    ShapeBorder shape;

    switch (quote.category) {
      case 'inspiration':
        cardColor = Colors.yellow[100]!;
        elevation = 4.0;
        shape = RoundedRectangleBorder(borderRadius: BorderRadius.circular(12));
        break;
      case 'motivation':
        cardColor = Colors.green[100]!;
        elevation = 6.0;
        shape = RoundedRectangleBorder(borderRadius: BorderRadius.circular(8));
        break;
      case 'introspective':
        cardColor = Colors.blue[100]!;
        elevation = 2.0;
        shape = RoundedRectangleBorder(borderRadius: BorderRadius.circular(16));
        break;
      default:
        cardColor = Colors.white;
        elevation = 1.0;
        shape = RoundedRectangleBorder(borderRadius: BorderRadius.circular(4));
    }

    return Card(
        color: cardColor,
        elevation: elevation,
        shape: shape,
        margin: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Text(
                quote.text,
                style: TextStyle(
                  fontSize: 18.0,
                  color: Colors.grey[600],
                ),
              ),
              SizedBox(height: 6.0),
              Text(
                quote.author,
                style: TextStyle(
                  fontSize: 14.0,
                  color: Colors.grey[800],
                ),
              ),
              SizedBox(height: 6.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    quote.category,
                    style: TextStyle(
                      fontSize: 14.0,
                      color: Colors.grey[800],
                    ),
                  ),
                  LikeButton(quote: quote),
                  Text(
                  quote.created.toLocal().toString().substring(0, 16),
                  style: TextStyle(
                    fontSize: 14.0,
                    color: Colors.grey[800],
                  ),
                ),
                ],
              ),
            ],
          ),
        )
    );
  }
}