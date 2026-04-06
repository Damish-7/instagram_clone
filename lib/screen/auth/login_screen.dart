import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controller/auth_controller.dart';
import '../../utils/app_routes.dart';
import '../../utils/app_theme.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AuthController>();
    final emailCtrl = TextEditingController();
    final passCtrl = TextEditingController();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            children: [
              const SizedBox(height: 60),

              // Logo
              const Text(
                'Instagram',
                style: TextStyle(
                  fontSize: 42,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Billabong',
                  letterSpacing: 1,
                ),
              ),

              const SizedBox(height: 40),

              // Email field
              TextField(
                controller: emailCtrl,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(hintText: 'Email'),
              ),

              const SizedBox(height: 12),

              // Password field
              TextField(
                controller: passCtrl,
                obscureText: true,
                decoration: const InputDecoration(hintText: 'Password'),
              ),

              const SizedBox(height: 20),

              // Login button
              Obx(() => ElevatedButton(
                    onPressed: controller.isLoading.value
                        ? null
                        : () => controller.login(
                              emailCtrl.text.trim(),
                              passCtrl.text.trim(),
                            ),
                    child: controller.isLoading.value
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text('Log In'),
                  )),

              const SizedBox(height: 16),

              // Divider
              Row(children: [
                const Expanded(child: Divider()),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text('OR',
                      style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                ),
                const Expanded(child: Divider()),
              ]),

              const SizedBox(height: 24),

              // Instagram gradient icon
              ShaderMask(
                shaderCallback: (bounds) =>
                    AppTheme.storyGradient.createShader(bounds),
                child: const Icon(Icons.camera_alt,
                    size: 40, color: Colors.white),
              ),

              const SizedBox(height: 8),

              const Text(
                'Log in with Instagram',
                style: TextStyle(
                    color: AppTheme.primary, fontWeight: FontWeight.w600),
              ),

              const SizedBox(height: 40),

              // Register link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Don't have an account? ",
                      style: TextStyle(color: Colors.grey[600])),
                  GestureDetector(
                    onTap: () => Get.toNamed(AppRoutes.register),
                    child: const Text(
                      'Sign up',
                      style: TextStyle(
                        color: AppTheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}