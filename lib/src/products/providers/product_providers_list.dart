import 'package:flutter/foundation.dart';
import 'package:woocommerceadmin/src/products/providers/product_provider.dart';

class ProductProvidersList with ChangeNotifier {
  List<ProductProvider> _productProviders = [];

  List<ProductProvider> get productProviders => _productProviders;

  ProductProvider getProductProviderById(int id) {
    return _productProviders.firstWhere((item) => item.product.id == id);
  }

  int getProductProviderIndexById(int id) {
    return _productProviders.indexWhere((item) => item.product.id == id);
  }

  void addProductProviders(List<ProductProvider> productProviders) {
    _productProviders.addAll(productProviders);
    notifyListeners();
  }

  void clearProductProvidersList() {
    _productProviders = [];
    notifyListeners();
  }

  void replaceProductProviderById(int id, ProductProvider productProvider) {
    int productIndex = getProductProviderIndexById(id);
    if (productIndex >= 0) {
      _productProviders[productIndex] = productProvider;
      notifyListeners();
    }
  }
}
