import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/home_controller.dart';
import '../controller/auth_controller.dart';
import '../controller/profile_controller.dart';
import '../controller/notification_controller.dart';
import 'feed/feed_screen.dart';
import 'reel/reel_screen.dart';
import 'search/search_screen.dart';
import 'notification/notification_screen.dart';
import 'profile/profile_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final homeCtrl   = Get.find<HomeController>();
    final authCtrl   = Get.find<AuthController>();
    final notifCtrl  = Get.find<NotificationController>();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.find<ProfileController>().loadProfile(authCtrl.myId);
    });

    final pages = [
      const FeedScreen(),
      const SearchScreen(),
      const ReelScreen(),
      const NotificationScreen(),
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
            items: [
              const BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined),
                activeIcon: Icon(Icons.home),
                label: 'Home',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.search),
                activeIcon: Icon(Icons.search),
                label: 'Search',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.play_circle_outline),
                activeIcon: Icon(Icons.play_circle),
                label: 'Reels',
              ),
              // Notification with badge
              BottomNavigationBarItem(
                icon: Obx(() => notifCtrl.unreadCount.value > 0
                    ? Badge(
                        label: Text('${notifCtrl.unreadCount.value}'),
                        child: const Icon(Icons.favorite_border),
                      )
                    : const Icon(Icons.favorite_border)),
                activeIcon: const Icon(Icons.favorite),
                label: 'Activity',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.person_outline),
                activeIcon: Icon(Icons.person),
                label: 'Profile',
              ),
            ],
          ),
        ));
  }
}