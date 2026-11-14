import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../../core/utils/category_style.dart';
import '../../domain/entities/assistant_message.dart';
import '../../domain/entities/location.dart';
import '../../l10n/l10n.dart';
import '../navigation/location_navigation.dart';
import '../providers/tanya_loka_provider.dart';
import '../theme/app_colors.dart';
import '../widgets/category_icon.dart';
import '../widgets/dialogs.dart';
import '../widgets/kawung_pattern.dart';

/// Starter questions, in the app language so the AI answers in it too.
List<String> _suggestions(AppLocalizations l10n) => [
  l10n.tanyaSuggest1,
  l10n.tanyaSuggest2,
  l10n.tanyaSuggest3,
  l10n.tanyaSuggest4,
  l10n.tanyaSuggest5,
  l10n.tanyaSuggest6,
];

/// Opens Tanya Loka. With [initialQuestion] the chat starts empty and that
/// question is sent right away.
Future<void> openTanyaLoka(BuildContext context, {String? initialQuestion}) {
  if (initialQuestion != null) context.read<TanyaLokaProvider>().reset();
  return Navigator.of(context).push(
    MaterialPageRoute(
      builder: (_) => TanyaLokaScreen(initialQuestion: initialQuestion),
    ),
  );
}

/// Opens a fresh Tanya Loka chat about [location] and asks a ready-made
/// question about it.
Future<void> openTanyaLokaAbout(BuildContext context, Location location) =>
    openTanyaLoka(
      context,
      initialQuestion: context.l10n.tanyaAboutPlace(location.name),
    );

/// Chat with the AI cultural guide, which answers only from LokaNusantara
/// data and links the places it mentions.
class TanyaLokaScreen extends StatefulWidget {
  const TanyaLokaScreen({super.key, this.initialQuestion});

  final String? initialQuestion;

  @override
  State<TanyaLokaScreen> createState() => _TanyaLokaScreenState();
}

class _TanyaLokaScreenState extends State<TanyaLokaScreen> {
  final _input = TextEditingController();
  final _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    final question = widget.initialQuestion;
    if (question != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _send(question);
      });
    }
  }

  @override
  void dispose() {
    _input.dispose();
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _send([String? text]) async {
    final question = (text ?? _input.text).trim();
    if (question.isEmpty) return;
    final provider = context.read<TanyaLokaProvider>();
    _input.clear();
    _scrollToEnd();
    final ok = await provider.send(question);
    if (!mounted) return;
    if (ok) {
      _scrollToEnd();
    } else {
      // Give the question back so the user can retry or edit it.
      _input.text = question;
      final error = provider.error;
      await showMessageDialog(
        context,
        'Tanya Loka',
        error == null
            ? context.l10n.errorUnknown
            : context.l10n.errorMessage(error),
      );
      provider.clearError();
    }
  }

  void _scrollToEnd() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scroll.hasClients) return;
      _scroll.animateTo(
        _scroll.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  Future<void> _confirmReset() async {
    final l10n = context.l10n;
    final ok = await showConfirmDialog(
      context,
      title: l10n.tanyaNewChat,
      message: l10n.tanyaNewChatMessage,
      confirmLabel: l10n.tanyaNewChatConfirm,
    );
    if (ok && mounted) context.read<TanyaLokaProvider>().reset();
  }

  @override
  Widget build(BuildContext context) {
    final chat = context.watch<TanyaLokaProvider>();
    final messages = chat.messages;

    return Scaffold(
      backgroundColor: AppColors.gading,
      appBar: AppBar(
        backgroundColor: AppColors.sogan,
        foregroundColor: Colors.white,
        titleSpacing: 0,
        title: Row(
          children: [
            SvgPicture.asset('assets/brand/logo_mark.svg', height: 30),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Tanya Loka',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
                ),
                Text(
                  context.l10n.tanyaSubtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xCCFFFFFF),
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          if (messages.isNotEmpty)
            IconButton(
              tooltip: context.l10n.tanyaNewChat,
              icon: const Icon(Icons.add_comment_outlined),
              onPressed: chat.sending ? null : _confirmReset,
            ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: messages.isEmpty && !chat.sending
                ? _Welcome(onPick: _send)
                : ListView.builder(
                    controller: _scroll,
                    padding: const EdgeInsets.fromLTRB(14, 16, 14, 8),
                    itemCount: messages.length + (chat.sending ? 1 : 0),
                    itemBuilder: (context, i) => i == messages.length
                        ? const _TypingBubble()
                        : _MessageBubble(message: messages[i]),
                  ),
          ),
          _InputBar(controller: _input, sending: chat.sending, onSend: _send),
        ],
      ),
    );
  }
}

