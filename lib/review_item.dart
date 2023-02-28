import 'package:flutter/material.dart';
import 'package:pontozz/api.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class ReviewItem extends StatefulWidget {
  const ReviewItem({Key? key, required this.review}) : super(key: key);

  final Review review;

  @override
  State<ReviewItem> createState() => _ReviewItemState();
}

class _ReviewItemState extends State<ReviewItem> {
  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

        Text(widget.review.user!),
        RatingBarIndicator(
            rating: widget.review.score != null ? widget.review.score!.toDouble() : 0,
            itemCount: 5,
            itemSize: 15.0,
            itemPadding: EdgeInsets.symmetric(horizontal: 2.0),
            itemBuilder: (context, _) => Icon(
              Icons.star,
              color: Color(0xFFd2ac67),
            )
        ),
      Text(widget.review.review!, style: TextStyle(fontStyle: FontStyle.italic, color: Color(0xFFd2ac67)))
    ],);
  }
}
