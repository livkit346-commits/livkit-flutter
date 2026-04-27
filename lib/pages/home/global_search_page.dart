import 'package:flutter/material.dart';
import '../../services/streaming_service.dart';

class GlobalSearchPage extends StatefulWidget {
  const GlobalSearchPage({super.key});

  @override
  State<GlobalSearchPage> createState() => _GlobalSearchPageState();
}

class _GlobalSearchPageState extends State<GlobalSearchPage> {
  final TextEditingController _searchController = TextEditingController();
  late final StreamingService _streamingService;
  
  bool _isLoading = false;
  List<dynamic> _users = [];
  List<dynamic> _streams = [];

  @override
  void initState() {
    super.initState();
    _streamingService = StreamingService();
  }

  Future<void> _performSearch() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final results = await _streamingService.search(query: query);
      setState(() {
        _users = results['users'] ?? [];
        _streams = results['live_streams'] ?? [];
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load search results')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.grey.shade900,
        title: TextField(
          controller: _searchController,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: "Search users or live streams...",
            hintStyle: TextStyle(color: Colors.white54),
            border: InputBorder.none,
          ),
          onSubmitted: (_) => _performSearch(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: _performSearch,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.redAccent))
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (_users.isNotEmpty) ...[
                  const Text("Users", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  ..._users.map((user) => ListTile(
                    leading: const CircleAvatar(backgroundColor: Colors.grey, child: Icon(Icons.person, color: Colors.white)),
                    title: Text(user['display_name'] ?? user['username'], style: const TextStyle(color: Colors.white)),
                    subtitle: Text("@${user['username']}", style: const TextStyle(color: Colors.white54)),
                    trailing: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF0050)),
                      onPressed: () {},
                      child: const Text("Profile", style: TextStyle(color: Colors.white)),
                    ),
                  )).toList(),
                  const Divider(color: Colors.white24, height: 30),
                ],

                if (_streams.isNotEmpty) ...[
                  const Text("Live Streams", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  ..._streams.map((stream) => ListTile(
                    leading: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(color: Colors.grey.shade800, borderRadius: BorderRadius.circular(8)),
                      child: const Icon(Icons.live_tv, color: Colors.redAccent),
                    ),
                    title: Text(stream['title'] ?? 'Untitled', style: const TextStyle(color: Colors.white)),
                    subtitle: Text("By: ${stream['streamer_username']}", style: const TextStyle(color: Colors.white54)),
                    trailing: const Icon(Icons.chevron_right, color: Colors.white),
                  )).toList(),
                ],

                if (!_isLoading && _users.isEmpty && _streams.isEmpty && _searchController.text.isNotEmpty)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.only(top: 40),
                      child: Text("No results found.", style: TextStyle(color: Colors.white54)),
                    ),
                  ),
              ],
            ),
    );
  }
}
