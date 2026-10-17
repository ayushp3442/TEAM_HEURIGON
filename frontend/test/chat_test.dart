import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:peer_tutoring_board/models/chat.dart';
import 'package:peer_tutoring_board/models/session_request.dart';
import 'package:peer_tutoring_board/models/subject.dart';
import 'package:peer_tutoring_board/services/chat_service.dart';
import 'package:peer_tutoring_board/dev_mocks/mock_chat_service.dart';
import 'package:peer_tutoring_board/widgets/chat_status_chip.dart';
import 'package:peer_tutoring_board/widgets/chat_tile.dart';
import 'package:peer_tutoring_board/screens/chats_screen.dart';
import 'package:peer_tutoring_board/screens/chat_screen.dart';
import 'package:peer_tutoring_board/providers/auth_provider.dart';
import 'package:peer_tutoring_board/dev_mocks/mock_auth_service.dart';

void main() {
  group('Stage F10: Chat Widgets & Screen Tests', () {
    testWidgets('ChatStatusChip renders OPEN with time remaining, CLOSED, and NOT_STARTED',
        (WidgetTester tester) async {
      final now = DateTime.now();

      // 1. OPEN > 1 hour (add 18h 30m so remaining is 18h)
      final openChat = ChatInfo(
        state: ChatState.open,
        opensAt: now.subtract(const Duration(hours: 2)),
        closesAt: now.add(const Duration(hours: 18, minutes: 30)),
      );

      // 2. OPEN < 1 hour (add 35m 30s so remaining is 35m)
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

    testWidgets('ChatTile displays student/tutor name, subject, last message, time, and status chip',
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

    testWidgets('ChatsScreen renders list of chats from MockChatService',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            Provider<ChatService>(create: (_) => MockChatService()),
          ],
          child: const MaterialApp(
            home: ChatsScreen(),
          ),
        ),
      );

      // Initial pump
      await tester.pump();
      // Pump to resolve 400ms delay in mock service
      await tester.pump(const Duration(milliseconds: 600));

      expect(find.text('Chats'), findsOneWidget);
      expect(find.text('Priya Verma'), findsOneWidget);
      expect(find.text('Dev Patel'), findsOneWidget);
      expect(find.text('Ananya Rao'), findsOneWidget);
      expect(find.text('Rohan Mehta'), findsOneWidget);
    });

    testWidgets('ChatScreen renders banner, message list, and input bar with polling',
        (WidgetTester tester) async {
      final mockAuth = MockAuthService();
      final authProvider = AuthProvider(mockAuth);

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            Provider<ChatService>(create: (_) => MockChatService()),
            ChangeNotifierProvider<AuthProvider>.value(value: authProvider),
          ],
          child: const MaterialApp(
            home: ChatScreen(requestId: 56),
          ),
        ),
      );

      // Initial pump
      await tester.pump();
      // Advance clock to resolve mock delays (list: 400ms, messages: 200ms)
      await tester.pump(const Duration(milliseconds: 800));
      await tester.pump(const Duration(milliseconds: 200));

      // Check app bar with other user name & subject
      expect(find.text('Priya Verma'), findsWidgets);
      expect(find.text('Data Structures'), findsOneWidget);

      // Check status banner
      expect(find.textContaining('This chat closes in'), findsOneWidget);

      // Check message bubbles
      expect(
        find.text('Hi Priya, thanks for the session on binary trees!'),
        findsOneWidget,
      );
      expect(
        find.text('Glad it helped! Remember to review tree traversals and recursion bases.'),
        findsOneWidget,
      );

      // Check date separator
      expect(find.text('Yesterday'), findsWidgets);

      // Check input bar
      expect(find.byType(TextField), findsOneWidget);
      expect(find.byIcon(Icons.send), findsOneWidget);
    });
  });
}
