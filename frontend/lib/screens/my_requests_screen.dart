import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../core/theme.dart';
import '../core/constants.dart';
import '../models/session_request.dart';
import '../services/request_service.dart';
import '../widgets/request_card.dart';
import '../widgets/skeleton.dart';
import '../widgets/empty_state.dart';
import '../core/api_client.dart';

// The 4 filter tabs shown in My Requests.
const _tabs = [
  ('All',      null),
  ('Pending',  RequestStatus.pending),
  ('Accepted', RequestStatus.accepted),
  ('Declined', RequestStatus.declined),
];

class MyRequestsScreen extends StatefulWidget {
  const MyRequestsScreen({super.key});

  @override
  State<MyRequestsScreen> createState() => _MyRequestsScreenState();
}

class _MyRequestsScreenState extends State<MyRequestsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabCtrl;
  late Future<List<SessionRequest>> _future;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: _tabs.length, vsync: this);
    _load();
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  void _load() {
    setState(() {
      _future = context.read<RequestService>().outgoing();
    });
  }

  Future<void> _handleCancel(int id) async {
    await context.read<RequestService>().cancel(id);
    _load(); // reload the whole list
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // Page header
          Padding(
            padding: const EdgeInsets.fromLTRB(
                AppLayout.space16, AppLayout.space24,
                AppLayout.space16, AppLayout.space16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'My Requests',
                style: Theme.of(context).textTheme.displaySmall,
              ),
            ),
          ),

          // Tab bar
          Container(
            color: AppColors.surface,
            child: Column(children: [
              const Divider(height: 1),
              TabBar(
                controller: _tabCtrl,
                tabs: _tabs
                    .map((t) => Tab(text: t.$1))
                    .toList(),
              ),
              const Divider(height: 1),
            ]),
          ),

          // Tab views
          Expanded(
            child: FutureBuilder<List<SessionRequest>>(
              future: _future,
              builder: (ctx, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return _SkeletonList();
                }

                if (snap.hasError) {
                  return _ErrorRetry(
                    message: ApiClient.errorMessage(snap.error!),
                    onRetry: _load,
                  );
                }

                final all = snap.data!;

                return TabBarView(
                  controller: _tabCtrl,
                  children: _tabs.map((t) {
                    final filtered = t.$2 == null
                        ? all
                        : all.where((r) => r.status == t.$2).toList();
                    return _RequestList(
                      requests: filtered,
                      tabLabel: t.$1,
                      onCancel: _handleCancel,
                      onRefresh: _load,
                    );
                  }).toList(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Single tab list
// ---------------------------------------------------------------------------
class _RequestList extends StatelessWidget {
  final List<SessionRequest>              requests;
  final String                            tabLabel;
  final Future<void> Function(int id)     onCancel;
  final VoidCallback                      onRefresh;

  const _RequestList({
    required this.requests,
    required this.tabLabel,
    required this.onCancel,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    if (requests.isEmpty) {
      return EmptyState(
        icon: Icons.inbox_outlined,
        message: tabLabel == 'All'
            ? 'You have not sent any session requests yet.'
            : 'No $tabLabel requests.',
        actionLabel: tabLabel == 'All' ? 'Browse tutors' : null,
        onAction:    tabLabel == 'All' ? () => context.go('/browse') : null,
      );
    }

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () async => onRefresh(),
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(
            AppLayout.space16, AppLayout.space16,
            AppLayout.space16, AppLayout.space24),
        itemCount: requests.length,
        itemBuilder: (_, i) => RequestCard(
          request:  requests[i],
          onCancel: onCancel,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Loading skeleton
// ---------------------------------------------------------------------------
class _SkeletonList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(
          AppLayout.space16, AppLayout.space16,
          AppLayout.space16, AppLayout.space24),
      itemCount: 4,
      itemBuilder: (_, __) => const Padding(
        padding: EdgeInsets.only(bottom: AppLayout.space12),
        child: RequestCardSkeleton(),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Error retry view
// ---------------------------------------------------------------------------
class _ErrorRetry extends StatelessWidget {
  final String       message;
  final VoidCallback onRetry;
  const _ErrorRetry({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.wifi_off_outlined, size: 32, color: AppColors.muted),
          const SizedBox(height: AppLayout.space12),
          Text(
            message,
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: AppColors.muted),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppLayout.space16),
          OutlinedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_outlined, size: 16),
            label: const Text('Try again'),
          ),
        ],
      ),
    );
  }
}
