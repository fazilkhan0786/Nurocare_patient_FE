// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:health_chatbot/main.dart';

void main() {
  testWidgets('App starts and displays home screen', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const HealthChatbotApp());

    // Verify that the main screen is displayed, which defaults to the HomeScreen.
    // A key widget on the HomeScreen is the FloatingActionButton with a chat icon.
    expect(find.byIcon(Icons.chat_bubble), findsOneWidget);

    // Verify the BottomNavigationBar is present.
    expect(find.byType(BottomNavigationBar), findsOneWidget);
  });
}
