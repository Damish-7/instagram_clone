import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/home_controller.dart';
import '../controller/auth_controller.dart';
import '../controller/profile_controller.dart';
import 'feed/feed_screen.dart';
import 'reel/reel_screen.dart';
import 'profile/profile_screen.dart';
import 'chat/chat_list_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final homeCtrl = Get.find<HomeController>();
    final authCtrl = Get.find<AuthController>();

    // Load my profile once home opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.find<ProfileController>().loadProfile(authCtrl.myId);
    });

    final pages = [
      const FeedScreen(),
      const ReelScreen(),
      const ChatListScreen(),
      ProfileScreen(userId: authCtrl.myId),
    ];

    return Obx(() => Scaffold(
          body: IndexedStack(
            index: homeCtrl.currentIndex.value,
            children: pages,
          ),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: homeCtrl.currentIndex.value,
            onTap: homeCtrl.changePage,
            type: BottomNavigationBarType.fixed,
            selectedItemColor: Colors.black,
            unselectedItemColor: Colors.grey,
            showSelectedLabels: false,
            showUnselectedLabels: false,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined),
                activeIcon: Icon(Icons.home),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.play_circle_outline),
                activeIcon: Icon(Icons.play_circle),
                label: 'Reels',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.chat_bubble_outline),
                activeIcon: Icon(Icons.chat_bubble),
                label: 'Chat',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person_outline),
                activeIcon: Icon(Icons.person),
                label: 'Profile',
              ),
            ],
          ),
        ));
  }
}