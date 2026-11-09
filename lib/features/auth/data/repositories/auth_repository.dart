import 'package:rafoof/core/constants/app_constants.dart';
import 'package:rafoof/core/constants/app_strings.dart';
import 'package:rafoof/core/network/api_client.dart';
import 'package:rafoof/core/network/api_endpoints.dart';
import 'package:rafoof/core/network/response_wrapper.dart';
import 'package:rafoof/core/services/app_preferences.dart';
import 'package:rafoof/features/auth/data/models/user_model.dart';

class AuthRepository {
  final ApiConsumer apiConsumer;
  final AppPreferences appPreferences;

  AuthRepository({required this.apiConsumer, required this.appPreferences});

  Future<UserModel> login({
    required String username,
    required String password,
    required bool keepSignedIn,
  }) async {
    final ResponseWrapper response = await apiConsumer.post(
      ApiEndpoints.login,
      body: {
        'username': username,
        'password': password,
        'expiresInMins': AppConstants.tokenExpiresInMins,
      },
    );

    final data = response.data;
    if (data is! Map<String, dynamic> || data['accessToken'] == null) {
      final message = data is Map ? data['message']?.toString() : null;
      throw Exception(message ?? AppStrings.invalidCredentials);
    }

    await appPreferences.setToken(data['accessToken'].toString());
    await appPreferences.setRefreshToken(
      data['refreshToken']?.toString() ?? '',
    );
    await appPreferences.setKeepSignedIn(keepSignedIn);
    await appPreferences.setAuthenticated(true);

    final user = UserModel.fromJson(data);
    await appPreferences.setUserName(user.fullName);
    await appPreferences.setUserEmail(user.email);
    return user;
  }

  Future<UserModel> getCurrentUser() async {
    final ResponseWrapper response = await apiConsumer.get(
      ApiEndpoints.currentUser,
    );

    final data = response.data;
    if (data is! Map<String, dynamic> || data['id'] == null) {
      throw Exception(AppStrings.loadUserFailed);
    }

    return UserModel.fromJson(data);
  }

  Future<void> logout() => appPreferences.logout();
}
