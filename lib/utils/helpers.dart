import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'api_constants.dart';

class Helpers {
  // ─── Format numbers (1200 → 1.2K) ──────────────────────────────
  static String formatCount(int count) {
    if (count >= 1000000) return '${(count / 1000000).toStringAsFixed(1)}M';
    if (count >= 1000) return '${(count / 1000).toStringAsFixed(1)}K';
    return count.toString();
  }

  // ─── Time ago ───────────────────────────────────────────────────
  static String timeAgo(String dateStr) {
    final date = DateTime.tryParse(dateStr);
    if (date == null) return '';
    return timeago.format(date);
  }

  // ─── Format date ────────────────────────────────────────────────
  static String formatDate(String dateStr) {
    final date = DateTime.tryParse(dateStr);
    if (date == null) return '';
    return DateFormat('MMMM d, yyyy').format(date);
  }

  // ─── Full image URL ─────────────────────────────────────────────
  static String imageUrl(String? path) {
    if (path == null || path.trim().isEmpty) return '';
    if (path.startsWith('http')) return path;
    final cleanPath = path.startsWith('/') ? path.substring(1) : path;
    return '${ApiConstants.uploadUrl}$cleanPath';
  }

  // ─── Snackbar shortcuts ─────────────────────────────────────────
  static void showSuccess(String msg) => Get.snackbar(
        'Success', msg,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );

  static void showError(String msg) => Get.snackbar(
        'Error', msg,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
      );

  // ─── Loading dialog ─────────────────────────────────────────────
  static void showLoading() => Get.dialog(
        const Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );

  static void hideLoading() {
    if (Get.isDialogOpen ?? false) Get.back();
  }

  // ─── Validate email ─────────────────────────────────────────────
  static bool isValidEmail(String email) =>
      RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);

  // ─── Validate password ──────────────────────────────────────────
  static bool isValidPassword(String password) => password.length >= 6;
}