import 'package:gunwave/gen/assets.gen.dart';

class GameBanners {
  const GameBanners._(this.name, this.path);

  final String name;
  final String path;

  static const className = 'banners';
  static final basePath = Assets.images.ui.banners;

  bool get isVertical => this == bannerVertical || this == bannerDown || this == bannerUp;
  bool get isHorizontal => this == bannerHozizontal || this == bannerLeft || this == bannerRight;
  bool get isCarved => this == carved || this == carvedSlide || this == carvedSquare;

  static final values = [
    bannerDown,
    bannerUp,
    bannerLeft,
    bannerRight,
    bannerVertical,
    bannerHozizontal,
    carved,
    carvedSlide,
    carvedSquare,
  ];

  static final bannerDown = GameBanners._(
    'banner_down',
    basePath.bannerDown.path,
  );

  static final bannerUp = GameBanners._(
    'banner_up',
    basePath.bannerUp.path,
  );

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

  static final bannerHozizontal = GameBanners._(
    'banner_horizontal',
    basePath.bannerHorizontal.path,
  );

  static final carved = GameBanners._(
    'carved',
    basePath.carved.path,
  );

  static final carvedSlide = GameBanners._(
    'carved_slide',
    basePath.carvedSlide.path,
  );

  static final carvedSquare = GameBanners._(
    'carved_square',
    basePath.carvedSquare.path,
  );
}