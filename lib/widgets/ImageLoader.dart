import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class ImageLoader extends StatelessWidget {
  final String imageUrl;
  final double width;
  final double height;
  final BorderRadius radius;

  const ImageLoader({
    super.key,
    required this.imageUrl,
    required this.width,
    required this.height,
    this.radius = BorderRadius.zero,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: radius,
      child: CachedNetworkImage(
        imageUrl: imageUrl,
        fit: BoxFit.cover,
        width: width,
        height: height,
        progressIndicatorBuilder: (context, url, progress) => Center(
          child: Image.asset(
            "Assets/Images/blankArtwork.jpg",
            fit: BoxFit.cover,
            width: width,
            height: height,
          ),
        ),
      ),
    );
  }
}
