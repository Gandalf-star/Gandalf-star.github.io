import 'dart:ui_web' as ui;
import 'package:flutter/material.dart';
import 'package:web/web.dart' as web;

Widget getPlatformImage(String url,
    {double? width, double? height, BoxFit? fit}) {
  // Unique ID for each image view to avoid collisions
  final String viewId =
      'image-view-${url.hashCode}-${DateTime.now().millisecondsSinceEpoch}';

  // Register the view factory
  // Note: ideally this should be done once, but for simplicity/robustness we check/register.
  // ignore: undefined_prefixed_name
  ui.platformViewRegistry.registerViewFactory(viewId, (int viewId) {
    final element = web.document.createElement('img') as web.HTMLImageElement;
    element.src = url;
    element.style.width = '100%';
    element.style.height = '100%';
    element.style.objectFit = _getBoxFit(fit);
    return element;
  });

  return SizedBox(
    width: width,
    height: height,
    child: HtmlElementView(viewType: viewId),
  );
}

String _getBoxFit(BoxFit? fit) {
  switch (fit) {
    case BoxFit.contain:
      return 'contain';
    case BoxFit.cover:
      return 'cover';
    case BoxFit.fill:
      return 'fill';
    case BoxFit.fitHeight:
      return 'contain'; // approximation
    case BoxFit.fitWidth:
      return 'contain'; // approximation
    case BoxFit.none:
      return 'none';
    case BoxFit.scaleDown:
      return 'scale-down';
    default:
      return 'cover';
  }
}
