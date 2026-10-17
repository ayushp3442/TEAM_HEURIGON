import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:peer_tutoring_board/models/chat.dart';
import 'package:peer_tutoring_board/models/session_request.dart';
import 'package:peer_tutoring_board/models/subject.dart';
import 'package:peer_tutoring_board/widgets/chat_status_chip.dart';
import 'package:peer_tutoring_board/widgets/chat_tile.dart';

// Stage I2: Tests rewritten to remove MockChatService / MockAuthService
// (mocks deleted). Screen-level integration tests that needed real mock data
// are deferred to Stage I3 acceptance testing with the live backend.
// Widget-level tests retained unchanged — they depend only on model objects.

void main() {
  group('Stage I2: Chat Widget Tests (no mocks)', () {
    testWidgets(
        'ChatStatusChip renders OPEN with time remaining, CLOSED, and NOT_STARTED',
        (WidgetTester tester) async {
      final now = DateTime.now();

      // 1. OPEN > 1 hour
      final openChat = ChatInfo(
        state: ChatState.open,
        opensAt: now.subtract(const Duration(hours: 2)),
        closesAt: now.add(const Duration(hours: 18, minutes: 30)),
      );

      // 2. OPEN < 1 hour
      final urgentChat = ChatInfo(
        state: ChatState.open,
        opensAt: now.subtract(const Duration(hours: 23)),
        closesAt: now.add(const Duration(minutes: 35, seconds: 30)),
      );

      // 3. CLOSED
      final closedChat = ChatInfo(
        state: ChatState.closed,
        opensAt: now.subtract(const Duration(hours: 26)),
        closesAt: now.subtract(const Duration(hours: 2)),
      );

      // 4. NOT_STARTED
      final notStartedChat = ChatInfo(
        state: ChatState.notStarted,
        opensAt: now.add(const Duration(hours: 4)),
        closesAt: now.add(const Duration(hours: 28)),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                ChatStatusChip(chat: openChat),
                ChatStatusChip(chat: urgentChat),
                ChatStatusChip(chat: closedChat),
                ChatStatusChip(chat: notStartedChat),
              ],
            ),
          ),
        ),
      );

      expect(find.textContaining('Open, 18h'), findsOneWidget);
      expect(find.textContaining('Open, 35m'), findsOneWidget);
      expect(find.text('Closed'), findsOneWidget);
      expect(find.text('Opens after session'), findsOneWidget);
    });

    testWidgets(
        'ChatTile displays student/tutor name, subject, last message, time, and status chip',
        (WidgetTester tester) async {
      final now = DateTime.now();
      final item = ChatListItem(
        requestId: 56,
        otherUser: const UserRef(id: 2, name: 'Priya Verma'),
        subject: const Subject(id: 4, name: 'Data Structures'),
        slot: SlotRange(
          startTime: now.subtract(const Duration(hours: 4)),
          endTime: now.subtract(const Duration(hours: 3)),
        ),
        chat: ChatInfo(
          state: ChatState.open,
          opensAt: now.subtract(const Duration(hours: 3)),
          closesAt: now.add(const Duration(hours: 18, minutes: 30)),
        ),
        lastMessage: LastMessage(
          content: 'Thanks, that makes sense!',
          sentAt: now.subtract(const Duration(minutes: 30)),
          senderId: 1,
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ChatTile(item: item),
          ),
        ),
      );

      expect(find.text('Priya Verma'), findsOneWidget);
      expect(find.text('Data Structures'), findsOneWidget);
      expect(find.text('Thanks, that makes sense!'), findsOneWidget);
      expect(find.textContaining('Open, 18h'), findsOneWidget);
    });

    testWidgets('ChatTile renders correctly when lastMessage is null',
        (WidgetTester tester) async {
      final now = DateTime.now();
      final item = ChatListItem(
        requestId: 99,
        otherUser: const UserRef(id: 5, name: 'Ananya Rao'),
        subject: const Subject(id: 2, name: 'Physics'),
        slot: SlotRange(
          startTime: now.add(const Duration(hours: 2)),
          endTime: now.add(const Duration(hours: 3)),
        ),
        chat: ChatInfo(
          state: ChatState.notStarted,
          opensAt: now.add(const Duration(hours: 3)),
          closesAt: now.add(const Duration(hours: 27)),
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: ChatTile(item: item)),
        ),
      );

      expect(find.text('Ananya Rao'), findsOneWidget);
      expect(find.text('Physics'), findsOneWidget);
      expect(find.text('Opens after session'), findsOneWidget);
    });
  });
}
