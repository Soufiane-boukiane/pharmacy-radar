import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:latlong2/latlong.dart';
import 'package:sefrou_smart_city/models/pharmacy.dart';
import 'package:sefrou_smart_city/services/pharmacy_service.dart';
import 'package:sefrou_smart_city/services/location_service.dart';
import 'package:sefrou_smart_city/services/firebase_service.dart';
import 'package:sefrou_smart_city/services/routing_service.dart';
import 'package:sefrou_smart_city/models/government_service.dart';

// Events
abstract class MapEvent extends Equatable {
  const MapEvent();

  @override
  List<Object> get props => [];
}

class InitializeMap extends MapEvent {
  const InitializeMap();
}

class LoadPharmaciesOnMap extends MapEvent {
  const LoadPharmaciesOnMap();
}

class UpdateMapPharmacies extends MapEvent {
  final List<Pharmacy> pharmacies;
  const UpdateMapPharmacies(this.pharmacies);

  @override
  List<Object> get props => [pharmacies];
}

class RefreshMapPharmacies extends MapEvent {
  const RefreshMapPharmacies();
}

class UpdateMapServices extends MapEvent {
  final List<GovernmentService> services;
  const UpdateMapServices(this.services);

  @override
  List<Object> get props => [services];
}

class LoadServicesOnMap extends MapEvent {
  const LoadServicesOnMap();
}

class UpdateUserLocation extends MapEvent {
  const UpdateUserLocation();
}

class GetDirections extends MapEvent {
  final LatLng destination;
  final String? destinationName;
  const GetDirections(this.destination, {this.destinationName});

  @override
  List<Object> get props => [destination, destinationName ?? ''];
}

class ClearRoute extends MapEvent {
  const ClearRoute();
}

// States
abstract class MapState extends Equatable {
  const MapState();

  @override
  List<Object> get props => [];
}

class MapInitial extends MapState {
  const MapInitial();
}

class MapLoading extends MapState {
  const MapLoading();
}

class MapLoaded extends MapState {
  final List<Pharmacy> pharmacies;
  final List<GovernmentService> governmentServices;
  final LatLng? userLocation;
  final LatLng centerLocation;
  final List<LatLng> routePoints;

  const MapLoaded({
    required this.pharmacies,
    this.governmentServices = const [],
    this.userLocation,
    required this.centerLocation,
    this.routePoints = const [],
  });

  MapLoaded copyWith({
    List<Pharmacy>? pharmacies,
    List<GovernmentService>? governmentServices,
    LatLng? userLocation,
    LatLng? centerLocation,
    List<LatLng>? routePoints,
  }) {
    return MapLoaded(
      pharmacies: pharmacies ?? this.pharmacies,
      governmentServices: governmentServices ?? this.governmentServices,
      userLocation: userLocation ?? this.userLocation,
      centerLocation: centerLocation ?? this.centerLocation,
      routePoints: routePoints ?? this.routePoints,
    );
  }

  @override
  List<Object> get props => [pharmacies, governmentServices, userLocation ?? '', centerLocation, routePoints];
}

class MapError extends MapState {
  final String message;

  const MapError(this.message);

  @override
  List<Object> get props => [message];
}

// Bloc
class MapBloc extends Bloc<MapEvent, MapState> {
  final PharmacyService _pharmacyService;
  final LocationService _locationService;
  final FirebaseService _firebaseService;
  final RoutingService _routingService = RoutingService();
  StreamSubscription? _pharmacySubscription;
  StreamSubscription? _servicesSubscription;

  static const LatLng sefrouCenter = LatLng(33.8300, -4.8300);

  MapBloc({
    required PharmacyService pharmacyService,
    required LocationService locationService,
    required FirebaseService firebaseService,
  })  : _pharmacyService = pharmacyService,
        _locationService = locationService,
        _firebaseService = firebaseService,
        super(const MapInitial()) {
    on<InitializeMap>(_onInitializeMap);
    on<LoadPharmaciesOnMap>(_onLoadPharmaciesOnMap);
    on<LoadServicesOnMap>(_onLoadServicesOnMap);
    on<UpdateMapPharmacies>(_onUpdateMapPharmacies);
    on<UpdateMapServices>(_onUpdateMapServices);
    on<RefreshMapPharmacies>(_onRefreshMapPharmacies);
    on<UpdateUserLocation>(_onUpdateUserLocation);
    on<GetDirections>(_onGetDirections);
    on<ClearRoute>(_onClearRoute);
  }

