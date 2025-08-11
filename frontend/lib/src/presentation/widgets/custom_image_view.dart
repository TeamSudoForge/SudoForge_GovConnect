import 'dart:io';
import 'package:flutter/material.dart';
import '../../core/theme/theme_config.dart';



// TODO: ADD images
// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:flutter_svg/flutter_svg.dart';
//
// enum ImageType { svg, png, network, networkSvg, file, unknown }
//
// extension ImageTypeExtension on String {
//   ImageType get imageType {
//     if (startsWith('http') || startsWith('https')) {
//       if (endsWith('.svg')) {
//         return ImageType.networkSvg;
//       }
//       return ImageType.network;
//     } else if (endsWith('.svg')) {
//       return ImageType.svg;
//     } else if (startsWith('file://')) {
//       return ImageType.file;
//     } else {
//       return ImageType.png;
//     }
//   }
// }
//
// class CustomImageView extends StatelessWidget {
//   CustomImageView({
//     this.imagePath,
//     this.height,
//     this.width,
//     this.color,
//     this.fit,
//     this.alignment,
//     this.onTap,
//     this.radius,
//     this.margin,
//     this.border,
//     this.placeHolder,
//   });
//
//   late String? imagePath;
//   final double? height;
//   final double? width;
//   final Color? color;
//   final BoxFit? fit;
//   final String? placeHolder;
//   final Alignment? alignment;
//   final VoidCallback? onTap;
//   final EdgeInsetsGeometry? margin;
//   final BorderRadius? radius;
//   final BoxBorder? border;
//
//   @override
//   Widget build(BuildContext context) {
//     // ...previous image rendering logic...
//   }
// }

class CustomImageView extends StatelessWidget {
  CustomImageView({
    this.imagePath,
    this.height,
    this.width,
    this.color,
    this.fit,
    this.alignment,
    this.onTap,
    this.radius,
    this.margin,
    this.border,
    this.placeHolder,
  });

  late String? imagePath;
  final double? height;
  final double? width;
  final Color? color;
  final BoxFit? fit;
  final String? placeHolder;
  final Alignment? alignment;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? margin;
  final BorderRadius? radius;
  final BoxBorder? border;

  @override
  Widget build(BuildContext context) {
    // Temporarily render nothing
    return const SizedBox.shrink();
  }
}
