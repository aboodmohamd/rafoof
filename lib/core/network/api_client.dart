import 'package:dio/dio.dart';
import 'package:rafoof/core/constants/app_strings.dart';
import 'package:rafoof/core/env_config.dart';
import 'package:rafoof/core/network/app_interceptors.dart';
import 'package:rafoof/core/network/response_wrapper.dart';
import 'package:rafoof/core/network/status_code.dart';
import 'package:rafoof/core/network/status_model.dart';
import 'package:flutter/foundation.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

abstract class ApiConsumer {
  Future<dynamic> get(String path, {Map<String, dynamic>? queryParameters});

  Future<dynamic> post(
    String path, {
    Map<String, dynamic>? body,
    bool formDataIsEnabled = false,
    Map<String, dynamic>? queryParameters,
  });

  Future<dynamic> put(
    String path, {
    Map<String, dynamic>? body,
    Map<String, dynamic>? queryParameters,
  });

  Future<dynamic> patch(
    String path, {
    Map<String, dynamic>? body,
    Map<String, dynamic>? queryParameters,
  });

  Future<dynamic> delete(
    String path, {
    Map<String, dynamic>? body,
    bool formDataIsEnabled = false,
    Map<String, dynamic>? queryParameters,
  });
}

class ApiClient implements ApiConsumer {
  final Dio dioClient;
  final AppInterceptors interceptors;

  ApiClient({required this.dioClient, required this.interceptors}) {
    dioClient.options
      ..baseUrl = EnvConfig.baseUrl
      ..responseType = ResponseType.json
      ..maxRedirects = 5
      ..followRedirects = true
      ..validateStatus = (status) {
        return status! < StatusCode.internalServerError;
      }
      ..connectTimeout = const Duration(seconds: 15)
      ..receiveTimeout = const Duration(seconds: 15)
      ..sendTimeout = const Duration(seconds: 30);

    dioClient.interceptors.add(interceptors);

    if (kDebugMode) {
      dioClient.interceptors.add(
        PrettyDioLogger(
          requestHeader: true,
          requestBody: true,
          responseBody: true,
          responseHeader: false,
          error: true,
          compact: true,
          maxWidth: 90,
        ),
      );
    }
  }

  @override
  Future<dynamic> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await dioClient.get(
        path,
        queryParameters: queryParameters,
      );
      return _wrapResponse(response);
    } on DioException catch (error) {
      throw _handleDioError(error);
    }
  }

  @override
  Future<dynamic> post(
    String path, {
    Map<String, dynamic>? body,
    bool formDataIsEnabled = false,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await dioClient.post(
        path,
        queryParameters: queryParameters,
        data: formDataIsEnabled ? FormData.fromMap(body ?? {}) : body,
      );
      return _wrapResponse(response);
    } on DioException catch (error) {
      throw _handleDioError(error);
    }
  }

  @override
  Future<dynamic> put(
    String path, {
    Map<String, dynamic>? body,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await dioClient.put(
        path,
        queryParameters: queryParameters,
        data: body,
      );
      return _wrapResponse(response);
    } on DioException catch (error) {
      throw _handleDioError(error);
    }
  }

  @override
  Future<dynamic> patch(
    String path, {
    Map<String, dynamic>? body,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await dioClient.patch(
        path,
        queryParameters: queryParameters,
        data: body,
      );
      return _wrapResponse(response);
    } on DioException catch (error) {
      throw _handleDioError(error);
    }
  }

  @override
  Future<dynamic> delete(
    String path, {
    Map<String, dynamic>? body,
    bool formDataIsEnabled = false,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await dioClient.delete(
        path,
        queryParameters: queryParameters,
        data: formDataIsEnabled ? FormData.fromMap(body ?? {}) : body,
      );
      return _wrapResponse(response);
    } on DioException catch (error) {
      throw _handleDioError(error);
    }
  }

  ResponseWrapper _wrapResponse(Response response) {
    final wrapper = ResponseWrapper();
    wrapper.statusModel = StatusModel()
      ..code = response.statusCode ?? 200
      ..error = 0
      ..message = 'Success';

    if (response.data is Map<String, dynamic>) {
      final dataMap = response.data as Map<String, dynamic>;
      wrapper.data = dataMap['data'] ?? dataMap;
      if (dataMap.containsKey('status')) {
        final statusMap = dataMap['status'];
        wrapper.statusModel.message = statusMap['message'] ?? 'Success';
        wrapper.statusModel.code =
            statusMap['code'] ?? response.statusCode ?? 200;
      }
    } else {
      wrapper.data = response.data;
    }
    return wrapper;
  }

  Exception _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return Exception(AppStrings.connectionTimeout);

      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        final message = error.message ?? AppStrings.serverError;

        if (statusCode == StatusCode.unauthorized) {
          return Exception(AppStrings.invalidCredentials);
        }
        if (statusCode == StatusCode.forbidden) {
          return Exception(AppStrings.accessDenied);
        }
        if (statusCode == StatusCode.internalServerError) {
          return Exception(AppStrings.serverUnavailable);
        }
        return Exception(message);

      case DioExceptionType.cancel:
        return Exception(AppStrings.requestCancelled);

      case DioExceptionType.connectionError:
        return Exception(AppStrings.noInternet);

      case DioExceptionType.unknown:
      default:
        return Exception(AppStrings.somethingWentWrong);
    }
  }
}
