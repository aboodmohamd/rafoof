import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:rafoof/core/constants/app_constants.dart';
import 'package:rafoof/core/network/api_endpoints.dart';
import 'package:rafoof/core/services/auth_event_service.dart';
import 'package:rafoof/core/services/app_preferences.dart';
import 'package:rafoof/core/services/network_logger.dart';
import 'package:flutter/foundation.dart';

class AppInterceptors extends Interceptor {
  final AppPreferences appPreferences;
  final Dio dio;
  AppInterceptors({required this.appPreferences, required this.dio});

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    options.headers['Content-Type'] = 'application/json';
    options.headers['charset'] = 'utf-8';
    options.headers['Accept'] = 'application/json';
    options.headers['X-Platform'] = Platform.isAndroid ? 'android' : 'ios';
    options.headers['Accept-Language'] = 'en';

    final token = appPreferences.getToken();
    if (token != null && token.isNotEmpty) {
      options.headers["Authorization"] = "Bearer $token";
    }

    NetworkLogger().logRequest(options.method, options.path, options.data);
    super.onRequest(options, handler);
  }

  @override
  Future<void> onResponse(
    Response response,
    ResponseInterceptorHandler handler,
  ) async {
    debugPrint(
      'RESPONSE[${response.statusCode}] => PATH: ${response.requestOptions.path}',
    );

    if (response.statusCode == 401) {
      final options = response.requestOptions;
      final canRefresh =
          options.extra['retried'] != true &&
          !options.path.contains(ApiEndpoints.login) &&
          !options.path.contains(ApiEndpoints.refreshToken);

      if (canRefresh && await _refreshToken()) {
        try {
          options.extra['retried'] = true;
          final retryResponse = await dio.fetch(options);
          return handler.resolve(retryResponse);
        } catch (_) {}
      }

      await _logoutAndRedirect();
      return handler.next(response);
    }

    if (response.data is Map<String, dynamic>) {
      final data = response.data as Map<String, dynamic>;
      if (data.containsKey('status')) {
        final status = data['status'];
        final int error = status['error'] ?? 0;
        final String message = status['message'] ?? '';
        final List<dynamic> errorMessages = status['error_messages'] ?? [];

        if (error == 1) {
          return handler.reject(
            DioException(
              requestOptions: response.requestOptions,
              response: response,
              type: DioExceptionType.badResponse,
              message: errorMessages.isNotEmpty
                  ? errorMessages.join(', ')
                  : message,
            ),
          );
        }
      }
    }

    dynamic logData = response.data;

    if (response.data is String) {
      try {
        final decodedResponse = json.decode(response.data);
        if (kDebugMode) {
          final prettyJson = const JsonEncoder.withIndent('  ')
              .convert(decodedResponse);
          debugPrint("Response Decoded:\n$prettyJson");
        }
        logData = decodedResponse;
      } catch (e) {
        if (kDebugMode) {
          debugPrint("Failed to decode response: ${response.data}");
        }
      }
    } else if (response.data is Map<String, dynamic>) {
      if (kDebugMode) {
        final prettyJson = const JsonEncoder.withIndent('  ')
            .convert(response.data);
        debugPrint("Response JSON:\n$prettyJson");
      }
    } else {
      debugPrint("Response Data: ${response.data}");
    }

    NetworkLogger().logResponse(
      response.requestOptions.path,
      response.statusCode ?? 0,
      logData,
    );
    super.onResponse(response, handler);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    debugPrint(
      'ERROR[${err.response?.statusCode}] => PATH: ${err.requestOptions.path}',
    );

    NetworkLogger().logError(
      err.requestOptions.path,
      err.response?.statusCode ?? 0,
      err.message ?? 'Unknown Error',
    );

    super.onError(err, handler);
  }

  Future<bool> _refreshToken() async {
    final refreshToken = appPreferences.getRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) return false;

    try {
      final response =
          await Dio(
            BaseOptions(
              baseUrl: dio.options.baseUrl,
              connectTimeout: const Duration(seconds: 15),
              receiveTimeout: const Duration(seconds: 15),
            ),
          ).post(
            ApiEndpoints.refreshToken,
            data: {
              'refreshToken': refreshToken,
              'expiresInMins': AppConstants.tokenExpiresInMins,
            },
          );

      final data = response.data;
      if (data is! Map || data['accessToken'] == null) return false;

      await appPreferences.setToken(data['accessToken'].toString());
      if (data['refreshToken'] != null) {
        await appPreferences.setRefreshToken(data['refreshToken'].toString());
      }
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> _logoutAndRedirect() async {
    debugPrint("Session expired → emitting unauthenticated event");
    await appPreferences.logout();
    AuthEventService().emit(AuthEvent.unauthenticated);
  }
}
