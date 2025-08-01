// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ai_image_editor_flutter/main.dart';

void main() {
  testWidgets('AI Image Editor app test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const AIImageEditorApp());

    // Verify that our app loads with the upload widget
    expect(find.text('AI Image Editor'), findsOneWidget);
    expect(find.text('Tải Ảnh Lên'), findsOneWidget);
  });
}
