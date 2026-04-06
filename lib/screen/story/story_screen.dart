import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:story_view/story_view.dart';
import '../../controller/story_controller.dart' as myCtrl;
import '../../model/story_model.dart';
import '../../utils/helpers.dart';

class StoryScreen extends StatefulWidget {
  final UserStoryGroup group;
  const StoryScreen({super.key, required this.group});

  @override
  State<StoryScreen> createState() => _StoryScreenState();
}

class _StoryScreenState extends State<StoryScreen> {
  final myCtrl.StoryController storyCtrl = Get.find<myCtrl.StoryController>();
  final StoryController controller = StoryController();
  late List<StoryItem> storyItems;

  @override
  void initState() {
    super.initState();
    storyItems = widget.group.stories.map((story) {
      storyCtrl.markSeen(story.id);
      return StoryItem.pageImage(
        url: Helpers.imageUrl(story.mediaUrl),
        controller: controller,
        caption: Text(
          story.username,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: StoryView(
        storyItems: storyItems,
        controller: controller,
        repeat: false,
        onVerticalSwipeComplete: (direction) {
          if (direction == Direction.down) Get.back();
        },
        onComplete: Get.back,
      ),
    );
  }
}