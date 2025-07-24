import 'package:bloc/bloc.dart';
import 'package:gh6_ucap/services/auth_service.dart';
import 'package:meta/meta.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthService _authService = AuthService();
  AuthBloc() : super(AuthInitial()) {
    on<AuthSignUpRequested>(_onSignUpRequested);
    on<AuthSignInRequested>(_onSignInRequested);
    // on<AuthSignOutRequested>(_onSignOutRequested);
  }

  Future<void> _onSignUpRequested(
    AuthSignUpRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      await _authService.signUp(
        email: event.email,
        password: event.password,
        fullname: event.fullname,
        createdAt: event.createdAt,
      );
      emit(AuthSuccess('Account created successfully!'));
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }

  Future<void> _onSignInRequested(
    AuthSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      await _authService.signIn(
        email: event.email,
        password: event.password,
      );
      emit(AuthSuccess('Login successful!'));
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }

  // Future<void> _onSignOutRequested(
  //   AuthSignOutRequested event,
  //   Emitter<AuthState> emit,
  // ) async {
  //   emit(AuthLoading());
  //   try {
  //     await _authService.signOut();
  //     emit(AuthSuccess('Logged out successfully!'));
  //   } catch (e) {
  //     emit(AuthFailure(e.toString()));
  //   }
  // }
}
