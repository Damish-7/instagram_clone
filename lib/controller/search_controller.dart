import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../model/search_model.dart';
import '../utils/api_client.dart';
import '../utils/api_constants.dart';
import '../utils/helpers.dart';

class SearchController extends GetxController {
  var searchResults  = <SearchUserModel>[].obs;
  var suggestions    = <SearchUserModel>[].obs;
  var isSearching    = false.obs;
  var isLoading      = false.obs;
  var searchQuery    = ''.obs;
  final _storage     = GetStorage();

  @override
  void onInit() {
    fetchSuggestions();
    super.onInit();
  }

  int get myId =>
      int.tryParse(_storage.read('user')?['id'].toString() ?? '0') ?? 0;

  // ─── Search users ─────────────────────────────────────────────
  Future<void> searchUsers(String query) async {
    searchQuery.value = query;
    if (query.trim().isEmpty) {
      searchResults.clear();
      isSearching(false);
      return;
    }
    try {
      isSearching(true);
      isLoading(true);
      final res = await ApiClient.instance.post(
        ApiConstants.search,
        data: {'action': 'search', 'query': query, 'user_id': myId},
      );
      if (res.data['status'] == 'success') {
        searchResults.value = (res.data['users'] as List)
            .map((u) => SearchUserModel.fromJson(u))
            .toList();
      }
    } catch (e) {
      Helpers.showError('Search failed');
    } finally {
      isLoading(false);
    }
  }

  // ─── Fetch suggestions ────────────────────────────────────────
  Future<void> fetchSuggestions() async {
    try {
      final res = await ApiClient.instance.post(
        ApiConstants.search,
        data: {'action': 'suggestions', 'user_id': myId},
      );
      if (res.data['status'] == 'success') {
        suggestions.value = (res.data['users'] as List)
            .map((u) => SearchUserModel.fromJson(u))
            .toList();
      }
    } catch (_) {}
  }

  // ─── Toggle follow from search ────────────────────────────────
  Future<void> toggleFollow(int targetId) async {
    final list = isSearching.value ? searchResults : suggestions;
    final index = list.indexWhere((u) => u.id == targetId);
    if (index == -1) return;

    final user = list[index];
    try {
      if (user.isFollowing || user.isRequested) {
        await ApiClient.instance.post(ApiConstants.follow, data: {
          'action': 'unfollow',
          'follower_id': myId,
          'following_id': targetId,
        });
        list[index] = user.copyWith(isFollowing: false, isRequested: false);
      } else {
        final res = await ApiClient.instance.post(ApiConstants.follow, data: {
          'action': 'follow',
          'follower_id': myId,
          'following_id': targetId,
        });
        if (res.data['follow_status'] == 'pending') {
          list[index] = user.copyWith(isRequested: true, isFollowing: false);
        } else {
          list[index] = user.copyWith(isFollowing: true, isRequested: false);
        }
      }
    } catch (e) {
      Helpers.showError('Action failed');
    }
  }
}