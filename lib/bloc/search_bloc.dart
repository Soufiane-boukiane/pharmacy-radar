import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../models/pharmacy.dart';

// Events
abstract class SearchEvent extends Equatable {
  const SearchEvent();

  @override
  List<Object> get props => [];
}

class SearchPharmacies extends SearchEvent {
  final String query;
  final List<Pharmacy> allPharmacies;

  const SearchPharmacies(this.query, this.allPharmacies);

  @override
  List<Object> get props => [query, allPharmacies];
}

class FilterByStatus extends SearchEvent {
  final String status;
  final List<Pharmacy> allPharmacies;

  const FilterByStatus(this.status, this.allPharmacies);

  @override
  List<Object> get props => [status, allPharmacies];
}

class ClearFilters extends SearchEvent {
  final List<Pharmacy> allPharmacies;

  const ClearFilters(this.allPharmacies);

  @override
  List<Object> get props => [allPharmacies];
}

class SortPharmacies extends SearchEvent {
  final String sortBy;
  final List<Pharmacy> allPharmacies;

  const SortPharmacies(this.sortBy, this.allPharmacies);

  @override
  List<Object> get props => [sortBy, allPharmacies];
}

// States
abstract class SearchState extends Equatable {
  const SearchState();

  @override
  List<Object> get props => [];
}

class SearchInitial extends SearchState {
  const SearchInitial();
}

class SearchLoaded extends SearchState {
  final List<Pharmacy> results;
  final String query;
  final String status;
  final String sortBy;

  const SearchLoaded({
    required this.results,
    this.query = '',
    this.status = 'all',
    this.sortBy = 'name',
  });

  @override
  List<Object> get props => [results, query, status, sortBy];
}

class SearchError extends SearchState {
  final String message;

  const SearchError(this.message);

  @override
  List<Object> get props => [message];
}

// Bloc
class SearchBloc extends Bloc<SearchEvent, SearchState> {
  SearchBloc() : super(const SearchInitial()) {
    on<SearchPharmacies>(_onSearchPharmacies);
    on<FilterByStatus>(_onFilterByStatus);
    on<ClearFilters>(_onClearFilters);
    on<SortPharmacies>(_onSortPharmacies);
  }

  Future<void> _onSearchPharmacies(
    SearchPharmacies event,
    Emitter<SearchState> emit,
  ) async {
    try {
      final query = event.query.toLowerCase();
      final filtered = event.allPharmacies.where((pharmacy) {
        return pharmacy.name.toLowerCase().contains(query) ||
            pharmacy.address.toLowerCase().contains(query);
      }).toList();

      emit(SearchLoaded(
        results: filtered,
        query: event.query,
        status: state is SearchLoaded ? (state as SearchLoaded).status : 'all',
        sortBy: state is SearchLoaded ? (state as SearchLoaded).sortBy : 'name',
      ));
    } catch (e) {
      emit(SearchError('Search failed: $e'));
    }
  }

  Future<void> _onFilterByStatus(
    FilterByStatus event,
    Emitter<SearchState> emit,
  ) async {
    try {
      List<Pharmacy> filtered = event.allPharmacies;

      if (event.status == 'open') {
        filtered = filtered.where((p) => p.isOpen).toList();
      } else if (event.status == 'closed') {
        filtered = filtered.where((p) => !p.isOpen).toList();
      } else if (event.status == 'duty') {
        filtered = filtered.where((p) => p.isDuty).toList();
      }

      emit(SearchLoaded(
        results: filtered,
        query: state is SearchLoaded ? (state as SearchLoaded).query : '',
        status: event.status,
        sortBy: state is SearchLoaded ? (state as SearchLoaded).sortBy : 'name',
      ));
    } catch (e) {
      emit(SearchError('Filter failed: $e'));
    }
  }

  Future<void> _onClearFilters(
    ClearFilters event,
    Emitter<SearchState> emit,
  ) async {
    try {
      emit(SearchLoaded(
        results: event.allPharmacies,
        query: '',
        status: 'all',
        sortBy: 'name',
      ));
    } catch (e) {
      emit(SearchError('Clear filters failed: $e'));
    }
  }

  Future<void> _onSortPharmacies(
    SortPharmacies event,
    Emitter<SearchState> emit,
  ) async {
    try {
      final results = List<Pharmacy>.from(event.allPharmacies);

      if (event.sortBy == 'name') {
        results.sort((a, b) => a.name.compareTo(b.name));
      } else if (event.sortBy == 'rating') {
        results.sort((a, b) => (b.rating ?? 0).compareTo(a.rating ?? 0));
      }

      emit(SearchLoaded(
        results: results,
        query: state is SearchLoaded ? (state as SearchLoaded).query : '',
        status: state is SearchLoaded ? (state as SearchLoaded).status : 'all',
        sortBy: event.sortBy,
      ));
    } catch (e) {
      emit(SearchError('Sort failed: $e'));
    }
  }
}
