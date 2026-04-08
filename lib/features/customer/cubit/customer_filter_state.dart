// features/customer/cubit/customer_filter_state.dart
class CustomerFilterState {
  final String viewType;
  final String capacity;
  final bool showAvailableOnly;
  final double? minPrice;
  final double? maxPrice;
  final String searchQuery;

  CustomerFilterState({
    this.viewType = 'All',
    this.capacity = 'All',
    this.showAvailableOnly = true,
    this.minPrice,
    this.maxPrice,
    this.searchQuery = '',
  });

  CustomerFilterState copyWith({
    String? viewType,
    String? capacity,
    bool? showAvailableOnly,
    double? minPrice,
    double? maxPrice,
    String? searchQuery,
    bool clearMinPrice = false,
    bool clearMaxPrice = false,
  }) {
    return CustomerFilterState(
      viewType: viewType ?? this.viewType,
      capacity: capacity ?? this.capacity,
      showAvailableOnly: showAvailableOnly ?? this.showAvailableOnly,
      minPrice: clearMinPrice ? null : (minPrice ?? this.minPrice),
      maxPrice: clearMaxPrice ? null : (maxPrice ?? this.maxPrice),
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  bool get hasActiveFilters =>
      viewType != 'All' ||
      capacity != 'All' ||
      !showAvailableOnly ||
      minPrice != null ||
      maxPrice != null ||
      searchQuery.isNotEmpty;
}
