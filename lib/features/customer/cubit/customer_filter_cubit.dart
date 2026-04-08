// features/customer/cubit/customer_filter_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'customer_filter_state.dart';

class CustomerFilterCubit extends Cubit<CustomerFilterState> {
  CustomerFilterCubit() : super(CustomerFilterState());

  void setViewType(String viewType) {
    emit(state.copyWith(viewType: viewType));
  }

  void setCapacity(String capacity) {
    emit(state.copyWith(capacity: capacity));
  }

  void toggleAvailableOnly(bool showAvailableOnly) {
    emit(state.copyWith(showAvailableOnly: showAvailableOnly));
  }

  void setPriceRange(double? minPrice, double? maxPrice) {
    emit(state.copyWith(
      minPrice: minPrice,
      maxPrice: maxPrice,
      clearMinPrice: minPrice == null,
      clearMaxPrice: maxPrice == null,
    ));
  }

  void setSearchQuery(String query) {
    emit(state.copyWith(searchQuery: query));
  }

  void updateFilters(Map<String, dynamic> filters) {
    emit(state.copyWith(
      viewType: filters['viewType'],
      capacity: filters['capacity'],
      showAvailableOnly: filters['showAvailableOnly'],
      minPrice: filters['minPrice'],
      maxPrice: filters['maxPrice'],
      searchQuery: filters['searchQuery'],
      clearMinPrice: filters['minPrice'] == null,
      clearMaxPrice: filters['maxPrice'] == null,
    ));
  }

  void resetFilters() {
    emit(CustomerFilterState(searchQuery: state.searchQuery));
  }

  void clearAll() {
    emit(CustomerFilterState());
  }
}
