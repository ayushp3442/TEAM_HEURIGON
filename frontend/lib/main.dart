import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:provider/provider.dart';
import 'core/theme.dart';
import 'core/router.dart';
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthProvider>().restoreSession();
    });
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
