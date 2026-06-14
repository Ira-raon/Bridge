import 'package:flutter/material.dart';
import '../screens/discussion_tracker_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/platform_screen.dart';

bottomNavigationBar: BottomNavigationBar(
  currentIndex: 0,
  onTap: (index) {
    switch (index) {
      case 0:
        break;

      case 1:
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => const DiscussionTrackerScreen(),
          ),
        );
        break;

      case 2:
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => const ProfileScreen(),
          ),
        );
        break;
    }
  },
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
),