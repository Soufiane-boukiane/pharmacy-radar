import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../models/pharmacy.dart';
import '../../services/favorites_service.dart';

// Events
abstract class FavoritesEvent extends Equatable {
  const FavoritesEvent();

  @override
  List<Object> get props => [];
}

class LoadFavorites extends FavoritesEvent {
  const LoadFavorites();
}

class AddFavorite extends FavoritesEvent {
  final String pharmacyId;

  const AddFavorite(this.pharmacyId);

  @override
  List<Object> get props => [pharmacyId];
}

class RemoveFavorite extends FavoritesEvent {
  final String pharmacyId;

  const RemoveFavorite(this.pharmacyId);

  @override
  List<Object> get props => [pharmacyId];
}

class GetFavoritePharmacies extends FavoritesEvent {
  final List<Pharmacy> allPharmacies;

  const GetFavoritePharmacies(this.allPharmacies);

  @override
  List<Object> get props => [allPharmacies];
}

// States
abstract class FavoritesState extends Equatable {
  const FavoritesState();

  @override
  List<Object> get props => [];
}

class FavoritesInitial extends FavoritesState {
  const FavoritesInitial();
}

class FavoritesLoaded extends FavoritesState {
  final Set<String> favoriteIds;
  final List<Pharmacy> favorites;

  const FavoritesLoaded({
    required this.favoriteIds,
    required this.favorites,
  });

  @override
  List<Object> get props => [favoriteIds, favorites];
}

class FavoritesError extends FavoritesState {
  final String message;

  const FavoritesError(this.message);

  @override
  List<Object> get props => [message];
}

// Bloc
class FavoritesBloc extends Bloc<FavoritesEvent, FavoritesState> {
  final FavoritesService _favoritesService;

  FavoritesBloc({required FavoritesService favoritesService})
      : _favoritesService = favoritesService,
        super(const FavoritesInitial()) {
    on<LoadFavorites>(_onLoadFavorites);
    on<AddFavorite>(_onAddFavorite);
    on<RemoveFavorite>(_onRemoveFavorite);
    on<GetFavoritePharmacies>(_onGetFavoritePharmacies);
  }

  Future<void> _onLoadFavorites(
    LoadFavorites event,
    Emitter<FavoritesState> emit,
  ) async {
    try {
      final favorites = await _favoritesService.getFavorites();
      emit(FavoritesLoaded(
        favoriteIds: favorites,
        favorites: [],
      ));
    } catch (e) {
      emit(FavoritesError('Failed to load favorites: $e'));
    }
  }

  Future<void> _onAddFavorite(
    AddFavorite event,
    Emitter<FavoritesState> emit,
  ) async {
    try {
      await _favoritesService.addFavorite(event.pharmacyId);
      final favorites = await _favoritesService.getFavorites();
      emit(FavoritesLoaded(
        favoriteIds: favorites,
        favorites: state is FavoritesLoaded
            ? (state as FavoritesLoaded).favorites
            : [],
      ));
    } catch (e) {
      emit(FavoritesError('Failed to add favorite: $e'));
    }
  }

  Future<void> _onRemoveFavorite(
    RemoveFavorite event,
    Emitter<FavoritesState> emit,
  ) async {
    try {
      await _favoritesService.removeFavorite(event.pharmacyId);
      final favorites = await _favoritesService.getFavorites();
      emit(FavoritesLoaded(
        favoriteIds: favorites,
        favorites: state is FavoritesLoaded
            ? (state as FavoritesLoaded).favorites
            : [],
      ));
    } catch (e) {
      emit(FavoritesError('Failed to remove favorite: $e'));
    }
  }

  Future<void> _onGetFavoritePharmacies(
    GetFavoritePharmacies event,
    Emitter<FavoritesState> emit,
  ) async {
    try {
      final favoriteIds = await _favoritesService.getFavorites();
      final favorites = event.allPharmacies
          .where((p) => favoriteIds.contains(p.id))
          .toList();

      emit(FavoritesLoaded(
        favoriteIds: favoriteIds,
        favorites: favorites,
      ));
    } catch (e) {
      emit(FavoritesError('Failed to get favorite pharmacies: $e'));
    }
  }
}
