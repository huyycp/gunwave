import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gunwave/build_config.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabaseApiProvider = Provider<SupabaseApi>((ref) => SupabaseApi());

class SupabaseApi {
  SupabaseApi._();
  static final SupabaseApi _instance = SupabaseApi._();

  factory SupabaseApi() {
    return _instance;
  }

  SupabaseClient get supabase => Supabase.instance.client;

  Future<void> init() async {
    await Supabase.initialize(
      url: BuildConfig.instance.supabaseUrl,
      anonKey: BuildConfig.instance.supabaseAnonKey,
    );
  }
}