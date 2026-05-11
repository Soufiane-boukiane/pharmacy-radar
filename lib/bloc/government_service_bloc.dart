import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../models/government_service.dart';
import '../services/firebase_service.dart';

// Events
abstract class GovernmentServiceEvent extends Equatable {
  const GovernmentServiceEvent();
  @override
  List<Object> get props => [];
}

class FetchGovernmentServices extends GovernmentServiceEvent {
  const FetchGovernmentServices();
}

class AddGovernmentService extends GovernmentServiceEvent {
  final GovernmentService service;
  const AddGovernmentService(this.service);
  @override
  List<Object> get props => [service];
}

class DeleteGovernmentService extends GovernmentServiceEvent {
  final String id;
  const DeleteGovernmentService(this.id);
  @override
  List<Object> get props => [id];
}

// States
abstract class GovernmentServiceState extends Equatable {
  const GovernmentServiceState();
  @override
  List<Object> get props => [];
}

class GovernmentServiceInitial extends GovernmentServiceState {}
class GovernmentServiceLoading extends GovernmentServiceState {}
class GovernmentServiceLoaded extends GovernmentServiceState {
  final List<GovernmentService> services;
  const GovernmentServiceLoaded(this.services);
  @override
  List<Object> get props => [services];
}

class GovernmentServiceActionSuccess extends GovernmentServiceState {
  final String message;
  const GovernmentServiceActionSuccess(this.message);
  @override
  List<Object> get props => [message];
}

class GovernmentServiceError extends GovernmentServiceState {
  final String message;
  const GovernmentServiceError(this.message);
  @override
  List<Object> get props => [message];
}

// Bloc
class GovernmentServiceBloc extends Bloc<GovernmentServiceEvent, GovernmentServiceState> {
  final FirebaseService _firebaseService;

  GovernmentServiceBloc({required FirebaseService firebaseService})
      : _firebaseService = firebaseService,
        super(GovernmentServiceInitial()) {
    on<FetchGovernmentServices>(_onFetchServices);
    on<AddGovernmentService>(_onAddService);
    on<DeleteGovernmentService>(_onDeleteService);
  }

  Future<void> _onFetchServices(FetchGovernmentServices event, Emitter<GovernmentServiceState> emit) async {
    emit(GovernmentServiceLoading());
    try {
      final data = await _firebaseService.getCollection('government_services');
      final services = data.map((json) => GovernmentService.fromJson(json)).toList();
      emit(GovernmentServiceLoaded(services));
    } catch (e) {
      emit(GovernmentServiceError(e.toString()));
    }
  }

  Future<void> _onAddService(AddGovernmentService event, Emitter<GovernmentServiceState> emit) async {
    try {
      await _firebaseService.setData('government_services', event.service.id, event.service.toJson());
      emit(const GovernmentServiceActionSuccess('Facility added successfully!'));
      add(const FetchGovernmentServices());
    } catch (e) {
      emit(GovernmentServiceError(e.toString()));
    }
  }

  Future<void> _onDeleteService(DeleteGovernmentService event, Emitter<GovernmentServiceState> emit) async {
    try {
      await _firebaseService.deleteDocument('government_services', event.id);
      emit(const GovernmentServiceActionSuccess('Facility deleted successfully!'));
      add(const FetchGovernmentServices());
    } catch (e) {
      emit(GovernmentServiceError(e.toString()));
    }
  }
}
