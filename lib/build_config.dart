import 'package:flutter_dotenv/flutter_dotenv.dart';

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

  late final String supabaseUrl;
  late final String supabaseAnonKey;

  void dev() {
    scheme = 'gunwave';
    iosAppId = 'com.huyvowkm.gunwave';
    androidBundleId = 'com.huyvowkm.gunwave';
    nativeUrl = '$scheme://';
    universalUrl = '';

    version = '';

    supabaseUrl = dotenv.env['SUPABASE_URL'] ?? '';
    supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY'] ?? '';
  }

  void prod() {
    scheme = 'gunwave';
    iosAppId = 'com.huyvowkm.gunwave';
    androidBundleId = 'com.huyvowkm.gunwave';
    nativeUrl = '$scheme://';
    universalUrl = '';
    
    version = '';

    supabaseUrl = '';
    supabaseAnonKey = '';
  }
}

enum BuildEnv {
  dev,
  prod,
}