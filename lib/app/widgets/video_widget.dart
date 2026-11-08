import 'package:coursaty_student_and_teacher/app/widgets/desktop_video_player.dart';
import 'package:coursaty_student_and_teacher/core/platform/app_platform.dart';
import 'package:coursaty_student_and_teacher/app/widgets/loading_indicator/coursaty_app_loader.dart';
import 'package:flutter/material.dart';
import 'package:better_player_plus/better_player_plus.dart';

import 'playback_wakelock.dart';

class VideoWidget extends StatefulWidget {
  const VideoWidget({super.key, required this.videoUrl});

  final String videoUrl;

  @override
  State<VideoWidget> createState() => _MyVideoWidgetBetterPlayerState();
}

class _MyVideoWidgetBetterPlayerState extends State<VideoWidget> {
  late final BetterPlayerDataSource betterPlayerDataSource;
  late final BetterPlayerController betterPlayerController;
  PlaybackWakelock? _wakelock;
  bool initialized = false;

  Future<void> init() async {
    // Desktop: better_player has no Windows version (MissingPluginException).
    if (initialized || AppPlatform.isDesktop) return;
    betterPlayerDataSource = BetterPlayerDataSource(
      BetterPlayerDataSourceType.network,
      widget.videoUrl,
    );

    betterPlayerController = BetterPlayerController(
      BetterPlayerConfiguration(
        controlsConfiguration: BetterPlayerControlsConfiguration(
          progressBarPlayedColor: Theme.of(context).colorScheme.primary,
        ),
        fit: BoxFit.cover,
        autoPlay: false,
        looping: false,
      ),
      betterPlayerDataSource: betterPlayerDataSource,
    );
    _wakelock = PlaybackWakelock(betterPlayerController);

    setState(() {
      initialized = true;
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    init();
  }

  @override
  void dispose() {
    _wakelock?.dispose();
    if (initialized) betterPlayerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (AppPlatform.isDesktop) {
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: SimpleDesktopVideo(source: widget.videoUrl),
      );
    }
    return initialized
        ? Padding(
            padding: const EdgeInsets.all(8.0),
            child: AspectRatio(
              aspectRatio: betterPlayerController.getAspectRatio() ?? 16 / 9,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: BetterPlayer(controller: betterPlayerController),
              ),
            ),
          )
        : Center(child: CoursatyAppLoader());
  }
}
