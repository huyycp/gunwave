import 'dart:ui' show Rect;

import 'package:gunwave/gen/assets.gen.dart';

class GameBanners {
  const GameBanners._(this.name, this.path);

  final String name;
  final String path;

  static const className = 'banners';
  static final basePath = Assets.images.ui.banners;

  bool get isVertical =>
      this == bannerVertical || this == bannerDown || this == bannerUp;
  bool get isHorizontal =>
      this == bannerHorizontal || this == bannerLeft || this == bannerRight;
  bool get isCarved =>
      this == carved || this == carvedSlide || this == carvedSquare;

  static final values = [
    bannerDown,
    bannerUp,
    bannerLeft,
    bannerRight,
    bannerVertical,
    bannerHorizontal,
    carved,
    carvedSlide,
    carvedSquare,
  ];

  static final bannerDown = GameBanners._(
    'banner_down',
    basePath.bannerDown.path,
  );

  static final bannerUp = GameBanners._('banner_up', basePath.bannerUp.path);

  static final bannerLeft = GameBanners._(
    'banner_left',
    basePath.bannerLeft.path,
  );

  static final bannerRight = GameBanners._(
    'banner_right',
    basePath.bannerRight.path,
  );

  static final bannerVertical = GameBanners._(
    'banner_vertical',
    basePath.bannerVertical.path,
  );

  static final bannerHorizontal = GameBanners._(
    'banner_horizontal',
    basePath.bannerHorizontal.path,
  );

  static final carved = GameBanners._('carved', basePath.carved.path);

  static final carvedSlide = GameBanners._(
    'carved_slide',
    basePath.carvedSlide.path,
  );

  static final carvedSquare = GameBanners._(
    'carved_square',
    basePath.carvedSquare.path,
  );
}

/// Shared image and metadata paths used by the Flame RPG interface.
abstract final class GameUiAssets {
  static final panel = Assets.images.ui.banners.carvedSquare;
  static final font = Assets.images.ui.fonts.uiFont;
  static final fontMetadataPath = Assets.images.ui.fonts.uiFontGlyphs;
  static final smallBarBase = Assets.images.ui.bars.smallBarBase;
  static final smallBarFill = Assets.images.ui.bars.smallBarFill;
  static final bigBarBase = Assets.images.ui.bars.bigBarBase;
  static final bigBarFill = Assets.images.ui.bars.bigBarFill;
  // Visible alpha bounds from the official Tiny Swords bar sprites.
  static const smallBarFrameCrop = Rect.fromLTWH(49, 22, 222, 19);
  static const smallBarFillCrop = Rect.fromLTWH(0, 30, 64, 3);
  static const bigBarFrameCrop = Rect.fromLTWH(40, 9, 240, 51);
  static const bigBarFillCrop = Rect.fromLTWH(0, 20, 64, 24);
  static const smallBarCapWidth = 20.0;
  static const bigBarCapWidth = 36.0;
  static final stageRoutePointer = Assets.images.ui.pointers.indicator;
}
