import 'package:flutter/foundation.dart';

class OrdersListFiltersProvider with ChangeNotifier {
  bool _isSearching = false;
  String _searchValue = "";

  String _sortOrderByValue = "date";
  String _sortOrderValue = "desc";
  Map<String, bool> _orderStatusOptions = {};

  bool get isSearching => _isSearching;
  String get searchValue => _searchValue;

  String get sortOrderByValue => _sortOrderByValue;
  String get sortOrderValue => _sortOrderValue;
  Map<String, bool> get orderStatusOptions => _orderStatusOptions;

  void toggleIsSearching() {
    _isSearching = !_isSearching;
    notifyListeners();
  }

  void changeSearchValue(String searchValue) {
    _searchValue = searchValue;
    notifyListeners();
  }

  void changeFilterModalValues({
    @required String sortOrderByValue,
    @required String sortOrderValue,
    @required Map<String, bool> orderStatusOptions,
  }) {
    _sortOrderByValue = sortOrderByValue;
    _sortOrderValue = sortOrderValue;
    _orderStatusOptions = orderStatusOptions;
    notifyListeners();
  }
}
