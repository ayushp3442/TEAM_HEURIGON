import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:provider/provider.dart';
import 'core/theme.dart';
import 'core/router.dart';
import 'core/api_client.dart';
import 'core/formatters.dart';
import 'providers/auth_provider.dart';
import 'services/auth_service.dart';
import 'services/subject_service.dart';
import 'services/tutor_service.dart';
import 'services/slot_service.dart';
import 'services/request_service.dart';
import 'services/chat_service.dart';
import 'services/service_locator.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  usePathUrlStrategy();
  runApp(
    MultiProvider(
      providers: [
        // Services — toggled by dev_flags.dart
        Provider<AuthService>(    create: (_) => ServiceLocator.auth),
        Provider<SubjectService>( create: (_) => ServiceLocator.subjects),
        Provider<TutorService>(   create: (_) => ServiceLocator.tutors),
        Provider<SlotService>(    create: (_) => ServiceLocator.slots),
        Provider<RequestService>( create: (_) => ServiceLocator.requests),
        Provider<ChatService>(    create: (_) => ServiceLocator.chat),

        // AuthProvider injected with AuthService
        ChangeNotifierProxyProvider<AuthService, AuthProvider>(
          create:  (ctx) => AuthProvider(ctx.read<AuthService>()),
          update:  (ctx, svc, prev) => prev ?? AuthProvider(svc),
        ),
      ],
      child: const PeerTutoringApp(),
    ),
  );
}

class PeerTutoringApp extends StatefulWidget {
  const PeerTutoringApp({super.key});

  @override
  State<PeerTutoringApp> createState() => _PeerTutoringAppState();
}

class _PeerTutoringAppState extends State<PeerTutoringApp> {
  late final _router = buildRouter(context);

  @override
  void initState() {
    super.initState();
    if (kDebugMode) {
      _checkHealthClock();
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthProvider>().restoreSession();
    });
  }

  Future<void> _checkHealthClock() async {
    try {
      final res = await ApiClient.dio.get('/health');
      final data = res.data is Map ? res.data as Map : {};
      final serverTime = data['serverTime'] ?? 'N/A';
      final timeZone = data['timeZone'] ?? 'N/A';
      final localTime = AppFormatters.apiDateTime(DateTime.now());
      debugPrint('====================================');
      debugPrint('[CLOCK CHECK] Backend health status: ${data['status']}');
      debugPrint('[CLOCK CHECK] Backend serverTime:   $serverTime (Zone: $timeZone)');
      debugPrint('[CLOCK CHECK] Browser localTime:    $localTime');
      debugPrint('====================================');
    } catch (e) {
      debugPrint('[CLOCK CHECK] Backend health check failed on startup: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Peer Tutoring Board',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.build(),
      routerConfig: _router,
    );
  }
}
