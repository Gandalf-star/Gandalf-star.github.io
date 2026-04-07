import 'package:flutter/material.dart';

Widget getPlatformImage(String url,
    {double? width, double? height, BoxFit? fit}) {
  return Image.network(
    url,
    width: width,
    height: height,
    fit: fit,
    errorBuilder: (context, error, stackTrace) {
      return Container(
        width: width,
        height: height,
        color: Colors.grey[200],
        child: const Icon(Icons.broken_image, color: Colors.grey),
      );
    },
    loadingBuilder: (context, child, loadingProgress) {
      if (loadingProgress == null) return child;
      return SizedBox(
        width: width,
        height: height,
        child: const Center(child: CircularProgressIndicator()),
      );
    },
  );
}
