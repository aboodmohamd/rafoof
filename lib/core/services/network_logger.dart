class NetworkLogger {
  static final NetworkLogger _instance = NetworkLogger._internal();

  factory NetworkLogger() {
    return _instance;
  }

  NetworkLogger._internal();

  final List<String> _logs = [];

  void logRequest(String method, String path, dynamic data) {
    _addLog('REQUEST [$method] $path\nBody: $data');
  }

  void logResponse(String path, int statusCode, dynamic data) {
    _addLog('RESPONSE [$statusCode] $path\nData: $data');
  }

  void logError(String path, int statusCode, String message) {
    _addLog('ERROR [$statusCode] $path\nMessage: $message');
  }

  void _addLog(String log) {
    _logs.add('[${DateTime.now().toIso8601String()}] $log');
    if (_logs.length > 20) {
      _logs.removeAt(0);
    }
  }

  String getLogs() {
    return _logs.join('\n\n');
  }

  void clear() {
    _logs.clear();
  }
}
