import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:sefrou_smart_city/models/pharmacy.dart';
import 'package:sefrou_smart_city/services/pharmacy_service.dart';

// Events
abstract class PharmacyEvent extends Equatable {
  const PharmacyEvent();

  @override
  List<Object> get props => [];
}

class FetchPharmacies extends PharmacyEvent {
  const FetchPharmacies();
}

class UpdatePharmacies extends PharmacyEvent {
  final List<Pharmacy> pharmacies;
  const UpdatePharmacies(this.pharmacies);

  @override
  List<Object> get props => [pharmacies];
}

// States
abstract class PharmacyState extends Equatable {
  const PharmacyState();

  @override
  List<Object> get props => [];
}

class PharmacyInitial extends PharmacyState {
  const PharmacyInitial();
}

class PharmacyLoading extends PharmacyState {
  const PharmacyLoading();
}

class PharmacyLoaded extends PharmacyState {
  final List<Pharmacy> pharmacies;
  final Pharmacy? dutyPharmacy;

  const PharmacyLoaded({
    required this.pharmacies,
    this.dutyPharmacy,
  });

  @override
  List<Object> get props => [pharmacies, dutyPharmacy ?? ''];
}

class PharmacyError extends PharmacyState {
  final String message;

  const PharmacyError(this.message);

  @override
  List<Object> get props => [message];
}

// Bloc
class PharmacyBloc extends Bloc<PharmacyEvent, PharmacyState> {
  final PharmacyService _pharmacyService;
  StreamSubscription? _subscription;

  PharmacyBloc({required PharmacyService pharmacyService})
      : _pharmacyService = pharmacyService,
        super(const PharmacyInitial()) {
    on<FetchPharmacies>(_onFetchPharmacies);
    on<UpdatePharmacies>(_onUpdatePharmacies);
  }

  Future<void> _onFetchPharmacies(
    FetchPharmacies event,
    Emitter<PharmacyState> emit,
  ) async {
    emit(const PharmacyLoading());
    await _subscription?.cancel();
    _subscription = _pharmacyService.getPharmaciesStream().listen((pharmacies) {
      add(UpdatePharmacies(pharmacies));
    });
  }

  void _onUpdatePharmacies(
    UpdatePharmacies event,
    Emitter<PharmacyState> emit,
  ) {
    Pharmacy? dutyPharmacy;
    try {
      dutyPharmacy = event.pharmacies.firstWhere((p) => p.isDuty || p.isDayDuty);
    } catch (_) {
      dutyPharmacy = event.pharmacies.isNotEmpty ? event.pharmacies.first : null;
    }
    emit(PharmacyLoaded(
      pharmacies: event.pharmacies,
      dutyPharmacy: dutyPharmacy,
    ));
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
