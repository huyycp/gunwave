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

    _loadSupabaseConfig();
  }

  void prod() {
    scheme = 'gunwave';
    iosAppId = 'com.huyvowkm.gunwave';
    androidBundleId = 'com.huyvowkm.gunwave';
    nativeUrl = '$scheme://';
    universalUrl = '';

    version = '';

    _loadSupabaseConfig();
  }

  void _loadSupabaseConfig() {
    final url = dotenv.env['SUPABASE_URL'];
    final anonKey = dotenv.env['SUPABASE_ANON_KEY'];
    if (url == null || url.isEmpty || anonKey == null || anonKey.isEmpty) {
      throw StateError(
        'SUPABASE_URL and SUPABASE_ANON_KEY must be set in the selected env file.',
      );
    }
    supabaseUrl = url;
    supabaseAnonKey = anonKey;
  }
}

enum BuildEnv {
  dev,
  prod,
}
