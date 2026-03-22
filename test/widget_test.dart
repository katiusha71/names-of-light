import 'package:flutter_test/flutter_test.dart';
import 'package:names_of_light/main.dart';

void main() {
  testWidgets('App renders', (WidgetTester tester) async {
    await tester.pumpWidget(const NamesOfLightApp());
    await tester.pump();
    expect(find.text('72 Names of Light'), findsOneWidget);
  });
}
