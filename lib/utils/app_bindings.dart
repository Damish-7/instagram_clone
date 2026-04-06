import 'package:get/get.dart';
import '../controller/auth_controller.dart';
import '../controller/feed_controller.dart';
import '../controller/story_controller.dart';
import '../controller/reel_controller.dart';
import '../controller/chat_controller.dart';
import '../controller/profile_controller.dart';
import '../controller/home_controller.dart';

class AuthBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AuthController>(() => AuthController());
  }
}

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HomeController>(() => HomeController());
    Get.lazyPut<FeedController>(() => FeedController());
    Get.lazyPut<StoryController>(() => StoryController());
    Get.lazyPut<ReelController>(() => ReelController());
    Get.lazyPut<ChatController>(() => ChatController());
    Get.lazyPut<ProfileController>(() => ProfileController());
    // Always register AuthController so logout works from profile
    Get.lazyPut<AuthController>(() => AuthController());
  }
}

class FeedBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<FeedController>(() => FeedController());
  }
}

class ReelBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ReelController>(() => ReelController());
  }
}

class StoryBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<StoryController>(() => StoryController());
  }
}

class ChatBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ChatController>(() => ChatController());
  }
}

class ProfileBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ProfileController>(() => ProfileController());
  }
}