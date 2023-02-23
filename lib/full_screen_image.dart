import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

class FullScreenImage extends StatelessWidget {
  final String imageUrl;
  final String tag;

  const FullScreenImage({required Key? key, required this.imageUrl, required this.tag}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      body: GestureDetector(
        child: Center(
          child: Hero(
            tag: tag,
            child: PhotoView(
            imageProvider: CachedNetworkImageProvider(
              imageUrl),
          )),
        ),
        onTap: () {
          Navigator.pop(context);
        },
      ),
    );
  }
}