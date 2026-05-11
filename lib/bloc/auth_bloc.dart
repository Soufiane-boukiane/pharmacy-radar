import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../models/user.dart';
import '../../services/auth_service.dart';

// Events
abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object> get props => [];
}

class AuthCheckStatus extends AuthEvent {
  const AuthCheckStatus();
}

class AuthSignUp extends AuthEvent {
  final String email;
  final String password;
  final String displayName;

  const AuthSignUp({
    required this.email,
    required this.password,
    required this.displayName,
  });

  @override
  List<Object> get props => [email, password, displayName];
}

class AuthSignIn extends AuthEvent {
  final String email;
  final String password;

  const AuthSignIn({
    required this.email,
    required this.password,
  });

  @override
  List<Object> get props => [email, password];
}

class AuthSignOut extends AuthEvent {
  const AuthSignOut();
}

class AuthResetPassword extends AuthEvent {
  final String email;

  const AuthResetPassword(this.email);

  @override
  List<Object> get props => [email];
}

// States
abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object> get props => [];
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

class Authenticated extends AuthState {
  final User user;

  const Authenticated(this.user);

  @override
  List<Object> get props => [user];
}

class Unauthenticated extends AuthState {
  const Unauthenticated();
}

class AuthError extends AuthState {
  final String message;

  const AuthError(this.message);

  @override
  List<Object> get props => [message];
}

class PasswordResetSent extends AuthState {
  final String email;

  const PasswordResetSent(this.email);

  @override
  List<Object> get props => [email];
}

// Bloc
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthService _authService;

  AuthBloc({required AuthService authService})
      : _authService = authService,
        super(const AuthInitial()) {
    on<AuthCheckStatus>(_onCheckStatus);
    on<AuthSignUp>(_onSignUp);
    on<AuthSignIn>(_onSignIn);
    on<AuthSignOut>(_onSignOut);
    on<AuthResetPassword>(_onResetPassword);
  }

  Future<void> _onCheckStatus(
    AuthCheckStatus event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      final currentFbUser = AuthService().currentUser; // Using the existing getter to get UID
      
      if (currentFbUser != null) {
        final fullUser = await _authService.getUserById(currentFbUser.uid);
        if (fullUser != null) {
          emit(Authenticated(fullUser));
        } else {
          emit(Authenticated(currentFbUser));
        }
      } else {
        emit(const Unauthenticated());
      }
    } catch (e) {
      emit(AuthError('Failed to check auth status: $e'));
    }
  }

  Future<void> _onSignUp(
    AuthSignUp event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      final user = await _authService.signUp(
        email: event.email,
        password: event.password,
        displayName: event.displayName,
      );

      if (user != null) {
        emit(Authenticated(user));
      } else {
        emit(const AuthError('Sign up failed'));
      }
    } catch (e) {
      emit(AuthError('Sign up error: $e'));
    }
  }

  Future<void> _onSignIn(
    AuthSignIn event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      final user = await _authService.signIn(
        email: event.email,
        password: event.password,
      );

      if (user != null) {
        await _authService.updateLastLogin(user.uid);
        emit(Authenticated(user));
      } else {
        emit(const AuthError('Sign in failed'));
      }
    } catch (e) {
      emit(AuthError('Sign in error: $e'));
    }
  }

  Future<void> _onSignOut(
    AuthSignOut event,
    Emitter<AuthState> emit,
  ) async {
    try {
      await _authService.signOut();
      emit(const Unauthenticated());
    } catch (e) {
      emit(AuthError('Sign out error: $e'));
    }
  }

  Future<void> _onResetPassword(
    AuthResetPassword event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      await _authService.resetPassword(event.email);
      emit(PasswordResetSent(event.email));
    } catch (e) {
      emit(AuthError('Password reset error: $e'));
    }
  }
}
