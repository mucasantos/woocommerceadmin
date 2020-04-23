import 'package:flutter/foundation.dart';
import 'package:woocommerceadmin/src/products/models/product.dart';

class ProductProvider with ChangeNotifier{
  Product _product;

  ProductProvider(Product product){
    this._product = product;
    notifyListeners();
  }

  Product get product => _product;

  void set product(Product product){
    this._product = product;
    notifyListeners();
  }

    void replaceProduct(Product product) {
    _product = product;
    notifyListeners();
  }
}