part of 'auth_bloc.dart';

@immutable
sealed class AuthEvent {}

class AuthSignUpRequested extends AuthEvent {
  final String email;
  final String password;
  final String fullname;
  final String createdAt;

  AuthSignUpRequested({
    required this.email,
    required this.password,
    required this.fullname,
    required this.createdAt,
  });
}

class AuthSignInRequested extends AuthEvent {
  final String email;
  final String password;

  AuthSignInRequested({
    required this.email,
    required this.password,
  });
}

class AuthSignOutRequested extends AuthEvent {}
