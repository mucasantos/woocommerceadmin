import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:woocommerceadmin/src/products/models/product.dart';
import 'package:http/http.dart' as http;

class Products with ChangeNotifier {
  int _page = 1;
  bool _hasMoreToLoad = true;
  bool _isListLoading = false;
  bool _isListError = false;
  String _listError;
  List<Product> _products = [];

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

  bool get hasMoreToLoad => _hasMoreToLoad;
  bool get isListLoading => _isListLoading;
  bool get isListError => _isListError;
  String get listError => _listError;

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

  List<Product> get products => _products;

  Product findProductById(int id) {
    return _products.firstWhere((item) => item.id == id);
  }

  int getProductIndexById(int id) {
    final productIndex = _products.indexWhere((product) => product.id == id);
    return productIndex;
  }

  void addProducts(List<Product> products) {
    _products.addAll(products);
    notifyListeners();
  }

  void replaceProductById(int id, Product productData) {
    int productIndex = getProductIndexById(id);
    _products[productIndex] = productData;
    notifyListeners();
  }

  Future<void> handleLoadMore({
    @required String baseurl,
    @required String username,
    @required String password,
  }) async {
    _page++;
    await fetchProductsList(
      baseurl: baseurl,
      username: username,
      password: password,
    );
  }

  Future<void> handleRefresh({
    @required String baseurl,
    @required String username,
    @required String password,
  }) async {
    _page = 1;
    _products = [];
    fetchProductsList(
      baseurl: baseurl,
      username: username,
      password: password,
    );
  }

  Future<void> fetchProductsList({
    @required String baseurl,
    @required String username,
    @required String password,
    int perPage = 25,
  }) async {
    String url =
        "$baseurl/wp-json/wc/v3/products?page=$_page&per_page=$perPage&consumer_key=$username&consumer_secret=$password";

    if (_searchValue is String && _searchValue.isNotEmpty) {
      url += "&search=$_searchValue";
    }
    if (_sortOrderByValue is String && _sortOrderByValue.isNotEmpty) {
      url += "&orderby=$_sortOrderByValue";
    }
    if (_sortOrderValue is String && _sortOrderValue.isNotEmpty) {
      url += "&order=$_sortOrderValue";
    }
    if (_statusFilterValue is String && _statusFilterValue.isNotEmpty) {
      url += "&status=$_statusFilterValue";
    }
    if (_stockStatusFilterValue is String &&
        _stockStatusFilterValue.isNotEmpty) {
      if (_stockStatusFilterValue == "instock" ||
          _stockStatusFilterValue == "outofstock" ||
          _stockStatusFilterValue == "onbackorder")
        url += "&stock_status=$_stockStatusFilterValue";
    }
    if (_featuredFilterValue is bool && _featuredFilterValue) {
      url += "&featured=$_featuredFilterValue";
    }
    if (_onSaleFilterValue is bool && _onSaleFilterValue) {
      url += "&on_sale=$_onSaleFilterValue";
    }
    if (_minPriceFilterValue is String && _minPriceFilterValue.isNotEmpty) {
      url += "&min_price=$_minPriceFilterValue";
    }
    if (_maxPriceFilterValue is String && _maxPriceFilterValue.isNotEmpty) {
      url += "&max_price=_maxPriceFilterValue";
    }
    if (_fromDateFilterValue is DateTime) {
      url += "&after=" + DateFormat("yyyy-MM-dd").format(_fromDateFilterValue);
    }
    if (_toDateFilterValue is DateTime) {
      url += "&before=" + DateFormat("yyyy-MM-dd").format(_toDateFilterValue);
    }
    _isListLoading = true;
    _isListError = false;
    notifyListeners();
    http.Response response;
    try {
      response = await http.get(url);
      if (response.statusCode == 200) {
        dynamic responseBody = json.decode(response.body);
        if (responseBody is List) {
          if (responseBody.isNotEmpty) {
            _hasMoreToLoad = true;
            _isListLoading = false;
            _isListError = false;
            final List<Product> loadedProducts = [];
            responseBody.forEach((item) {
              loadedProducts.add(Product.fromJson(item));
            });
            _products.addAll(loadedProducts);
            notifyListeners();
          } else {
            _hasMoreToLoad = false;
            _isListLoading = false;
            _isListError = false;
            notifyListeners();
          }
        } else {
          _hasMoreToLoad = true;
          _isListLoading = false;
          _isListError = true;
          _listError = "Failed to fetch products";
          notifyListeners();
        }
      } else {
        String errorCode = "";
        dynamic responseBody = json.decode(response.body);
        if (responseBody is Map &&
            responseBody.containsKey("code") &&
            responseBody["code"] is String) {
          errorCode = responseBody["code"];
        }
        _hasMoreToLoad = true;
        _isListLoading = false;
        _isListError = true;
        _listError = "Failed to fetch products. Error: $errorCode";
        notifyListeners();
      }
    } on SocketException catch (_) {
      _hasMoreToLoad = true;
      _isListLoading = false;
      _isListError = true;
      _listError = "Failed to fetch products. Error: Network not reachable";
      notifyListeners();
    } catch (e) {
      _hasMoreToLoad = true;
      _isListLoading = false;
      _isListError = true;
      _listError = "Failed to fetch products. Error: $e";
      notifyListeners();
    }
  }

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
