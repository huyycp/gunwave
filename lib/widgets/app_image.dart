import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class AppImage extends StatelessWidget {
  final String path;
  final double? width;
  final double? height;
  final BorderRadius borderRadius;
  final bool isCircle;
  Widget? placeHolder;
  Color? color;
  final BoxFit fit;

  AppImage(
    this.path, {
    super.key,
    this.width = double.infinity,
    this.height = double.infinity,
    this.borderRadius = BorderRadius.zero,
    this.isCircle = false,
    this.placeHolder = const SizedBox.shrink(),
    this.color,
    this.fit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    final imageType = path.substring(path.lastIndexOf('.') + 1);
    placeHolder ??= Container(color: Colors.grey);
    Widget image = placeHolder!;
    if (imageType.isNotEmpty && path.isNotEmpty) {
      switch (imageType) {
        case 'svg': {
          if (path.startsWith('http')) {
            image = SvgPicture.network(
              path,
              width: width,
              height: height,
              fit: fit,
              color: color,
            );
          } else {
            image = SvgPicture.asset(
              path,
              width: width,
              height: height,
              fit: fit,
              color: color,
            );
          }
          break;
        }
        default: {
          if (path.startsWith('http')) {
            image = CachedNetworkImage(
              imageUrl: path,
              width: width,
              height: height,
              fit: fit,
              color: color,
              errorWidget: (_, __, ___) => placeHolder!,
            );
          } else if (path.startsWith('/')) {
            image = Image.file(
              File(path),
              width: width,
              height: height,
              fit: fit,
              color: color,
              errorBuilder: (_, __, ___) => placeHolder!,
            );
          } else {
            image = Image.asset(
              path,
              width: width,
              height: height,
              fit: fit,
              color: color,
              errorBuilder: (_, __, ___) => placeHolder!,
            );
          }
        }
      }
    }
    return isCircle
      ? SizedBox(
          width: width,
          height: height,
          child: ClipOval(
            child: image,
          ),
        )
      : SizedBox(
          width: width,
          height: height,
          child: ClipRRect(
            borderRadius: borderRadius,
            child: image,
          ),
        );
  }
}
