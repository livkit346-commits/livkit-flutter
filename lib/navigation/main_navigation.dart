import 'package:flutter/material.dart';
import '../pages/home/home_page.dart';
import '../pages/live/go_live_page.dart';
import '../pages/chat/chat_page.dart';
import '../pages/profile/self_profile_screen.dart';
import 'bottom_nav.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;

  void _onTabTap(int index) {
    if (index == 2) {
      // 🎥 GO LIVE
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const GoLivePage()),
      );
      return;
    }
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      const HomePage(),
      const Center(child: Text("Live Feed", style: TextStyle(color: Colors.white))),
      const SizedBox(), // Placeholder for Go Live
      const ChatPageList(),
      const SelfProfileScreen(),
    ];

    return Scaffold(
      backgroundColor: Colors.black,
      body: IndexedStack(
        index: _selectedIndex,
        children: pages,
      ),
      bottomNavigationBar: BottomNav(
        onTap: _onTabTap,
        selected: _selectedIndex,
      ),
    );
  }
}
