import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yoyu/core/notifications/controllers/notification_controller.dart';

class ErrorInterceptor extends Interceptor {
  final Ref ref;

  ErrorInterceptor(this.ref);

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    String errorMessage = '發生未知的網路錯誤';

    if (err.type == DioExceptionType.connectionTimeout || 
        err.type == DioExceptionType.receiveTimeout ||
        err.type == DioExceptionType.sendTimeout) {
      errorMessage = '連線逾時，請檢查網路狀態';
    } else if (err.type == DioExceptionType.badResponse) {
      errorMessage = '伺服器回應錯誤 (狀態碼: ${err.response?.statusCode})';
    } else if (err.type == DioExceptionType.connectionError) {
      errorMessage = '無法連線至伺服器';
    }

    ref.read(notificationProvider.notifier).showError(errorMessage);
    super.onError(err, handler);
  }
}
