import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gunwave/views/game/widgets/rank_submission_loading_dialog.dart';

void main() {
  testWidgets('system Back keeps the rank dialog until its route is removed', (
    tester,
  ) async {
    late NavigatorState navigator;
    late DialogRoute<void> route;

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            navigator = Navigator.of(context);
            return Scaffold(
              body: TextButton(
                onPressed: () {
                  route = DialogRoute<void>(
                    context: context,
                    barrierDismissible: false,
                    builder: (_) => const RankSubmissionLoadingDialog(),
                  );
                  navigator.push<void>(route);
                },
                child: const Text('Submit rank'),
              ),
            );
          },
        ),
      ),
    );

    await tester.tap(find.text('Submit rank'));
    await tester.pump(const Duration(milliseconds: 250));
    expect(find.byType(RankSubmissionLoadingDialog), findsOneWidget);

    await tester.binding.handlePopRoute();
    await tester.pump();
    expect(find.byType(RankSubmissionLoadingDialog), findsOneWidget);

    navigator.removeRoute(route);
    await tester.pump(const Duration(milliseconds: 250));
    expect(find.byType(RankSubmissionLoadingDialog), findsNothing);
    expect(find.text('Submit rank'), findsOneWidget);
  });
}
