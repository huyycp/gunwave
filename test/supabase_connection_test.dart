import 'dart:convert';
import 'dart:io';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';

// Run only this live smoke test with:
// flutter test test/supabase_connection_test.dart \
//   --dart-define=RUN_SUPABASE_CONNECTION_TEST=true
const _runLiveConnectionTest =
    bool.fromEnvironment('RUN_SUPABASE_CONNECTION_TEST');

void main() {
  test(
    'development Supabase Auth health endpoint accepts the project key',
    () async {
      final envFile = File('dev.env');
      if (!envFile.existsSync()) {
        fail('dev.env is required to run the Supabase connection smoke test.');
      }

      dotenv.testLoad(fileInput: envFile.readAsStringSync());
      final url = dotenv.env['SUPABASE_URL'];
      final anonKey = dotenv.env['SUPABASE_ANON_KEY'];
      if (url == null || url.isEmpty || anonKey == null || anonKey.isEmpty) {
        fail('Set SUPABASE_URL and SUPABASE_ANON_KEY in dev.env.');
      }

      final httpClient = HttpClient();
      try {
        final request = await httpClient.getUrl(Uri.parse('$url/auth/v1/health'));
        request.headers.set('apikey', anonKey);
        final response = await request.close().timeout(
          const Duration(seconds: 10),
        );
        final responseBody = await response
            .transform(utf8.decoder)
            .join()
            .timeout(const Duration(seconds: 5));

        expect(response.statusCode, HttpStatus.ok, reason: responseBody);
        final health = jsonDecode(responseBody) as Map<String, dynamic>;
        expect(health['name'], 'GoTrue');
      } finally {
        httpClient.close(force: true);
      }
    },
    skip: _runLiveConnectionTest
        ? false
        : 'Opt in with --dart-define=RUN_SUPABASE_CONNECTION_TEST=true.',
    timeout: const Timeout(Duration(seconds: 20)),
  );
}
