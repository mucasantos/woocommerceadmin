import 'package:flutter/foundation.dart';
import 'package:woocommerceadmin/src/products/providers/product_provider.dart';

class ProductsListProvider with ChangeNotifier {
  List<ProductProvider> _productProviders = [];

  List<ProductProvider> get productProviders => _productProviders;

  ProductProvider getProductById(int id) {
    return _productProviders.firstWhere((item) => item.product.id == id);
  }

  int getProductIndexById(int id) {
    final productProviderIndex =
        _productProviders.indexWhere((item) => item.product.id == id);
    return productProviderIndex;
  }

  void addProducts(List<ProductProvider> productProviders) {
    _productProviders.addAll(productProviders);
    notifyListeners();
  }

  void clearProductProvidersList() {
    _productProviders = [];
    notifyListeners();
  }

  void replaceProductProviderById(int id, ProductProvider productProvider) {
    int productIndex = getProductIndexById(id);
    if (productIndex >= 0) {
      _productProviders[productIndex] = productProvider;
      notifyListeners();
    }
  }
}
