import 'package:dio/dio.dart';
import 'package:get/get.dart' hide Response, FormData;
import 'package:get_storage/get_storage.dart';
import 'api_constants.dart';

class ApiClient {
  static final Dio _dio = Dio(
    BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: {'Content-Type': 'application/json'},
    ),
  );

  static Dio get instance {
    _dio.interceptors.clear();
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          final token = GetStorage().read<String>('token');
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onResponse: (response, handler) {
          return handler.next(response);
        },
        onError: (DioException error, handler) {
          if (error.response?.statusCode == 401) {
            GetStorage().erase();
            Get.offAllNamed('/login');
          }
          String message = 'Something went wrong';
          if (error.response?.data != null) {
            message = error.response?.data['message'] ?? message;
          }
          Get.snackbar('Error', message,
              snackPosition: SnackPosition.BOTTOM);
          return handler.next(error);
        },
      ),
    );
    return _dio;
  }

  // ─── Multipart (for image/video upload) ─────────────────────────
  static Future<Response> uploadFile({
    required String endpoint,
    required FormData formData,
  }) async {
    return await instance.post(
      endpoint,
      data: formData,
      options: Options(contentType: 'multipart/form-data'),
    );
  }
}


