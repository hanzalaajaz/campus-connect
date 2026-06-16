import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class AppImage extends StatelessWidget {
  final String imageUrl;
  final double? height;
  final double? width;
  final BoxFit fit;
  final Widget Function(BuildContext, String)? placeholder;
  final Widget Function(BuildContext, String, dynamic)? errorWidget;

  const AppImage({
    super.key,
    required this.imageUrl,
    this.height,
    this.width,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.errorWidget,
  });

  static ImageProvider provider(String url) {
    if (url.startsWith('data:image')) {
      return MemoryImage(base64Decode(url.split(',').last));
    }
    return NetworkImage(url);
  }

  @override
  Widget build(BuildContext context) {
    if (imageUrl.startsWith('data:image')) {
      return Image.memory(
        base64Decode(imageUrl.split(',').last),
        height: height,
        width: width,
        fit: fit,
        errorBuilder: (ctx, err, stack) => errorWidget != null
            ? errorWidget!(ctx, imageUrl, err)
            : const SizedBox(),
      );
    }

    return CachedNetworkImage(
      imageUrl: imageUrl,
      height: height,
      width: width,
      fit: fit,
      placeholder: placeholder,
      errorWidget: errorWidget,
    );
  }
}
