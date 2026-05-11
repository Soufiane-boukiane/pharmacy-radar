import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../services/firebase_service.dart';

// Events
abstract class AdminAnalyticsEvent extends Equatable {
  const AdminAnalyticsEvent();

  @override
  List<Object> get props => [];
}

class FetchAnalytics extends AdminAnalyticsEvent {
  const FetchAnalytics();
}

class RefreshAnalytics extends AdminAnalyticsEvent {
  const RefreshAnalytics();
}

// States
abstract class AdminAnalyticsState extends Equatable {
  const AdminAnalyticsState();

  @override
  List<Object> get props => [];
}

class AnalyticsInitial extends AdminAnalyticsState {
  const AnalyticsInitial();
}

class AnalyticsLoading extends AdminAnalyticsState {
  const AnalyticsLoading();
}

class AnalyticsLoaded extends AdminAnalyticsState {
  final int totalPharmacies;
  final int activeDutySchedules;
  final int totalAdminUsers;
  final int recentActivities;

  const AnalyticsLoaded({
    required this.totalPharmacies,
    required this.activeDutySchedules,
    required this.totalAdminUsers,
    required this.recentActivities,
  });

  @override
  List<Object> get props => [
    totalPharmacies,
    activeDutySchedules,
    totalAdminUsers,
    recentActivities,
  ];
}

class AnalyticsError extends AdminAnalyticsState {
  final String message;

  const AnalyticsError(this.message);

  @override
  List<Object> get props => [message];
}

// Bloc
class AdminAnalyticsBloc extends Bloc<AdminAnalyticsEvent, AdminAnalyticsState> {
  final FirebaseService _firebaseService;

  AdminAnalyticsBloc({required FirebaseService firebaseService})
      : _firebaseService = firebaseService,
        super(const AnalyticsInitial()) {
    on<FetchAnalytics>(_onFetchAnalytics);
    on<RefreshAnalytics>(_onRefreshAnalytics);
  }

  Future<void> _onFetchAnalytics(
    FetchAnalytics event,
    Emitter<AdminAnalyticsState> emit,
  ) async {
    emit(const AnalyticsLoading());
    try {
      // Fetch data from Firestore
      final pharmacies = await _firebaseService.getCollection('pharmacies');
      final dutySchedules = await _firebaseService.getCollection('duty_schedules');
      final users = await _firebaseService.getCollection('users');
      final auditLogs = await _firebaseService.getCollection('audit_logs');

      // Count active duty schedules
      final activeDuty = dutySchedules
          .where((d) => d['isActive'] == true)
          .length;

      emit(AnalyticsLoaded(
        totalPharmacies: pharmacies.length,
        activeDutySchedules: activeDuty,
        totalAdminUsers: users.length,
        recentActivities: auditLogs.length,
      ));
    } catch (e) {
      emit(AnalyticsError('Failed to fetch analytics: $e'));
    }
  }

  Future<void> _onRefreshAnalytics(
    RefreshAnalytics event,
    Emitter<AdminAnalyticsState> emit,
  ) async {
    await _onFetchAnalytics(const FetchAnalytics(), emit);
  }
}
