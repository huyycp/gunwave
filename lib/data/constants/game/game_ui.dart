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
  static final progressFrame = Assets.images.ui.buttons.buttonSquare;
  static final progressBackground =
      Assets.images.ui.buttons.buttonSquareDisabled;
  static final progressFill = Assets.images.ui.buttons.buttonSquareHover;
}
