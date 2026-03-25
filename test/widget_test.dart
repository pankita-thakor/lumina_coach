import 'package:flutter_test/flutter_test.dart';
import 'package:lumina_coach/app.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:lumina_coach/providers/preferences_provider.dart';

void main() {
  testWidgets('App mounts', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
        child: const LuminaCoachApp(),
      ),
    );
    await tester.pump();
    expect(find.byType(LuminaCoachApp), findsOneWidget);
  });
}
