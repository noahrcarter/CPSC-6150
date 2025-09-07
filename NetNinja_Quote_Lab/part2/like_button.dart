import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ninja_id2/quote.dart';

class LikeButton extends StatefulWidget {
  final Quote quote;

  const LikeButton({Key? key, required this.quote}) : super(key: key);

  @override
  _LikeButtonState createState() => _LikeButtonState();
}

class _LikeButtonState extends State<LikeButton> {
  late int likeCount;

  @override
  void initState() {
    super.initState();
    likeCount = widget.quote.likes;
  }

  void _incrementLike() {
    setState(() {
      widget.quote.incrementLike(widget.quote);
      likeCount = widget.quote.likes;
    });
    print('Quote liked, likes = $likeCount');
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: _incrementLike,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: Colors.white,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(Icons.favorite, color: Colors.red[400], size: 40),
          SizedBox(width: 8),
          Text(
            '$likeCount',
            style: TextStyle(color: Colors.grey[800]),
          ),
        ],
      ),
    );
  }
}