import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yoyu/core/network/interceptors/error_interceptor.dart';

class ApiClient {
  final Dio _dio;

  ApiClient(this._dio);

  Future<Response> post(String path, {dynamic data}) async {
    return _dio.post(path, data: data);
  }
}

final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: 'https://www.i-pass.com.tw/APP/APPV2/',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        "User-Agent": "ktor-client",
        "Accept-Encoding": "gzip",
        "Accept": "application/json",
        "Connection": "Keep-Alive",
        "Device-OS": "Android",
        "OS-Version": "28",
        "App-Version": "1.36.0",
        "Accept-Language": "zh-TW",
        "Content-Type": "application/json",
      },
    ),
  );

  dio.interceptors.add(ErrorInterceptor(ref));
  
  // Custom interceptor to handle i-pass specific errors based on rtnCode
  dio.interceptors.add(InterceptorsWrapper(
    onResponse: (response, handler) {
      final data = response.data;
      if (data is Map<String, dynamic>) {
        if (data.containsKey('rtnCode') && data['rtnCode'] != '0' && data['rtnCode'] != '00') {
          // You could potentially trigger notification here if needed, but for specific APIs
          // it might be better handled in the repository/domain layer to avoid double notifications.
        }
      }
      return handler.next(response);
    },
  ));

  return dio;
});

final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient(ref.watch(dioProvider));
});
