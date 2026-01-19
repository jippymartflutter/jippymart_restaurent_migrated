import 'package:cached_network_image/cached_network_image.dart';
import 'package:jippymart_restaurant/constant/constant.dart';
import 'package:jippymart_restaurant/themes/responsive.dart';
import 'package:flutter/material.dart';

class NetworkImageWidget extends StatelessWidget {
  final String imageUrl;
  final double? height;
  final double? width;
  final Widget? errorWidget;
  final BoxFit? fit;
  final double? borderRadius;
  final Color? color;

  const NetworkImageWidget({
    super.key,
    this.height,
    this.width,
    this.fit,
    required this.imageUrl,
    this.borderRadius,
    this.errorWidget,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    // Check if the imageUrl is invalid (empty or the string "null")
    if (imageUrl.isEmpty || imageUrl == "null") {
      return errorWidget ??
          Container(
            height: height ?? Responsive.height(8, context),
            width: width ?? Responsive.width(15, context),
            color: Colors.grey[300],
            child: Icon(Icons.error_outline, color: Colors.grey),
          );
    }

    return CachedNetworkImage(
      imageUrl: imageUrl,
      fit: fit ?? BoxFit.fitWidth,
      height: height ?? Responsive.height(8, context),
      width: width ?? Responsive.width(15, context),
      color: color,
      progressIndicatorBuilder: (context, url, downloadProgress) =>
          Constant.loader(),
      errorWidget: (context, url, error) =>
      errorWidget ??
          Container(
            height: height ?? Responsive.height(8, context),
            width: width ?? Responsive.width(15, context),
            color: Colors.grey[300],
            child: Icon(Icons.error_outline, color: Colors.grey),
          ),
    );
  }
}