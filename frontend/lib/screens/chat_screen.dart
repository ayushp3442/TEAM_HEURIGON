import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../core/theme.dart';
import '../core/constants.dart';
import '../core/formatters.dart';
import '../core/api_client.dart';
import '../models/chat.dart';
import '../models/session_request.dart';
import '../providers/auth_provider.dart';
import '../services/chat_service.dart';
import '../widgets/initials_avatar.dart';
import '../widgets/skeleton.dart';

// ---------------------------------------------------------------------------
// ChatScreen — Screen 8 (Single chat at /chats/:requestId)
// ---------------------------------------------------------------------------
class ChatScreen extends StatefulWidget {
  final int requestId;

  const ChatScreen({super.key, required this.requestId});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _scrollCtrl = ScrollController();
  final _textCtrl   = TextEditingController();
  final _focusNode  = FocusNode();

  ChatInfo?          _chatInfo;
  String             _otherUserName = 'Peer';
  String             _subjectName   = 'Subject';
  final List<ChatMessage> _messages = [];

  bool   _loadingInitial = true;
  String? _loadError;
  bool   _sending = false;

  Timer? _pollTimer;
  Timer? _countdownTimer;

  int get _lastMessageId => _messages.isEmpty ? 0 : _messages.last.id;

  @override
  void initState() {
    super.initState();
    _loadMetadataAndMessages();
    // Countdown updater: every 1 second to ensure smooth countdown & state transitions
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) => _onCountdownTick());
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    _countdownTimer?.cancel();
    _scrollCtrl.dispose();
    _textCtrl.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Data loading & Polling
  // ---------------------------------------------------------------------------
  Future<void> _loadMetadataAndMessages() async {
    setState(() {
      _loadingInitial = true;
      _loadError      = null;
    });

    try {
      final chatService = context.read<ChatService>();

      // Fetch chat list item to resolve names & subject
      try {
        final list = await chatService.list();
        final match = list.firstWhere((c) => c.requestId == widget.requestId);
        _otherUserName = match.otherUser.name;
        _subjectName   = match.subject.name;
        _chatInfo      = match.chat;
      } catch (_) {
        // Fallback names if not in list
      }

      // Fetch messages
      final resp = await chatService.messages(widget.requestId, afterId: 0);
      if (!mounted) return;

      setState(() {
        _chatInfo       = resp.chat;
        _messages.clear();
        _messages.addAll(resp.messages);
        _loadingInitial = false;
      });

      _scrollToBottom();
      _syncPollingState();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loadError      = ApiClient.errorMessage(e);
        _loadingInitial = false;
      });
    }
  }

  void _syncPollingState() {
    _pollTimer?.cancel();
    if (_chatInfo?.state == ChatState.open) {
      _pollTimer = Timer.periodic(const Duration(seconds: 3), (_) => _pollNewMessages());
    }
  }

  Future<void> _pollNewMessages() async {
    if (!mounted || _chatInfo?.state != ChatState.open) return;
    try {
      final resp = await context.read<ChatService>().messages(
            widget.requestId,
            afterId: _lastMessageId,
          );
      if (!mounted) return;

      if (resp.messages.isNotEmpty) {
        setState(() {
          _messages.addAll(resp.messages);
          _chatInfo = resp.chat;
        });
        _scrollToBottom();
      }
    } catch (_) {
      // Ignore background poll errors silently
    }
  }

  void _onCountdownTick() {
    if (!mounted || _chatInfo == null) return;

    if (_chatInfo!.state == ChatState.open) {
      final diff = _chatInfo!.closesAt.difference(DateTime.now());
      if (diff <= Duration.zero) {
        // Countdown reached zero -> switch to CLOSED dynamically without reload!
        setState(() {
          _chatInfo = ChatInfo(
            state:    ChatState.closed,
            opensAt:  _chatInfo!.opensAt,
            closesAt: _chatInfo!.closesAt,
          );
        });
        _pollTimer?.cancel();
      } else {
        // Re-render countdown text / accent color threshold
        setState(() {});
      }
    } else if (_chatInfo!.state == ChatState.notStarted) {
      final diff = _chatInfo!.opensAt.difference(DateTime.now());
      if (diff <= Duration.zero) {
        // Session ended -> chat is now open!
        setState(() {
          _chatInfo = ChatInfo(
            state:    ChatState.open,
            opensAt:  _chatInfo!.opensAt,
            closesAt: _chatInfo!.closesAt,
          );
        });
        _syncPollingState();
      }
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  // ---------------------------------------------------------------------------
  // Message Sending
  // ---------------------------------------------------------------------------
  Future<void> _sendMessage() async {
    final text = _textCtrl.text.trim();
    if (text.isEmpty || _sending || _chatInfo?.state != ChatState.open) return;

    setState(() => _sending = true);

    try {
      final msg = await context.read<ChatService>().send(widget.requestId, text);
      if (!mounted) return;

      setState(() {
        _textCtrl.clear();
        _messages.add(msg);
      });
      _scrollToBottom();
    } catch (e) {
      if (!mounted) return;
      final msg = ApiClient.errorMessage(e);

      // On 409 or other conflict: refresh state and messages from server
      await _loadMetadataAndMessages();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(msg),
            backgroundColor: AppColors.declined,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  // ---------------------------------------------------------------------------
  // UI Helpers
  // ---------------------------------------------------------------------------
  String get _otherInitials {
    final parts = _otherUserName.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return parts[0].isNotEmpty ? parts[0][0].toUpperCase() : '?';
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final currentUserId = auth.user?.id ?? 1;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        surfaceTintColor: AppColors.transparent,
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.ink),
          tooltip: 'Back to chats',
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/chats');
            }
          },
        ),
        titleSpacing: 0,
        title: Row(
          children: [
            InitialsAvatar(
              initials: _otherInitials,
              size: 34,
              backgroundColor: AppColors.primary,
              textColor: AppColors.onPrimary,
            ),
            const SizedBox(width: AppLayout.space12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _otherUserName,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.ink,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    _subjectName,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontSize: 11,
                          color: AppColors.muted,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: AppLayout.maxContentWidth),
          child: Column(
            children: [
              // 1. Status Banner
              if (_chatInfo != null) _StatusBanner(chat: _chatInfo!),

              // 2. Message Area / Loading / Error
              Expanded(
                child: _loadingInitial
                    ? const _SkeletonChatView()
                    : _loadError != null
                        ? _ChatErrorView(
                            error: _loadError!,
                            onRetry: _loadMetadataAndMessages,
                          )
                        : _MessageList(
                            messages:      _messages,
                            scrollCtrl:    _scrollCtrl,
                            currentUserId: currentUserId,
                          ),
              ),

              // 3. Input Bar
              _InputBar(
                textCtrl: _textCtrl,
                focusNode: _focusNode,
                isOpen:   _chatInfo?.state == ChatState.open,
                sending:  _sending,
                onSend:   _sendMessage,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Status Banner
// ---------------------------------------------------------------------------
class _StatusBanner extends StatelessWidget {
  final ChatInfo chat;

  const _StatusBanner({required this.chat});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    Color bg;
    Color fg;
    IconData icon;
    String text;

    switch (chat.state) {
      case ChatState.open:
        final diff = chat.closesAt.difference(DateTime.now());
        final isUrgent = diff < const Duration(hours: 1);
        final remainingStr = AppFormatters.remaining(chat.closesAt);

        if (isUrgent) {
          bg = AppColors.accent.withValues(alpha: 0.12);
          fg = AppColors.accent;
          icon = Icons.alarm;
          text = 'This chat closes soon ($remainingStr). Message history will be read-only.';
        } else {
          bg = AppColors.surface;
          fg = AppColors.primary;
          icon = Icons.schedule;
          text = 'This chat closes in $remainingStr. History will remain read-only afterwards.';
        }
        break;

      case ChatState.notStarted:
        bg = AppColors.pendingBg;
        fg = AppColors.pending;
        icon = Icons.lock_clock_outlined;
        text = 'Chat opens after your session ends at ${AppFormatters.time(chat.opensAt)} on ${AppFormatters.date(chat.opensAt)}.';
        break;

      case ChatState.closed:
        bg = AppColors.cancelledBg;
        fg = AppColors.muted;
        icon = Icons.lock_outline;
        text = 'This chat has closed. Message history is read-only.';
        break;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: AppLayout.space16, vertical: 10),
      decoration: BoxDecoration(
        color: bg,
        border: const Border(bottom: BorderSide(color: AppColors.border, width: 1)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: fg),
          const SizedBox(width: AppLayout.space8),
          Expanded(
            child: Text(
              text,
              style: tt.labelSmall?.copyWith(color: fg, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Message List with Date Separators
// ---------------------------------------------------------------------------
class _MessageList extends StatelessWidget {
  final List<ChatMessage> messages;
  final ScrollController  scrollCtrl;
  final int               currentUserId;

  const _MessageList({
    required this.messages,
    required this.scrollCtrl,
    required this.currentUserId,
  });

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  String _dateSeparator(DateTime dt) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final msgDate = DateTime(dt.year, dt.month, dt.day);

    if (msgDate == today) return 'Today';
    if (msgDate == yesterday) return 'Yesterday';
    return AppFormatters.date(dt);
  }

  @override
  Widget build(BuildContext context) {
    if (messages.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppLayout.space24),
          child: Text(
            'No messages in this chat yet.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.muted),
          ),
        ),
      );
    }

    return ListView.builder(
      controller: scrollCtrl,
      padding: const EdgeInsets.symmetric(
        horizontal: AppLayout.space16,
        vertical: AppLayout.space12,
      ),
      itemCount: messages.length,
      itemBuilder: (ctx, i) {
        final msg = messages[i];
        final isOwn = msg.senderId == currentUserId;

        final showDateSep = i == 0 || !_isSameDay(messages[i - 1].sentAt, msg.sentAt);

        return Column(
          children: [
            if (showDateSep)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: AppLayout.space12),
                child: _DateSeparatorPill(label: _dateSeparator(msg.sentAt)),
              ),
            _MessageBubble(message: msg, isOwn: isOwn),
          ],
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Date Separator Pill
// ---------------------------------------------------------------------------
class _DateSeparatorPill extends StatelessWidget {
  final String label;

  const _DateSeparatorPill({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: AppColors.border),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: AppColors.muted,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Message Bubble
// ---------------------------------------------------------------------------
class _MessageBubble extends StatelessWidget {
  final ChatMessage message;
  final bool        isOwn;

  const _MessageBubble({required this.message, required this.isOwn});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppLayout.space8),
      child: Align(
        alignment: isOwn ? Alignment.centerRight : Alignment.centerLeft,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isOwn ? AppColors.primary : AppColors.surface,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(AppLayout.space8),
                topRight: const Radius.circular(AppLayout.space8),
                bottomLeft: isOwn ? const Radius.circular(AppLayout.space8) : Radius.zero,
                bottomRight: isOwn ? Radius.zero : const Radius.circular(AppLayout.space8),
              ),
              border: isOwn ? null : Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment:
                  isOwn ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!isOwn) ...[
                  Text(
                    message.senderName,
                    style: tt.labelSmall?.copyWith(
                      color: AppColors.primaryDark,
                      fontWeight: FontWeight.w600,
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(height: 2),
                ],
                Text(
                  message.content,
                  style: tt.bodyMedium?.copyWith(
                    color: isOwn ? AppColors.onPrimary : AppColors.ink,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  AppFormatters.time(message.sentAt),
                  style: tt.labelSmall?.copyWith(
                    color: isOwn
                        ? AppColors.onPrimary.withValues(alpha: 0.75)
                        : AppColors.muted,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Input Bar (Multiline, Max 1000, Enter=Send, Shift+Enter=Newline)
// ---------------------------------------------------------------------------
class _InputBar extends StatefulWidget {
  final TextEditingController textCtrl;
  final FocusNode             focusNode;
  final bool                  isOpen;
  final bool                  sending;
  final VoidCallback          onSend;

  const _InputBar({
    required this.textCtrl,
    required this.focusNode,
    required this.isOpen,
    required this.sending,
    required this.onSend,
  });

  @override
  State<_InputBar> createState() => _InputBarState();
}

class _InputBarState extends State<_InputBar> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppLayout.space16,
        vertical: AppLayout.space12,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border, width: 1)),
      ),
      child: SafeArea(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Focus(
                onKeyEvent: (node, event) {
                  // Only listen to keydown events
                  if (event is KeyDownEvent &&
                      event.logicalKey == LogicalKeyboardKey.enter) {
                    if (HardwareKeyboard.instance.isShiftPressed) {
                      // Shift + Enter: Allow new line
                      return KeyEventResult.ignored;
                    } else {
                      // Enter: Send message
                      if (widget.isOpen &&
                          !widget.sending &&
                          widget.textCtrl.text.trim().isNotEmpty) {
                        widget.onSend();
                      }
                      return KeyEventResult.handled;
                    }
                  }
                  return KeyEventResult.ignored;
                },
                child: ValueListenableBuilder(
                  valueListenable: widget.textCtrl,
                  builder: (_, __, ___) => TextField(
                    controller: widget.textCtrl,
                    focusNode:  widget.focusNode,
                    enabled:    widget.isOpen && !widget.sending,
                    maxLines:   4,
                    minLines:   1,
                    maxLength:  1000,
                    textInputAction: TextInputAction.newline,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.ink,
                        ),
                    decoration: InputDecoration(
                      hintText: widget.isOpen
                          ? 'Type a message... (Enter to send, Shift+Enter for new line)'
                          : 'Chat is closed. History is read-only.',
                      hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.muted,
                          ),
                      counterText: '',
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      filled: true,
                      fillColor: widget.isOpen
                          ? AppColors.background
                          : AppColors.cancelledBg,
                      border: const OutlineInputBorder(
                        borderRadius: AppTheme.borderRadius,
                        borderSide: BorderSide(color: AppColors.border),
                      ),
                      enabledBorder: const OutlineInputBorder(
                        borderRadius: AppTheme.borderRadius,
                        borderSide: BorderSide(color: AppColors.border),
                      ),
                      focusedBorder: const OutlineInputBorder(
                        borderRadius: AppTheme.borderRadius,
                        borderSide: BorderSide(color: AppColors.primary, width: 1.5),
                      ),
                      disabledBorder: const OutlineInputBorder(
                        borderRadius: AppTheme.borderRadius,
                        borderSide: BorderSide(color: AppColors.border),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppLayout.space8),

            // Send Button
            ValueListenableBuilder(
              valueListenable: widget.textCtrl,
              builder: (_, __, ___) {
                final hasText = widget.textCtrl.text.trim().isNotEmpty;
                final canSend = widget.isOpen && !widget.sending && hasText;

                return SizedBox(
                  height: 44,
                  width: 44,
                  child: FilledButton(
                    onPressed: canSend ? widget.onSend : null,
                    style: FilledButton.styleFrom(
                      padding: EdgeInsets.zero,
                      backgroundColor: AppColors.primary,
                      disabledBackgroundColor: AppColors.border,
                      shape: const RoundedRectangleBorder(
                        borderRadius: AppTheme.borderRadius,
                      ),
                    ),
                    child: widget.sending
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.onPrimary,
                            ),
                          )
                        : Icon(
                            Icons.send,
                            size: 18,
                            color: canSend
                                ? AppColors.onPrimary
                                : AppColors.muted,
                          ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Skeleton Chat View
// ---------------------------------------------------------------------------
class _SkeletonChatView extends StatelessWidget {
  const _SkeletonChatView();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppLayout.space16),
      children: const [
        Align(
          alignment: Alignment.centerLeft,
          child: SkeletonBox(width: 220, height: 48, radius: 8),
        ),
        SizedBox(height: 12),
        Align(
          alignment: Alignment.centerRight,
          child: SkeletonBox(width: 180, height: 40, radius: 8),
        ),
        SizedBox(height: 12),
        Align(
          alignment: Alignment.centerLeft,
          child: SkeletonBox(width: 280, height: 56, radius: 8),
        ),
        SizedBox(height: 12),
        Align(
          alignment: Alignment.centerRight,
          child: SkeletonBox(width: 140, height: 36, radius: 8),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Error View
// ---------------------------------------------------------------------------
class _ChatErrorView extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;

  const _ChatErrorView({required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppLayout.space24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.wifi_off_outlined, size: 40, color: AppColors.declined),
            const SizedBox(height: AppLayout.space12),
            Text('Could not load chat messages', style: tt.headlineSmall),
            const SizedBox(height: AppLayout.space4),
            Text(
              error,
              style: tt.bodySmall?.copyWith(color: AppColors.muted),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppLayout.space16),
            OutlinedButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}
