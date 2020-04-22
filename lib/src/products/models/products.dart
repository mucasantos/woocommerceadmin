import 'package:flutter/foundation.dart';
import 'package:woocommerceadmin/src/products/models/product.dart';

class Products with ChangeNotifier {
  List<Product> _products = [];

  List<Product> get products => [..._products];

  Product getProductById(int id) {
    return _products.firstWhere((item) => item.id == id);
  }

  int getProductIndexById(int id) {
    final productIndex = _products.indexWhere((item) => item.id == id);
    return productIndex;
  }

  void addProducts(List<Product> products) {
    _products.addAll(products);
    notifyListeners();
  }

  void clearProductsList() {
    _products = [];
    notifyListeners();
  }

  void replaceProductById(int id, Product productData) {
    int productIndex = getProductIndexById(id);
    _products[productIndex] = productData;
    notifyListeners();
  }
}
