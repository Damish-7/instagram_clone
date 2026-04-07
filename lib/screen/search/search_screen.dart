import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../controller/search_controller.dart' as sc;
import '../../model/search_model.dart';
import '../../utils/app_theme.dart';
import '../../utils/helpers.dart';
import '../profile/profile_screen.dart';
import '../../utils/app_bindings.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<sc.SearchController>();

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          autofocus: false,
          decoration: InputDecoration(
            hintText: 'Search users...',
            prefixIcon: const Icon(Icons.search, size: 20),
            filled: true,
            fillColor: Colors.grey[100],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          ),
          onChanged: ctrl.searchUsers,
        ),
      ),
      body: Obx(() {
        // Show search results
        if (ctrl.isSearching.value) {
          if (ctrl.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }
          if (ctrl.searchResults.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.search_off, size: 64, color: Colors.grey),
                  SizedBox(height: 8),
                  Text('No users found',
                      style: TextStyle(color: Colors.grey)),
                ],
              ),
            );
          }
          return ListView.builder(
            itemCount: ctrl.searchResults.length,
            itemBuilder: (_, i) =>
                _UserTile(user: ctrl.searchResults[i], ctrl: ctrl),
          );
        }

        // Show suggestions
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text('Suggested for you',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16)),
            ),
            Expanded(
              child: ctrl.suggestions.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      itemCount: ctrl.suggestions.length,
                      itemBuilder: (_, i) =>
                          _UserTile(user: ctrl.suggestions[i], ctrl: ctrl),
                    ),
            ),
          ],
        );
      }),
    );
  }
}

class _UserTile extends StatelessWidget {
  final SearchUserModel user;
  final sc.SearchController ctrl;
  const _UserTile({required this.user, required this.ctrl});

  @override
  Widget build(BuildContext context) {
    final picUrl = Helpers.imageUrl(user.profilePic);

    return ListTile(
      onTap: () {
        Get.to(
          () => ProfileScreen(userId: user.id),
          binding: ProfileBinding(),
        );
      },
      leading: CircleAvatar(
        radius: 24,
        backgroundColor: Colors.grey[200],
        backgroundImage:
            picUrl.isNotEmpty ? CachedNetworkImageProvider(picUrl) : null,
        child: picUrl.isEmpty
            ? const Icon(Icons.person, color: Colors.grey)
            : null,
      ),
      title: Row(
        children: [
          Text(user.username,
              style: const TextStyle(fontWeight: FontWeight.bold)),
          if (user.isPrivate) ...[
            const SizedBox(width: 4),
            const Icon(Icons.lock, size: 14, color: Colors.grey),
          ],
        ],
      ),
      subtitle: user.bio != null && user.bio!.isNotEmpty
          ? Text(user.bio!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.grey))
          : null,
      trailing: _FollowButton(user: user, ctrl: ctrl),
    );
  }
}

class _FollowButton extends StatelessWidget {
  final SearchUserModel user;
  final sc.SearchController ctrl;
  const _FollowButton({required this.user, required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final current = ctrl.isSearching.value
          ? ctrl.searchResults.firstWhereOrNull((u) => u.id == user.id)
          : ctrl.suggestions.firstWhereOrNull((u) => u.id == user.id);
      final u = current ?? user;

      String label;
      Color bgColor;
      Color textColor;

      if (u.isFollowing) {
        label = 'Following';
        bgColor = Colors.grey[200]!;
        textColor = Colors.black;
      } else if (u.isRequested) {
        label = 'Requested';
        bgColor = Colors.grey[200]!;
        textColor = Colors.black;
      } else {
        label = 'Follow';
        bgColor = AppTheme.primary;
        textColor = Colors.white;
      }

      return ElevatedButton(
        onPressed: () => ctrl.toggleFollow(user.id),
        style: ElevatedButton.styleFrom(
          backgroundColor: bgColor,
          foregroundColor: textColor,
          minimumSize: const Size(90, 34),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8)),
        ),
        child: Text(label, style: const TextStyle(fontSize: 13)),
      );
    });
  }
}