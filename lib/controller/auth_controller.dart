import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../model/user_model.dart';
import '../utils/api_client.dart';
import '../utils/api_constants.dart';
import '../utils/app_routes.dart';
import '../utils/helpers.dart';

class AuthController extends GetxController {
  final _storage = GetStorage();
  var isLoading = false.obs;
  var currentUser = Rxn<UserModel>();

  @override
  void onInit() {
    _loadUser();
    super.onInit();
  }

  void _loadUser() {
    final userData = _storage.read('user');
    if (userData != null) {
      currentUser.value = UserModel.fromJson(Map<String, dynamic>.from(userData));
    }
  }

  int get myId => currentUser.value?.id ?? 0;
  String get myUsername => currentUser.value?.username ?? '';

  // ─── Login ──────────────────────────────────────────────────────
  Future<void> login(String email, String password) async {
    if (email.isEmpty || password.isEmpty) {
      Helpers.showError('Please fill all fields');
      return;
    }
    if (!Helpers.isValidEmail(email)) {
      Helpers.showError('Invalid email address');
      return;
    }
    try {
      isLoading(true);
      final res = await ApiClient.instance.post(
        ApiConstants.auth,
        data: {'action': 'login', 'email': email, 'password': password},
      );
      if (res.data['status'] == 'success') {
        _storage.write('token', res.data['token']);
        _storage.write('user', res.data['user']);
        currentUser.value = UserModel.fromJson(
          Map<String, dynamic>.from(res.data['user']),
        );
        Get.offAllNamed(AppRoutes.home);
      } else {
        Helpers.showError(res.data['message'] ?? 'Login failed');
      }
    } catch (e) {
      Helpers.showError('Login failed. Check your connection.');
    } finally {
      isLoading(false);
    }
  }

  // ─── Register ───────────────────────────────────────────────────
  Future<void> register(String username, String email, String password) async {
    if (username.isEmpty || email.isEmpty || password.isEmpty) {
      Helpers.showError('Please fill all fields');
      return;
    }
    if (!Helpers.isValidEmail(email)) {
      Helpers.showError('Invalid email address');
      return;
    }
    if (!Helpers.isValidPassword(password)) {
      Helpers.showError('Password must be at least 6 characters');
      return;
    }
    try {
      isLoading(true);
      final res = await ApiClient.instance.post(
        ApiConstants.auth,
        data: {
          'action': 'register',
          'username': username,
          'email': email,
          'password': password,
        },
      );
      if (res.data['status'] == 'success') {
        Helpers.showSuccess('Account created! Please login.');
        Get.offAllNamed(AppRoutes.login);
      } else {
        Helpers.showError(res.data['message'] ?? 'Registration failed');
      }
    } catch (e) {
      Helpers.showError('Registration failed. Check your connection.');
    } finally {
      isLoading(false);
    }
  }

  // ─── Logout ─────────────────────────────────────────────────────
  void logout() {
    _storage.erase();
    currentUser.value = null;
    Get.offAllNamed(AppRoutes.login);
  }
}