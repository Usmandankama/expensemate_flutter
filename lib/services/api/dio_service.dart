// lib/services/api_service.dart
import 'package:dio/dio.dart';

abstract class IApiService {
  Future<Response> post(String path, {dynamic data});
  Future<Response> get(String path);
}

class DioApiService implements IApiService {
  late final Dio _dio;

  DioApiService() {
    _dio = Dio(
      BaseOptions(
        baseUrl: 'http://10.28.239.253:3000/api/',
        // baseUrl: 'http:/10.0.0.2:3000/api/',
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Production Tip: Add an Interceptor for logging in debug mode
    _dio.interceptors.add(LogInterceptor(
      requestBody: true, 
      responseBody: true,
    ));
  }

  @override
  Future<Response> post(String path, {dynamic data}) async {
    try {
      return await _dio.post(path, data: data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<Response> get(String path) async {
    try {
      return await _dio.get(path);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  String _handleError(DioException e) {
    // Custom error handling for production
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
        return "Connection timed out. Check your internet.";
      case DioExceptionType.badResponse:
        return "Server Error: ${e.response?.statusCode}";
      default:
        return "Something went wrong. Please try again.";
    }
  }
}