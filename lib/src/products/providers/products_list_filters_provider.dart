import 'package:flutter/foundation.dart';

class ProductsListFiltersProvider with ChangeNotifier {
  bool _isSearching = false;
  String _searchValue = "";

  String _sortOrderByValue = "date";
  String _sortOrderValue = "desc";
  String _statusFilterValue = "any";
  String _stockStatusFilterValue = "all";
  bool _featuredFilterValue = false;
  bool _onSaleFilterValue = false;
  String _minPriceFilterValue = "";
  String _maxPriceFilterValue = "";
  DateTime _fromDateFilterValue;
  DateTime _toDateFilterValue;

  bool get isSearching => _isSearching;
  String get searchValue => _searchValue;

  String get sortOrderByValue => _sortOrderByValue;
  String get sortOrderValue => _sortOrderValue;
  String get statusFilterValue => _statusFilterValue;
  String get stockStatusFilterValue => _stockStatusFilterValue;
  bool get featuredFilterValue => _featuredFilterValue;
  bool get onSaleFilterValue => _onSaleFilterValue;
  String get minPriceFilterValue => _minPriceFilterValue;
  String get maxPriceFilterValue => _maxPriceFilterValue;
  DateTime get fromDateFilterValue => _fromDateFilterValue;
  DateTime get toDateFilterValue => _toDateFilterValue;

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
    @required String statusFilterValue,
    @required String stockStatusFilterValue,
    @required bool featuredFilterValue,
    @required bool onSaleFilterValue,
    @required String minPriceFilterValue,
    @required String maxPriceFilterValue,
    @required DateTime fromDateFilterValue,
    @required DateTime toDateFilterValue,
  }) {
    _sortOrderByValue = sortOrderByValue;
    _sortOrderValue = sortOrderValue;
    _statusFilterValue = statusFilterValue;
    _stockStatusFilterValue = stockStatusFilterValue;
    _featuredFilterValue = featuredFilterValue;
    _onSaleFilterValue = onSaleFilterValue;
    _minPriceFilterValue = minPriceFilterValue;
    _maxPriceFilterValue = maxPriceFilterValue;
    _fromDateFilterValue = fromDateFilterValue;
    _toDateFilterValue = toDateFilterValue;
    notifyListeners();
  }
}
