import 'dart:async';

enum AuthEvent { authenticated, unauthenticated, logout }

class AuthEventService {
  static final AuthEventService _instance = AuthEventService._internal();
  factory AuthEventService() => _instance;
  AuthEventService._internal();

  final _authEventController = StreamController<AuthEvent>.broadcast();
  Stream<AuthEvent> get authEvents => _authEventController.stream;

  void emit(AuthEvent event) {
    _authEventController.add(event);
  }

  void dispose() {
    _authEventController.close();
  }
}
