import 'package:flutter_dotenv/flutter_dotenv.dart';

class EnvConfig {
  static Future<void> init({String fileName = ".env.dev"}) async {
    await dotenv.load(fileName: fileName);
  }

  static String get baseUrl => dotenv.env['BASE_URL'] ?? "";
}
