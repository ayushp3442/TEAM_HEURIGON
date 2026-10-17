import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:peer_tutoring_board/main.dart';
import 'package:peer_tutoring_board/providers/auth_provider.dart';
import 'package:peer_tutoring_board/services/auth_service.dart';
import 'package:peer_tutoring_board/services/subject_service.dart';
import 'package:peer_tutoring_board/services/tutor_service.dart';
import 'package:peer_tutoring_board/services/slot_service.dart';
import 'package:peer_tutoring_board/services/request_service.dart';
import 'package:peer_tutoring_board/services/chat_service.dart';
import 'package:peer_tutoring_board/services/service_locator.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          Provider<AuthService>(create: (_) => ServiceLocator.auth),
          Provider<SubjectService>(create: (_) => ServiceLocator.subjects),
          Provider<TutorService>(create: (_) => ServiceLocator.tutors),
          Provider<SlotService>(create: (_) => ServiceLocator.slots),
          Provider<RequestService>(create: (_) => ServiceLocator.requests),
          Provider<ChatService>(create: (_) => ServiceLocator.chat),
          ChangeNotifierProxyProvider<AuthService, AuthProvider>(
            create: (ctx) => AuthProvider(ctx.read<AuthService>()),
            update: (ctx, svc, prev) => prev ?? AuthProvider(svc),
          ),
        ],
        child: const PeerTutoringApp(),
      ),
    );
    await tester.pump();
    expect(find.byType(MaterialApp), findsOneWidget);

    // Clean up tree to resolve precache / image timers
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 2));
  });
}