  Future<void> _onInitializeMap(
    InitializeMap event,
    Emitter<MapState> emit,
  ) async {
    emit(const MapLoading());
    try {
      await _locationService.requestLocationPermission();
      add(const LoadPharmaciesOnMap());
      add(const LoadServicesOnMap());
    } catch (e) {
      emit(MapError('Failed to initialize map: $e'));
    }
  }

  void _onUpdateMapPharmacies(
    UpdateMapPharmacies event,
    Emitter<MapState> emit,
  ) {
    if (state is MapLoaded) {
      emit((state as MapLoaded).copyWith(pharmacies: event.pharmacies));
    } else if (state is MapLoading || state is MapInitial) {
      emit(MapLoaded(
        pharmacies: event.pharmacies,
        centerLocation: sefrouCenter,
      ));
    }
  }

  void _onUpdateMapServices(
    UpdateMapServices event,
    Emitter<MapState> emit,
  ) {
    if (state is MapLoaded) {
      emit((state as MapLoaded).copyWith(governmentServices: event.services));
    }
  }

  Future<void> _onLoadPharmaciesOnMap(
    LoadPharmaciesOnMap event,
    Emitter<MapState> emit,
  ) async {
    await _pharmacySubscription?.cancel();
    _pharmacySubscription = _pharmacyService.getPharmaciesStream().listen((pharmacies) {
      add(UpdateMapPharmacies(pharmacies));
    });

    try {
      final userLocation = await _locationService.getCurrentLocation();
      if (state is MapLoading || state is MapInitial) {
        emit(MapLoaded(
          pharmacies: const [],
          userLocation: userLocation != null
              ? LatLng(userLocation.latitude, userLocation.longitude)
              : null,
          centerLocation: sefrouCenter,
        ));
      } else if (state is MapLoaded) {
        emit((state as MapLoaded).copyWith(
          userLocation: userLocation != null
              ? LatLng(userLocation.latitude, userLocation.longitude)
              : null,
        ));
      }
    } catch (e) {
      if (state is MapLoading || state is MapInitial) {
        emit(const MapLoaded(
          pharmacies: [],
          centerLocation: sefrouCenter,
        ));
      }
    }
  }

  Future<void> _onLoadServicesOnMap(
    LoadServicesOnMap event,
    Emitter<MapState> emit,
  ) async {
    await _servicesSubscription?.cancel();
    _servicesSubscription = _firebaseService.getCollectionStream('government_services').listen((data) {
      final services = data.map((json) => GovernmentService.fromJson(json)).toList();
      add(UpdateMapServices(services));
    });
  }

  Future<void> _onRefreshMapPharmacies(
      RefreshMapPharmacies event, Emitter<MapState> emit) async {
    add(const LoadPharmaciesOnMap());
    add(const LoadServicesOnMap());
  }

  Future<void> _onUpdateUserLocation(
    UpdateUserLocation event,
    Emitter<MapState> emit,
  ) async {
    if (state is MapLoaded) {
      final currentState = state as MapLoaded;
      try {
        final userLocation = await _locationService.getCurrentLocation();
        emit(currentState.copyWith(
          userLocation: userLocation != null
              ? LatLng(userLocation.latitude, userLocation.longitude)
              : null,
        ));
      } catch (e) {
        // Silent failure for location update
      }
    }
  }

  Future<void> _onGetDirections(
    GetDirections event,
    Emitter<MapState> emit,
  ) async {
    if (state is MapLoaded) {
      final currentState = state as MapLoaded;
      if (currentState.userLocation == null) {
        emit(const MapError('Please enable location to get directions'));
        return;
      }

      try {
        final route = await _routingService.getRoute(
          currentState.userLocation!,
          event.destination,
        );
        
        emit(currentState.copyWith(routePoints: route));
      } catch (e) {
        emit(MapError('Failed to get route: $e'));
      }
    }
  }

  void _onClearRoute(ClearRoute event, Emitter<MapState> emit) {
    if (state is MapLoaded) {
      final currentState = state as MapLoaded;
      emit(currentState.copyWith(routePoints: const []));
    }
  }

  @override
  Future<void> close() {
    _pharmacySubscription?.cancel();
    _servicesSubscription?.cancel();
    return super.close();
  }
}
