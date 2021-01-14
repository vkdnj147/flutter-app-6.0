import 'dart:async';

import 'package:ibetalabs_flutter_app/support/dioclient/dio_client.dart';
import 'package:meta/meta.dart';
import 'package:shared_preferences/shared_preferences.dart';


class SignInFailure implements Exception {}

class SignOutFailure implements Exception {}

enum AuthenticationStatus { unknown, authenticated, unauthenticated }

class AuthenticationRepository {
  final DioClient _dioClient;
  AuthenticationRepository(this._dioClient) : assert(_dioClient != null);

  final _controller = StreamController<AuthenticationStatus>();
  Stream<AuthenticationStatus> get status async* {
    await Future<void>.delayed(const Duration(seconds: 1));
    yield AuthenticationStatus.unauthenticated;
    yield* _controller.stream;
  }

  Future<void> signIn({
    @required String token,
  }) async {
    assert(token != null);
    print(']-----] AuthenticationRepository::signIn [-----[ ${token}');
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('accessTokenBeta', token);
      await Future.delayed(
        const Duration(milliseconds: 300),
        () => _controller.add(AuthenticationStatus.authenticated),
      );
    } on Exception {
      throw SignInFailure();
    }
  }

  Future<void> signOut() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.remove('accessTokenBeta');
      _controller.add(AuthenticationStatus.unauthenticated);
    } on Exception {
      throw SignOutFailure();
    }
  }

  Future<String> getAccessToken() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      return prefs.getString('accessTokenBeta');
    } on Exception {
      throw SignInFailure();
    }
  }

  void dispose() => _controller.close();
}
