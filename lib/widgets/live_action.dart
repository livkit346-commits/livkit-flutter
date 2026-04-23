import 'package:flutter/material.dart';

class LiveAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  const LiveAction({
    super.key, 
    required this.icon, 
    required this.label,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: Colors.black45,
            child: Icon(icon, color: Colors.white),
          ),
          const SizedBox(height: 3),
          Text(label,
              style: const TextStyle(color: Colors.white70, fontSize: 11)),
        ],
      ),
    );
  }
}
