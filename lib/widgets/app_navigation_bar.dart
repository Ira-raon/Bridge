import 'package:flutter/material.dart';

import '../screens/discussion_tracker_screen.dart';
import '../screens/platform_screen.dart';
import '../screens/profile_screen.dart';

class AppNavigationBar extends StatelessWidget {
  const AppNavigationBar({super.key, required this.currentIndex});

  final int currentIndex;

  void _navigate(BuildContext context, int index) {
    if (index == currentIndex) {
      return;
    }

    final Widget destination = switch (index) {
      0 => const PlatformScreen(),
      1 => const DiscussionTrackerScreen(),
      2 => const ProfileScreen(),
      _ => const PlatformScreen(),
    };

    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(builder: (_) => destination),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: (index) => _navigate(context, index),
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_rounded),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.chat_rounded),
          label: 'Discussions',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_rounded),
          label: 'Profile',
        ),
      ],
    );
  }
}
