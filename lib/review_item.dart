import 'package:flutter/material.dart';
import 'package:pontozz/api.dart';

class ReviewItem extends StatefulWidget {
  const ReviewItem({Key? key, required this.review}) : super(key: key);

  final Review review;

  @override
  State<ReviewItem> createState() => _ReviewItemState();
}

class _ReviewItemState extends State<ReviewItem> {
  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Row(children: [
        Text(widget.review.user!)
      ],),
      Text(widget.review.review!, style: TextStyle(fontStyle: FontStyle.italic))
    ],);
  }
}