class _Welcome extends StatelessWidget {
  const _Welcome({required this.onPick});

  final ValueChanged<String> onPick;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.terakota, AppColors.sogan],
            ),
          ),
          child: Stack(
            children: [
              const Positioned.fill(
                child: KawungPattern(color: Color(0x1AF6D98A), tileSize: 44),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.l10n.tanyaGreeting,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    context.l10n.tanyaIntro,
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.5,
                      color: Colors.white.withValues(alpha: 0.88),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Text(
          context.l10n.tanyaTryAsking,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 10),
        for (final q in _suggestions(context.l10n))
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Material(
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
                side: const BorderSide(color: AppColors.border),
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: () => onPick(q),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.auto_awesome,
                        size: 18,
                        color: AppColors.prada,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          q,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      const Icon(
                        Icons.north_east,
                        size: 16,
                        color: AppColors.textMuted,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.message});

  final ChatMessage message;

  @override
  Widget build(BuildContext context) {
    final mine = message.role == ChatRole.user;
    final maxWidth = MediaQuery.sizeOf(context).width * 0.82;

    return Align(
      alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
          decoration: BoxDecoration(
            color: mine ? AppColors.terakota : Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(18),
              topRight: const Radius.circular(18),
              bottomLeft: Radius.circular(mine ? 18 : 4),
              bottomRight: Radius.circular(mine ? 4 : 18),
            ),
            border: mine ? null : Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SelectableText(
                message.text,
                style: TextStyle(
                  fontSize: 14.5,
                  height: 1.5,
                  color: mine ? Colors.white : AppColors.textPrimary,
                ),
              ),
              if (message.locations.isNotEmpty) ...[
                const SizedBox(height: 10),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    for (final place in message.locations)
                      _PlaceChip(location: place),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _PlaceChip extends StatelessWidget {
  const _PlaceChip({required this.location});

  final Location location;

  @override
  Widget build(BuildContext context) {
    final style = categoryStyleOf(location.category?.name);
    return Material(
      color: style.color.withValues(alpha: 0.1),
      shape: const StadiumBorder(),
      child: InkWell(
        customBorder: const StadiumBorder(),
        onTap: () => openLocationDetail(context, location),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CategoryIcon(style, size: 14, color: style.color),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  location.name,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: style.color,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Three dots bouncing in turn while the answer is on its way.
class _TypingBubble extends StatefulWidget {
  const _TypingBubble();

  @override
  State<_TypingBubble> createState() => _TypingBubbleState();
}

class _TypingBubbleState extends State<_TypingBubble>
    with SingleTickerProviderStateMixin {
  late final AnimationController _anim = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  )..repeat();

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.border),
        ),
        child: AnimatedBuilder(
          animation: _anim,
          builder: (context, _) => Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (var i = 0; i < 3; i++)
                Transform.translate(
                  offset: Offset(
                    0,
                    -4 *
                        math.max(
                          0,
                          math.sin((_anim.value - i * 0.18) * 2 * math.pi),
                        ),
                  ),
                  child: Container(
                    width: 8,
                    height: 8,
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    decoration: const BoxDecoration(
                      color: AppColors.prada,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              const SizedBox(width: 8),
              Text(
                context.l10n.tanyaTyping,
                style: const TextStyle(
                  fontSize: 12.5,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InputBar extends StatelessWidget {
  const _InputBar({
    required this.controller,
    required this.sending,
    required this.onSend,
  });

  final TextEditingController controller;
  final bool sending;
  final ValueChanged<String?> onSend;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        12,
        8,
        12,
        8 + MediaQuery.paddingOf(context).bottom,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Color(0x14000000), blurRadius: 8)],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  minLines: 1,
                  maxLines: 4,
                  maxLength: 500,
                  textInputAction: TextInputAction.send,
                  onSubmitted: sending ? null : (_) => onSend(null),
                  decoration: InputDecoration(
                    hintText: context.l10n.tanyaHint,
                    hintStyle: const TextStyle(color: AppColors.textMuted),
                    counterText: '',
                    filled: true,
                    fillColor: AppColors.surfaceMuted,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(22),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Material(
                color: sending ? AppColors.border : AppColors.terakota,
                shape: const CircleBorder(),
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: sending ? null : () => onSend(null),
                  child: const SizedBox.square(
                    dimension: 46,
                    child: Icon(Icons.send_rounded, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            context.l10n.tanyaDisclaimer,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }
}
