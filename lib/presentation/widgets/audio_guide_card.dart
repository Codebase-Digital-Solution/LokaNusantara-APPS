import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/l10n.dart';
import '../providers/audio_guide.dart';
import '../theme/app_colors.dart';

String _speedLabel(AppLocalizations l10n, NarrationSpeed speed) =>
    switch (speed) {
      NarrationSpeed.slow => l10n.audioSpeedSlow,
      NarrationSpeed.normal => l10n.audioSpeedNormal,
      NarrationSpeed.fast => l10n.audioSpeedFast,
    };

/// Player for the location narration: play/pause, stop, progress, speed.
class AudioGuideCard extends StatelessWidget {
  const AudioGuideCard({super.key, required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    final guide = context.watch<AudioGuide>();
    final playing = guide.state == AudioGuideState.playing;
    final active = guide.state != AudioGuideState.idle;

    return Container(
      margin: const EdgeInsets.only(top: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Material(
                color: color,
                shape: const CircleBorder(),
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: guide.toggle,
                  child: SizedBox.square(
                    dimension: 52,
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      child: Icon(
                        playing
                            ? Icons.pause_rounded
                            : Icons.play_arrow_rounded,
                        key: ValueKey(playing),
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.l10n.audioTitle,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      active
                          ? context.l10n.audioPart(guide.index + 1, guide.total)
                          : context.l10n.audioListen,
                      style: const TextStyle(
                        fontSize: 12.5,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              if (active)
                IconButton(
                  tooltip: context.l10n.audioStop,
                  icon: const Icon(Icons.stop_rounded),
                  color: AppColors.textSecondary,
                  onPressed: guide.stop,
                ),
            ],
          ),
          if (active) ...[
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: guide.progress,
                minHeight: 5,
                color: color,
                backgroundColor: color.withValues(alpha: 0.15),
              ),
            ),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              Text(
                context.l10n.audioSpeed,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textMuted,
                ),
              ),
              const SizedBox(width: 8),
              for (final speed in NarrationSpeed.values)
                Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: ChoiceChip(
                    label: Text(_speedLabel(context.l10n, speed)),
                    selected: guide.speed == speed,
                    onSelected: (_) => guide.setSpeed(speed),
                    visualDensity: VisualDensity.compact,
                    labelStyle: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: guide.speed == speed
                          ? Colors.white
                          : AppColors.textSecondary,
                    ),
                    selectedColor: color,
                    backgroundColor: AppColors.surfaceMuted,
                    showCheckmark: false,
                    side: BorderSide.none,
                  ),
                ),
            ],
          ),
          if (guide.voiceAvailable == false)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                context.l10n.audioNoVoice,
                style: const TextStyle(
                  fontSize: 11.5,
                  color: AppColors.textMuted,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
