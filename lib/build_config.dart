class BuildConfig {
  BuildConfig._();

  static final BuildConfig _instance = BuildConfig._();

  static BuildConfig get instance => _instance;

  late final String scheme;
  late final String nativeUrl;
  late final String iosAppId;
  late final String androidBundleId;
  late final String universalUrl;
  late final String version;

  void dev() {
    scheme = 'gunwave';
    iosAppId = 'com.huyvowkm.gunwave';
    androidBundleId = 'com.huyvowkm.gunwave';
    nativeUrl = '$scheme://';
    universalUrl = '';

    version = '';
  }

  void prod() {
    scheme = 'luckypool';
    iosAppId = 'com.huyvowkm.gunwave';
    androidBundleId = 'com.huyvowkm.gunwave';
    nativeUrl = '$scheme://';
    universalUrl = '';
    
    version = '';
  }
}