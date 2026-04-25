import 'package:flutter/material.dart';
import '../../services/streaming_service.dart';
import 'streamer_page.dart';

class GoLivePage extends StatefulWidget {
  final String accessToken; // Auth token

  const GoLivePage({
    super.key,
    required this.accessToken,
  });

  @override
  State<GoLivePage> createState() => _GoLivePageState();
}

class _GoLivePageState extends State<GoLivePage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _isPrivate = false;

  Future<void> _startLive() async {
    if (_isLoading) return;

    setState(() => _isLoading = true);

    final streamingService = StreamingService();

    try {
      final response = await streamingService.createLiveStream(
        title: _titleController.text.trim().isEmpty
            ? "Untitled Live"
            : _titleController.text.trim(),
        isPrivate: _isPrivate,
        password: _isPrivate ? _passwordController.text.trim() : null,
      );

      final stream = response["stream"];
      final String shareLink = stream["share_link"] ?? "";

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => StreamerPage(
            streamId: stream["id"],
            channelName: response["channel_name"],
            agoraToken: response["agora_token"],
            accessToken: widget.accessToken, // ✅ THIS WAS MISSING
            title: _titleController.text.trim().isEmpty
                ? "Live Now"
                : _titleController.text.trim(),
          ),
        ),
      );

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Failed to start live stream"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // ───────── TOP BAR ─────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.close, color: Colors.white),
                  ),
                  const Spacer(),
                  const Text(
                    "Go Live",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // ───────── CAMERA PREVIEW PLACEHOLDER ─────────
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              height: MediaQuery.of(context).size.height * 0.42,
              decoration: BoxDecoration(
                color: Colors.white10,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Center(
                child: Icon(
                  Icons.videocam,
                  color: Colors.white54,
                  size: 60,
                ),
              ),
            ),

            const SizedBox(height: 20),

            // ───────── TITLE INPUT ─────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                controller: _titleController,
                style: const TextStyle(color: Colors.white),
                maxLength: 80,
                decoration: InputDecoration(
                  counterText: "",
                  hintText: "Add a title for your live",
                  hintStyle: const TextStyle(color: Colors.white54),
                  filled: true,
                  fillColor: Colors.white12,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 15),

            // ───────── OPTIONS ─────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _isPrivate = !_isPrivate;
                    });
                  },
                  child: _Option(
                    icon: _isPrivate ? Icons.lock : Icons.public,
                    label: _isPrivate ? "Private" : "Public",
                    color: _isPrivate ? Colors.redAccent : Colors.greenAccent,
                  ),
                ),
                _Option(icon: Icons.chat_bubble_outline, label: "Chat"),
                _Option(icon: Icons.card_giftcard, label: "Gifts"),
                _Option(icon: Icons.mic_none, label: "Mic"),
              ],
            ),

            if (_isPrivate) ...[
              const SizedBox(height: 15),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: TextField(
                  controller: _passwordController,
                  style: const TextStyle(color: Colors.white),
                  obscureText: true,
                  decoration: InputDecoration(
                    hintText: "Set a password for your private live",
                    hintStyle: const TextStyle(color: Colors.white54),
                    filled: true,
                    fillColor: Colors.white12,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
            ],

            const Spacer(),

            // ───────── GO LIVE BUTTON ─────────
            Padding(
              padding: const EdgeInsets.only(bottom: 30),
              child: GestureDetector(
                onTap: _isLoading ? null : _startLive,
                child: Container(
                  width: 240,
                  height: 52,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFF0050), Color(0xFFFF2E63)],
                    ),
                    borderRadius: BorderRadius.circular(26),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.pinkAccent.withOpacity(0.4),
                        blurRadius: 15,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Center(
                    child: _isLoading
                        ? const CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          )
                        : const Text(
                            "GO LIVE",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
                            ),
                          ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ───────── OPTION WIDGET ─────────
class _Option extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;

  const _Option({required this.icon, required this.label, this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          radius: 26,
          backgroundColor: Colors.white12,
          child: Icon(icon, color: color ?? Colors.white),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
      ],
    );
  }
}
