import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../models/user.dart';
import '../../services/auth_service.dart';

// Events
abstract class AdminUserEvent extends Equatable {
  const AdminUserEvent();

  @override
  List<Object> get props => [];
}

class FetchAdminUsers extends AdminUserEvent {
  const FetchAdminUsers();
}

class AddAdminUser extends AdminUserEvent {
  final String email;
  final String password;
  final String displayName;
  final String role;

  const AddAdminUser({
    required this.email,
    required this.password,
    required this.displayName,
    required this.role,
  });

  @override
  List<Object> get props => [email, password, displayName, role];
}

class UpdateAdminUserRole extends AdminUserEvent {
  final String userId;
  final String newRole;

  const UpdateAdminUserRole({
    required this.userId,
    required this.newRole,
  });

  @override
  List<Object> get props => [userId, newRole];
}

class DeleteAdminUser extends AdminUserEvent {
  final String userId;

  const DeleteAdminUser(this.userId);

  @override
  List<Object> get props => [userId];
}

// States
abstract class AdminUserState extends Equatable {
  const AdminUserState();

  @override
  List<Object> get props => [];
}

class AdminUserInitial extends AdminUserState {
  const AdminUserInitial();
}

class AdminUserLoading extends AdminUserState {
  const AdminUserLoading();
}

class AdminUserLoaded extends AdminUserState {
  final List<User> users;

  const AdminUserLoaded(this.users);

  @override
  List<Object> get props => [users];
}

class AdminUserError extends AdminUserState {
  final String message;

  const AdminUserError(this.message);

  @override
  List<Object> get props => [message];
}

class AdminUserSuccess extends AdminUserState {
  final String message;

  const AdminUserSuccess(this.message);

  @override
  List<Object> get props => [message];
}

// Bloc
class AdminUserBloc extends Bloc<AdminUserEvent, AdminUserState> {
  final AuthService _authService;

  AdminUserBloc({required AuthService authService})
      : _authService = authService,
        super(const AdminUserInitial()) {
    on<FetchAdminUsers>(_onFetchUsers);
    on<AddAdminUser>(_onAddUser);
    on<UpdateAdminUserRole>(_onUpdateUserRole);
    on<DeleteAdminUser>(_onDeleteUser);
  }

  Future<void> _onFetchUsers(
    FetchAdminUsers event,
    Emitter<AdminUserState> emit,
  ) async {
    emit(const AdminUserLoading());
    try {
      final users = await _authService.listUsers();
      emit(AdminUserLoaded(users));
    } catch (e) {
      emit(AdminUserError('Failed to fetch users: $e'));
    }
  }

  Future<void> _onAddUser(
    AddAdminUser event,
    Emitter<AdminUserState> emit,
  ) async {
    try {
      await _authService.signUp(
        email: event.email,
        password: event.password,
        displayName: event.displayName,
      );
      await _authService.updateUserRole(event.email, event.role);
      emit(const AdminUserSuccess('User added successfully'));
      add(const FetchAdminUsers());
    } catch (e) {
      emit(AdminUserError('Failed to add user: $e'));
    }
  }

  Future<void> _onUpdateUserRole(
    UpdateAdminUserRole event,
    Emitter<AdminUserState> emit,
  ) async {
    try {
      await _authService.updateUserRole(event.userId, event.newRole);
      emit(const AdminUserSuccess('User role updated successfully'));
      add(const FetchAdminUsers());
    } catch (e) {
      emit(AdminUserError('Failed to update user role: $e'));
    }
  }

  Future<void> _onDeleteUser(
    DeleteAdminUser event,
    Emitter<AdminUserState> emit,
  ) async {
    try {
      await _authService.deleteUser(event.userId);
      emit(const AdminUserSuccess('User deleted successfully'));
      add(const FetchAdminUsers());
    } catch (e) {
      emit(AdminUserError('Failed to delete user: $e'));
    }
  }
}
