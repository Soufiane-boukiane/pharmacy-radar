import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../models/pharmacy.dart';
import '../../services/pharmacy_service.dart';

// Events
abstract class AdminPharmacyEvent extends Equatable {
  const AdminPharmacyEvent();

  @override
  List<Object> get props => [];
}

class FetchAdminPharmacies extends AdminPharmacyEvent {
  const FetchAdminPharmacies();
}

class AddAdminPharmacy extends AdminPharmacyEvent {
  final Pharmacy pharmacy;

  const AddAdminPharmacy(this.pharmacy);

  @override
  List<Object> get props => [pharmacy];
}

class UpdateAdminPharmacy extends AdminPharmacyEvent {
  final Pharmacy pharmacy;

  const UpdateAdminPharmacy(this.pharmacy);

  @override
  List<Object> get props => [pharmacy];
}

class DeleteAdminPharmacy extends AdminPharmacyEvent {
  final String pharmacyId;

  const DeleteAdminPharmacy(this.pharmacyId);

  @override
  List<Object> get props => [pharmacyId];
}

class BulkUpdateDutyStatus extends AdminPharmacyEvent {
  final bool isDuty;

  const BulkUpdateDutyStatus(this.isDuty);

  @override
  List<Object> get props => [isDuty];
}

// States
abstract class AdminPharmacyState extends Equatable {
  const AdminPharmacyState();

  @override
  List<Object> get props => [];
}

class AdminPharmacyInitial extends AdminPharmacyState {
  const AdminPharmacyInitial();
}

class AdminPharmacyLoading extends AdminPharmacyState {
  const AdminPharmacyLoading();
}

class AdminPharmacyLoaded extends AdminPharmacyState {
  final List<Pharmacy> pharmacies;

  const AdminPharmacyLoaded(this.pharmacies);

  @override
  List<Object> get props => [pharmacies];
}

class AdminPharmacyError extends AdminPharmacyState {
  final String message;

  const AdminPharmacyError(this.message);

  @override
  List<Object> get props => [message];
}

class AdminPharmacySuccess extends AdminPharmacyState {
  final String message;

  const AdminPharmacySuccess(this.message);

  @override
  List<Object> get props => [message];
}

// Bloc
class AdminPharmacyBloc extends Bloc<AdminPharmacyEvent, AdminPharmacyState> {
  final PharmacyService _pharmacyService;

  AdminPharmacyBloc({required PharmacyService pharmacyService})
      : _pharmacyService = pharmacyService,
        super(const AdminPharmacyInitial()) {
    on<FetchAdminPharmacies>(_onFetchPharmacies);
    on<AddAdminPharmacy>(_onAddPharmacy);
    on<UpdateAdminPharmacy>(_onUpdatePharmacy);
    on<DeleteAdminPharmacy>(_onDeletePharmacy);
    on<BulkUpdateDutyStatus>(_onBulkUpdateDutyStatus);
  }

  Future<void> _onFetchPharmacies(
    FetchAdminPharmacies event,
    Emitter<AdminPharmacyState> emit,
  ) async {
    emit(const AdminPharmacyLoading());
    try {
      final pharmacies = await _pharmacyService.getPharmacies();
      emit(AdminPharmacyLoaded(pharmacies));
    } catch (e) {
      emit(AdminPharmacyError('Failed to fetch pharmacies: $e'));
    }
  }

  Future<void> _onAddPharmacy(
    AddAdminPharmacy event,
    Emitter<AdminPharmacyState> emit,
  ) async {
    try {
      await _pharmacyService.addPharmacy(event.pharmacy);
      emit(const AdminPharmacySuccess('Pharmacy added successfully'));
      add(const FetchAdminPharmacies());
    } catch (e) {
      emit(AdminPharmacyError('Failed to add pharmacy: $e'));
    }
  }

  Future<void> _onUpdatePharmacy(
    UpdateAdminPharmacy event,
    Emitter<AdminPharmacyState> emit,
  ) async {
    try {
      await _pharmacyService.updatePharmacy(event.pharmacy);
      emit(const AdminPharmacySuccess('Pharmacy updated successfully'));
      add(const FetchAdminPharmacies());
    } catch (e) {
      emit(AdminPharmacyError('Failed to update pharmacy: $e'));
    }
  }

  Future<void> _onDeletePharmacy(
    DeleteAdminPharmacy event,
    Emitter<AdminPharmacyState> emit,
  ) async {
    try {
      await _pharmacyService.deletePharmacy(event.pharmacyId);
      emit(const AdminPharmacySuccess('Pharmacy deleted successfully'));
      add(const FetchAdminPharmacies());
    } catch (e) {
      emit(AdminPharmacyError('Failed to delete pharmacy: $e'));
    }
  }

  Future<void> _onBulkUpdateDutyStatus(
    BulkUpdateDutyStatus event,
    Emitter<AdminPharmacyState> emit,
  ) async {
    try {
      await _pharmacyService.bulkUpdateDutyStatus(event.isDuty);
      emit(AdminPharmacySuccess('All pharmacies ${event.isDuty ? 'activated' : 'deactivated'} successfully'));
      add(const FetchAdminPharmacies());
    } catch (e) {
      emit(AdminPharmacyError('Failed to update pharmacies: $e'));
    }
  }
}
