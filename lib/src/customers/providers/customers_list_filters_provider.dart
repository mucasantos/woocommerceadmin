import 'package:flutter/foundation.dart';

class CustomersListFiltersProvider with ChangeNotifier {
  bool _isSearching = false;
  String _searchValue = "";

  String _sortOrderByValue = "registered_date";
  String _sortOrderValue = "desc";
  String _roleFilterValue = "customer";

  bool get isSearching => _isSearching;
  String get searchValue => _searchValue;

  String get sortOrderByValue => _sortOrderByValue;
  String get sortOrderValue => _sortOrderValue;
  String get roleFilterValue => _roleFilterValue;

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
    @required String roleFilterValue,
  }) {
    _sortOrderByValue = sortOrderByValue;
    _sortOrderValue = sortOrderValue;
    _roleFilterValue = roleFilterValue;
    notifyListeners();
  }
}
