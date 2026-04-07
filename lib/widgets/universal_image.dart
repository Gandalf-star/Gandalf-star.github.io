import 'package:flutter/material.dart';
import 'platform_image_stub.dart'
    if (dart.library.io) 'platform_image_mobile.dart'
    if (dart.library.html) 'platform_image_web.dart';

class UniversalImage extends StatelessWidget {
  final String url;
  final double? width;
  final double? height;
  final BoxFit? fit;

  const UniversalImage({
    super.key,
    required this.url,
    this.width,
    this.height,
    this.fit,
  });

  @override
  Widget build(BuildContext context) {
    if (url.isEmpty) {
      return Container(
        width: width,
        height: height,
        color: Colors.grey[300],
        child: const Icon(Icons.image, color: Colors.grey),
      );
    }
    return getPlatformImage(url, width: width, height: height, fit: fit);
  }
}
