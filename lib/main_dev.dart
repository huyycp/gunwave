import 'package:gunwave/build_config.dart';
import 'package:gunwave/main_prod.dart';

Future<void> main() async {
  await startApp(BuildEnv.dev);
}
