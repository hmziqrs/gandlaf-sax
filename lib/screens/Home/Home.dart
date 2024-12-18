import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gandalf/providers/video.dart';
import 'package:gandalf/screens/Home/events.dart';
import 'package:gandalf/screens/Home/widgets/sheet.dart';
import 'package:gandalf/services/analytics.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:video_player/video_player.dart';

class HomeScreen extends ConsumerStatefulWidget {
  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
    Analytics.logEvent(ViewHomeScreenEvent());
    // Initialize video on widget creation
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await ref.read(videoControllerProvider.notifier).initialize();
      if (kIsWeb) {
        onTap();
      }
    });

    super.initState();
  }

  void onTap() async {
    final videoProvider = ref.read(videoControllerProvider.notifier);
    final videoState = ref.read(videoControllerProvider);
    if (videoState.isPlaying) {
      await videoProvider.pause();
    }

    // Track sheet opening
    Analytics.logEvent(OpenSheetEvent());

    await showMaterialModalBottomSheet(
      backgroundColor: Colors.transparent,
      context: context,
      useRootNavigator: true,
      builder: (context) {
        return Sheet();
      },
    );
    await videoProvider.syncVideo();
    if (kIsWeb && videoState.isFirstSync) {
      videoProvider.triggerFirstSync();
    }
  }

  @override
  Widget build(BuildContext context) {
    final videoState = ref.watch(videoControllerProvider);

    return PopScope(
      onPopInvokedWithResult: (flag, data) {
        ref.read(videoControllerProvider.notifier).pause();
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: Container(
          color: Colors.black,
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (videoState.isInitialized)
                Positioned.fill(
                  child: VideoPlayer(
                    videoState.controller!,
                  ),
                ),
              Positioned.fill(
                child: GestureDetector(
                  onTap: onTap,
                  child: Container(
                    color: Colors.transparent,
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
