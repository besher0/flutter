import 'package:coursaty_student_and_teacher/app/widgets/desktop_video_player.dart';
import 'package:coursaty_student_and_teacher/core/platform/app_platform.dart';
import 'package:coursaty_student_and_teacher/app/widgets/loading_indicator/coursaty_app_loader.dart';
import 'package:flutter/material.dart';
import 'package:better_player_plus/better_player_plus.dart';
import 'package:flutter/services.dart';

import 'playback_wakelock.dart';

class PreviewFileVideo extends StatefulWidget {
  const PreviewFileVideo({
    super.key,
    required this.filePath,
    required this.videoDuration,
  });

  final String filePath;
  final TextEditingController videoDuration;

  @override
  State<PreviewFileVideo> createState() => _MyVideoWidgetBetterPlayerState();
}

class _MyVideoWidgetBetterPlayerState extends State<PreviewFileVideo> {
  late final BetterPlayerDataSource betterPlayerDataSource;
  late final BetterPlayerController betterPlayerController;
  PlaybackWakelock? _wakelock;
  bool initialized = false;

  Future<void> init() async {
    // Desktop: better_player has no Windows version (MissingPluginException).
    if (initialized || AppPlatform.isDesktop) return;
    betterPlayerDataSource = BetterPlayerDataSource(
      BetterPlayerDataSourceType.file,
      widget.filePath,
    );

    betterPlayerController = BetterPlayerController(
      BetterPlayerConfiguration(
        deviceOrientationsAfterFullScreen: [DeviceOrientation.portraitUp],
        deviceOrientationsOnFullScreen: [
          DeviceOrientation.landscapeLeft,
          DeviceOrientation.landscapeRight,
        ],
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
    betterPlayerController.addEventsListener((event) {
      if (event.betterPlayerEventType == BetterPlayerEventType.initialized) {
        widget.videoDuration.text =
            (betterPlayerController
                        .videoPlayerController
                        ?.value
                        .duration
                        ?.inSeconds ??
                    0)
                .toString();
      }
    });
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
      return SimpleDesktopVideo(
        source: widget.filePath,
        onDuration: (duration) =>
            widget.videoDuration.text = duration.inSeconds.toString(),
      );
    }
    return initialized
        ? AspectRatio(
            aspectRatio: betterPlayerController.getAspectRatio() ?? 16 / 9,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: BetterPlayer(controller: betterPlayerController),
            ),
          )
        : Center(child: CoursatyAppLoader());
  }
}
