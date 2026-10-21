import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:msmart_kids_faceid/features/hikvision/presentation/pages/hikvision_screen.dart';

void main() {
  testWidgets('failure view provides a retry action', (tester) async {
    var retried = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: HikvisionFailureView(
            message:
                'Face ID qurilmasiga yuborilgan ma\'lumot noto\'g\'ri. Qayta urinib ko\'ring.',
            onRetry: () => retried = true,
          ),
        ),
      ),
    );

    expect(find.text('Qayta urinib ko‘rish'), findsOneWidget);

    await tester.tap(find.text('Qayta urinib ko‘rish'));
    expect(retried, isTrue);
  });
}
