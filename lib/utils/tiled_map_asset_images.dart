import 'dart:ui';

import 'package:flame/cache.dart';

/// Loads Tiled's relative tileset image paths from Flutter's asset bundle.
class TiledMapAssetImages extends Images {
  TiledMapAssetImages() : super(prefix: '');

  @override
  Future<Image> load(String fileName, {String? key, String? package}) {
    return super.load(
      _resolveAssetPath(fileName),
      key: key ?? fileName,
      package: package,
    );
  }

  String _resolveAssetPath(String fileName) {
    if (fileName.startsWith('assets/')) return fileName;

    final segments = <String>['assets', 'tiles'];
    for (final segment in fileName.split('/')) {
      if (segment.isEmpty || segment == '.') continue;
      if (segment == '..') {
        if (segments.length == 1) {
          throw ArgumentError.value(
            fileName,
            'fileName',
            'Tiled image path escapes the app assets directory.',
          );
        }
        segments.removeLast();
      } else {
        segments.add(segment);
      }
    }
    return segments.join('/');
  }
}
