// Basic smoke test for the ShopSphere app shell.

import 'package:ecommerce_app/my_app.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('App builds and shows splash branding', (tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pump();

    expect(find.text('ShopSphere'), findsOneWidget);
  });
}
