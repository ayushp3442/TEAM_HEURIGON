import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../core/constants.dart';
import '../core/theme.dart';
import '../providers/auth_provider.dart';
import '../widgets/brand_logo.dart';

// ---------------------------------------------------------------------------
// AppShell — persistent navigation wrapper.
// NavigationRail at width >= 1000, BottomNavigationBar below that.
// AppBar: title + user avatar menu.
// Architecture.md Section 7.4.
// ---------------------------------------------------------------------------
class AppShell extends StatefulWidget {
  final Widget child;
  const AppShell({super.key, required this.child});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  // Determine active index from current route.
  int _indexForRoute(String location, bool isTutor) {
    if (isTutor) {
      if (location.startsWith('/dashboard')) return 0;
      if (location.startsWith('/browse'))    return 1;
      if (location.startsWith('/chats'))     return 2;
    } else {
      if (location.startsWith('/browse'))     return 0;
      if (location.startsWith('/my-requests'))return 1;
      if (location.startsWith('/chats'))      return 2;
    }
    return 0;
  }

  void _onTabTap(int index, bool isTutor) {
    final routes = isTutor
        ? ['/dashboard', '/browse', '/chats']
        : ['/browse', '/my-requests', '/chats'];
    context.go(routes[index]);
  }

  List<_NavItem> _items(bool isTutor) {
    if (isTutor) {
      return const [
        _NavItem(icon: Icons.dashboard_outlined,  label: 'Dashboard'),
        _NavItem(icon: Icons.search_outlined,      label: 'Browse'),
        _NavItem(icon: Icons.chat_bubble_outline,  label: 'Chats'),
      ];
    }
    return const [
      _NavItem(icon: Icons.search_outlined,       label: 'Browse'),
      _NavItem(icon: Icons.assignment_outlined,   label: 'My Requests'),
      _NavItem(icon: Icons.chat_bubble_outline,   label: 'Chats'),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final auth     = context.watch<AuthProvider>();
    final isTutor  = auth.isTutor;
    final location = GoRouterState.of(context).matchedLocation;
    final index    = _indexForRoute(location, isTutor);
    final items    = _items(isTutor);
    final width    = MediaQuery.of(context).size.width;
    final isWide   = width >= AppLayout.desktopBreakpoint;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(context, auth),
      body: Row(
        children: [
          // Navigation Rail (wide screens)
          if (isWide)
            Container(
              decoration: const BoxDecoration(
                color: AppColors.surface,
                border: Border(right: BorderSide(color: AppColors.border)),
              ),
              child: NavigationRail(
                selectedIndex:  index,
                onDestinationSelected: (i) => _onTabTap(i, isTutor),
                labelType:      NavigationRailLabelType.all,
                backgroundColor: AppColors.surface,
                destinations: items
                    .map((e) => NavigationRailDestination(
                          icon: Icon(e.icon),
                          label: Text(e.label),
                        ))
                    .toList(),
              ),
            ),

          // Main content — centered with max width 1100
          Expanded(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: AppLayout.maxContentWidth),
                child: widget.child,
              ),
            ),
          ),
        ],
      ),

      // Bottom nav (narrow screens)
      bottomNavigationBar: isWide
          ? null
          : Container(
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: AppColors.border)),
              ),
              child: NavigationBar(
                selectedIndex: index,
                onDestinationSelected: (i) => _onTabTap(i, isTutor),
                destinations: items
                    .map((e) => NavigationDestination(
                          icon:  Icon(e.icon),
                          label: e.label,
                        ))
                    .toList(),
              ),
            ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, AuthProvider auth) {
    return AppBar(
      title: StudyCircleLogo(
        height: 32,
        showText: true,
        onTap: () => context.go(auth.isTutor ? '/dashboard' : '/browse'),
      ),
      actions: [
        _UserMenu(auth: auth),
        const SizedBox(width: 8),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// User avatar menu — initials, name, role, logout.
// ---------------------------------------------------------------------------
class _UserMenu extends StatelessWidget {
  final AuthProvider auth;
  const _UserMenu({required this.auth});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      offset: const Offset(0, 48),
      color: AppColors.surface,
      elevation: 0,
      shape: const RoundedRectangleBorder(
        borderRadius: AppTheme.borderRadius,
        side: BorderSide(color: AppColors.border),
      ),
      child: CircleAvatar(
        radius: 16,
        backgroundColor: AppColors.primary,
        child: Text(
          auth.initials,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.onPrimary,
          ),
        ),
      ),
      onSelected: (value) async {
        if (value == 'logout') {
          await auth.logout();
          if (context.mounted) context.go('/login');
        } else if (value == 'privacy') {
          context.go('/privacy');
        } else if (value == 'terms') {
          context.go('/terms');
        }
      },
      itemBuilder: (_) => [
        PopupMenuItem(
          enabled: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(auth.displayName,
                  style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.ink)),
              const SizedBox(height: 2),
              Text(auth.isTutor ? 'Tutor' : 'Student',
                  style: const TextStyle(fontSize: 12, color: AppColors.muted)),
            ],
          ),
        ),
        const PopupMenuDivider(),
        const PopupMenuItem(
          value: 'privacy',
          child: Row(
            children: [
              Icon(Icons.privacy_tip_outlined, size: 16, color: AppColors.muted),
              SizedBox(width: 8),
              Text('Privacy Policy'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'terms',
          child: Row(
            children: [
              Icon(Icons.description_outlined, size: 16, color: AppColors.muted),
              SizedBox(width: 8),
              Text('Terms of Service'),
            ],
          ),
        ),
        const PopupMenuDivider(),
        const PopupMenuItem(
          value: 'logout',
          child: Row(
            children: [
              Icon(Icons.logout_outlined, size: 16, color: AppColors.declined),
              SizedBox(width: 8),
              Text('Log out', style: TextStyle(color: AppColors.declined)),
            ],
          ),
        ),
      ],
    );
  }
}

class _NavItem {
  final IconData icon;
  final String   label;
  const _NavItem({required this.icon, required this.label});
}
