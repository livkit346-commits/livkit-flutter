import 'package:flutter/material.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import '../../widgets/live_action.dart';
import '../../widgets/tiktok_comments.dart';
import '../../services/streaming_service.dart';
import 'package:share_plus/share_plus.dart';

import '../../config/agora_config.dart';

class StreamerPage extends StatefulWidget {
  final String streamId;
  final String channelName;
  final String agoraToken;
  final String title;
  final String shareLink;

  const StreamerPage({
    super.key,
    required this.streamId,
    required this.channelName,
    required this.agoraToken,
    this.title = "Live Now",
    this.shareLink = "",
  });

  @override
  State<StreamerPage> createState() => _StreamerPageState();
}

class _StreamerPageState extends State<StreamerPage>
    with SingleTickerProviderStateMixin {
  late final RtcEngine _engine;

  bool _isLive = false;
  bool _engineReady = false;
  bool _isEnding = false;

  final TextEditingController _commentController = TextEditingController();
  final TikTokCommentsController commentsController =
      TikTokCommentsController();

  late final AnimationController _animController;
  late final Animation<double> _fadeScale;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _initLive();
  }

  // ───────── ANIMATIONS ─────────
  void _setupAnimations() {
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );

    _fadeScale =
        CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic);

    _animController.forward();
  }

  // ───────── PERMISSIONS + START ─────────
  Future<void> _initLive() async {

    if (kIsWeb) {
      print("Permissions handled by browser"); 
      await _initAgora();
      return;
    }

    await _requestPermissions();

    final camStatus = await Permission.camera.status;
    final micStatus = await Permission.microphone.status;

    print("Camera permission: $camStatus"); // debug
    print("Mic permission: $micStatus"); // debug

    if (camStatus.isGranted && micStatus.isGranted) {
      await _initAgora();
    } else {
      print("Permissions not granted"); // debug

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Camera and microphone permissions are required"),
          ),
        );
        Navigator.pop(context);
      }
    }
  }

  Future<void> _requestPermissions() async {
    final statuses = await [
      Permission.camera,
      Permission.microphone,
    ].request();

    print("Permission statuses: $statuses"); // debug
  }

  // ───────── AGORA INIT ─────────
  Future<void> _initAgora() async {
    _engine = createAgoraRtcEngine();

    await _engine.initialize(
      const RtcEngineContext(
        appId: AgoraConfig.appId,
        channelProfile: ChannelProfileType.channelProfileLiveBroadcasting,
      ),
    );

    await _engine.enableVideo();
    await _engine.startPreview();

    await _engine.setClientRole(
      role: ClientRoleType.clientRoleBroadcaster,
    );

    await _engine.joinChannel(
      token: widget.agoraToken,
      channelId: widget.channelName,
      uid: 0,
      options: const ChannelMediaOptions(),
    );

    print("Agora joined channel successfully"); // debug

    if (mounted) {
      setState(() {
        _isLive = true;
        _engineReady = true;
      });
    }
  }

  // ───────── END LIVE ─────────
  Future<void> _endLive() async {
    if (_isEnding) return;
    _isEnding = true;

    final streamingService = StreamingService();

    try {
      await streamingService.endLiveStream(streamId: widget.streamId);

      if (_engineReady) {
        try {
          await _engine.leaveChannel();
          await _engine.release();
        } catch (e) {
          print("Agora leave/release error: $e"); // debug
        }
      } else {
        print("Agora engine not initialized, skipping release"); // debug
      }


      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Live stream ended")),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      print("End live error: $e"); // debug

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to end stream: $e")),
        );
      }
    } finally {
      _isEnding = false;
    }
  }

  // ───────── COMMENTS ─────────
  void _sendComment() {
    final text = _commentController.text.trim();
    if (text.isEmpty) return;

    commentsController.addComment(text);
    _commentController.clear();
  }

  @override
  void dispose() {
    _commentController.dispose();
    _animController.dispose();
    super.dispose();
  }

  // ───────── UI ─────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: FadeTransition(
        opacity: _fadeScale,
        child: ScaleTransition(
          scale: Tween(begin: 0.97, end: 1.0).animate(_fadeScale),
          child: Stack(
            children: [
              // 🎥 LIVE VIDEO
              _engineReady
                  ? AgoraVideoView(
                      controller: VideoViewController(
                        rtcEngine: _engine,
                        canvas: const VideoCanvas(uid: 0),
                      ),
                    )
                  : const Center(
                      child: CircularProgressIndicator(
                        color: Colors.white,
                      ),
                    ),

              // 🔝 TOP INFO
              Positioned(
                top: MediaQuery.of(context).padding.top + 12,
                left: 15,
                right: 15,
                child: Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Text(
                          "LIVE",
                          style: TextStyle(
                            color: Colors.redAccent,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: _endLive,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.redAccent,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          "END",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // 🎯 RIGHT ACTIONS
              Positioned(
                right: 10,
                bottom: 160,
                child: Column(
                  children: [
                    const LiveAction(icon: Icons.attach_money, label: "Sub"),
                    const SizedBox(height: 12),
                    const LiveAction(icon: Icons.person_add, label: "Follow"),
                    const SizedBox(height: 12),
                    LiveAction(
                      icon: Icons.share, 
                      label: "Share",
                      onTap: () {
                        if (widget.shareLink.isNotEmpty) {
                          Share.share(widget.shareLink);
                        } else {
                          Share.share('https://livkit.onrender.com/live/${widget.streamId}');
                        }
                      },
                    ),
                  ],
                ),
              ),

              // 💬 COMMENTS
              TikTokComments(controller: commentsController),

              // ✍️ COMMENT INPUT
              Positioned(
                bottom: 40,
                left: 10,
                right: 10,
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _commentController,
                        style: const TextStyle(color: Colors.white),
                        onSubmitted: (_) => _sendComment(),
                        decoration: InputDecoration(
                          hintText: "Add a comment...",
                          hintStyle:
                              const TextStyle(color: Colors.white54),
                          filled: true,
                          fillColor: Colors.white12,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 12,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(25),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.send, color: Colors.white),
                      onPressed: _sendComment,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
