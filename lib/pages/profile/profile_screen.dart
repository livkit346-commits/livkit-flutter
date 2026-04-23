import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart'; // <-- Add this package

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();

    _tabController = TabController(length: 3, vsync: this);

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _fadeAnim = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOut,
    );

    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.05),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic),
    );

    _animController.forward();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      // No bottomNavigationBar, so it won't show
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnim,
          child: SlideTransition(
            position: _slideAnim,
            child: NestedScrollView(
              headerSliverBuilder: (context, innerBoxIsScrolled) {
                return [
                  SliverToBoxAdapter(
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // 🔙 Back button
                              IconButton(
                                icon: const Icon(Icons.arrow_back,
                                    color: Colors.white),
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                              ),

                              const Text(
                                "horminira",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),

                              // 📤 Share button
                              IconButton(
                                icon: const Icon(Icons.share,
                                    color: Colors.white),
                                onPressed: () {
                                  Share.share(
                                      'https://livkit.onrender.com/profile/horminira');
                                },
                              ),
                            ],
                          ),
                        ),

                        // X-Style Double Profile Header
                        Stack(
                          clipBehavior: Clip.none,
                          alignment: Alignment.bottomLeft,
                          children: [
                            // 🖼️ Banner Image
                            Container(
                              height: 130,
                              width: double.infinity,
                              color: Colors.grey.shade800,
                              child: const Icon(Icons.image, color: Colors.white38, size: 40),
                            ),
                            // 👤 Overlapping Avatar
                            Positioned(
                              bottom: -40,
                              left: 16,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: Colors.black,
                                  shape: BoxShape.circle,
                                ),
                                child: const CircleAvatar(
                                  radius: 46,
                                  backgroundImage:
                                      AssetImage("assets/profile.png"),
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 45), // Space for overlapped avatar

                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "iyundaaaa 😍",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                "@horminira",
                                style: TextStyle(
                                  color: Colors.white54,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 12),
                              
                              // Follow & Book Buttons
                              Row(
                                children: [
                                  Expanded(
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFFFF0050),
                                        padding: const EdgeInsets.symmetric(vertical: 12),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(24),
                                        ),
                                      ),
                                      onPressed: () {
                                        // TODO: Wire to backend follow
                                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Followed!")));
                                      },
                                      child: const Text("Follow", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.white12,
                                        padding: const EdgeInsets.symmetric(vertical: 12),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(24),
                                        ),
                                      ),
                                      onPressed: () {
                                        // TODO: Wire to backend booking
                                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Stream Booked! We'll alert you.")));
                                      },
                                      child: const Text("Book Live", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 20),

                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  _statItem("3", "Posts"),
                                  _divider(),
                                  _statItem("88", "Followers"),
                                  _divider(),
                                  _statItem("127", "Following"),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),

                  SliverPersistentHeader(
                    pinned: true,
                    delegate: _TabBarDelegate(
                      TabBar(
                        controller: _tabController,
                        indicatorColor: Colors.white,
                        indicatorWeight: 2,
                        labelColor: Colors.white,
                        unselectedLabelColor: Colors.white38,
                        tabs: const [
                          Tab(icon: Icon(Icons.grid_on)),
                          Tab(icon: Icon(Icons.video_collection_outlined)),
                          Tab(icon: Icon(Icons.person_pin_outlined)),
                        ],
                      ),
                    ),
                  ),
                ];
              },
              body: TabBarView(
                controller: _tabController,
                children: [
                  // 🟦 POSTS GRID
                  GridView.builder(
                    padding: const EdgeInsets.all(4),
                    itemCount: 12,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 4,
                      mainAxisSpacing: 4,
                    ),
                    itemBuilder: (context, index) {
                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.grey.shade800,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Icon(Icons.image,
                            color: Colors.white54),
                      );
                    },
                  ),

                  // 🎥 VIDEOS / HISTORIC LIVES TIMELINE
                  ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: 6,
                    itemBuilder: (context, index) {
                      return IntrinsicHeight(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Timeline line
                            Column(
                              children: [
                                Container(
                                  width: 12,
                                  height: 12,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFFF0050),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                Expanded(
                                  child: Container(
                                    width: 2,
                                    color: Colors.white12,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(width: 12),
                            // Card content
                            Expanded(
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 16),
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade900,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      "Oct 12, 2023 • 2:00 PM",
                                      style: TextStyle(color: Colors.white54, fontSize: 12),
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: const [
                                        Icon(Icons.live_tv, color: Colors.blueAccent),
                                        SizedBox(width: 12),
                                        Text(
                                          "Just Chatting \u0026 Gaming",
                                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    const Text(
                                      "Duration: 1h 45m • 1.2k Views",
                                      style: TextStyle(color: Colors.white70, fontSize: 13),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),

                  // 🏷️ TAGGED
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.person_pin_outlined,
                            size: 60, color: Colors.white24),
                        SizedBox(height: 10),
                        Text(
                          "No tagged posts yet",
                          style: TextStyle(color: Colors.white54),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  static Widget _statItem(String count, String label) {
    return Column(
      children: [
        Text(
          count,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white54,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  static Widget _divider() {
    return Container(
      height: 30,
      width: 1,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      color: Colors.white12,
    );
  }
}


class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar _tabBar;

  _TabBarDelegate(this._tabBar);

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Colors.black, // background for the tab bar
      child: _tabBar,
    );
  }

  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  double get minExtent => _tabBar.preferredSize.height;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return false;
  }
}
