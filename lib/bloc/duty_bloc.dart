import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:sefrou_smart_city/models/duty_schedule.dart';
import 'package:sefrou_smart_city/services/firebase_service.dart';

// Events
abstract class DutyEvent extends Equatable {
  const DutyEvent();

  @override
  List<Object> get props => [];
}

class FetchDutySchedules extends DutyEvent {
  const FetchDutySchedules();
}

class ListenToDutySchedules extends DutyEvent {
  const ListenToDutySchedules();
}

class AddDutySchedule extends DutyEvent {
  final DutySchedule schedule;

  const AddDutySchedule(this.schedule);

  @override
  List<Object> get props => [schedule];
}

class UpdateDutySchedule extends DutyEvent {
  final DutySchedule schedule;

  const UpdateDutySchedule(this.schedule);

  @override
  List<Object> get props => [schedule];
}

class DeleteDutySchedule extends DutyEvent {
  final String scheduleId;

  const DeleteDutySchedule(this.scheduleId);

  @override
  List<Object> get props => [scheduleId];
}

// States
abstract class DutyState extends Equatable {
  const DutyState();

  @override
  List<Object> get props => [];
}

class DutyInitial extends DutyState {
  const DutyInitial();
}

class DutyLoading extends DutyState {
  const DutyLoading();
}

class DutyLoaded extends DutyState {
  final List<DutySchedule> schedules;
  final DutySchedule? currentDutyPharmacy;

  const DutyLoaded({
    required this.schedules,
    this.currentDutyPharmacy,
  });

  @override
  List<Object> get props => [schedules, currentDutyPharmacy ?? ''];
}

class DutyError extends DutyState {
  final String message;

  const DutyError(this.message);

  @override
  List<Object> get props => [message];
}

class DutySuccess extends DutyState {
  final String message;

  const DutySuccess(this.message);

  @override
  List<Object> get props => [message];
}

// Bloc
class DutyBloc extends Bloc<DutyEvent, DutyState> {
  final FirebaseService _firebaseService;

  DutyBloc({required FirebaseService firebaseService})
      : _firebaseService = firebaseService,
        super(const DutyInitial()) {
    on<FetchDutySchedules>(_onFetchDutySchedules);
    on<ListenToDutySchedules>(_onListenToDutySchedules);
    on<AddDutySchedule>(_onAddDutySchedule);
    on<UpdateDutySchedule>(_onUpdateDutySchedule);
    on<DeleteDutySchedule>(_onDeleteDutySchedule);
  }

  Future<void> _onFetchDutySchedules(
    FetchDutySchedules event,
    Emitter<DutyState> emit,
  ) async {
    emit(const DutyLoading());
    try {
      final schedules = await _firebaseService.getDutySchedules();
      final currentDuty = await _firebaseService.getCurrentDutyPharmacy();
      emit(DutyLoaded(
        schedules: schedules,
        currentDutyPharmacy: currentDuty,
      ));
    } catch (e) {
      emit(DutyError('Failed to fetch duty schedules: $e'));
    }
  }

  Future<void> _onListenToDutySchedules(
    ListenToDutySchedules event,
    Emitter<DutyState> emit,
  ) async {
    emit(const DutyLoading());
    try {
      await emit.forEach(
        _firebaseService.getDutySchedulesStream(),
        onData: (List<DutySchedule> schedules) {
          DutySchedule? currentDuty;
          try {
            currentDuty = schedules.firstWhere((s) => s.isDutyNow);
          } catch (_) {
            currentDuty = null;
          }
          return DutyLoaded(
            schedules: schedules,
            currentDutyPharmacy: currentDuty,
          );
        },
        onError: (error, stackTrace) {
          return DutyError('Error listening to duty schedules: $error');
        },
      );
    } catch (e) {
      emit(DutyError('Failed to listen to duty schedules: $e'));
    }
  }

  Future<void> _onAddDutySchedule(
    AddDutySchedule event,
    Emitter<DutyState> emit,
  ) async {
    try {
      await _firebaseService.addDutySchedule(event.schedule);
      emit(const DutySuccess('Duty schedule added successfully'));
      add(const FetchDutySchedules());
    } catch (e) {
      emit(DutyError('Failed to add duty schedule: $e'));
    }
  }

  Future<void> _onUpdateDutySchedule(
    UpdateDutySchedule event,
    Emitter<DutyState> emit,
  ) async {
    try {
      await _firebaseService.updateDutySchedule(event.schedule);
      emit(const DutySuccess('Duty schedule updated successfully'));
      add(const FetchDutySchedules());
    } catch (e) {
      emit(DutyError('Failed to update duty schedule: $e'));
    }
  }

  Future<void> _onDeleteDutySchedule(
    DeleteDutySchedule event,
    Emitter<DutyState> emit,
  ) async {
    try {
      await _firebaseService.deleteDutySchedule(event.scheduleId);
      emit(const DutySuccess('Duty schedule deleted successfully'));
      add(const FetchDutySchedules());
    } catch (e) {
      emit(DutyError('Failed to delete duty schedule: $e'));
    }
  }
}
