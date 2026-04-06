import 'package:get/get.dart';
import '../screen/auth/login_screen.dart';
import '../screen/auth/register_screen.dart';
import '../screen/home_screen.dart';
import '../screen/reel/reel_screen.dart';
import '../screen/chat/chat_list_screen.dart';
import '../screen/chat/chat_room_screen.dart';
import '../screen/profile/profile_screen.dart';
import 'app_bindings.dart';

class AppRoutes {
  static const String login    = '/login';
  static const String register = '/register';
  static const String home     = '/home';
  static const String reel     = '/reel';
  static const String story    = '/story';
  static const String chatList = '/chat-list';
  static const String chatRoom = '/chat-room';
  static const String profile  = '/profile';

  static final List<GetPage> pages = [
    GetPage(
      name: login,
      page: () => const LoginScreen(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: register,
      page: () => const RegisterScreen(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: home,
      page: () => const HomeScreen(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: reel,
      page: () => const ReelScreen(),
      binding: ReelBinding(),
    ),
    // story uses Get.to() directly with group param — no route entry needed
    GetPage(
      name: chatList,
      page: () => const ChatListScreen(),
      binding: ChatBinding(),
    ),
    GetPage(
      name: chatRoom,
      page: () {
        final args = Get.arguments as Map<String, dynamic>? ?? {};
        return ChatRoomScreen(
          userId: args['userId'] ?? 0,
          username: args['username'] ?? '',
          profilePic: args['profilePic'],
        );
      },
      binding: ChatBinding(),
    ),
    GetPage(
      name: profile,
      page: () {
        final args = Get.arguments as Map<String, dynamic>? ?? {};
        return ProfileScreen(userId: args['userId'] ?? 0);
      },
      binding: ProfileBinding(),
    ),
  ];
}