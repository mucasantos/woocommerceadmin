import 'package:flutter/foundation.dart';
import 'package:woocommerceadmin/src/orders/providers/order_provider.dart';

class OrderProvidersList with ChangeNotifier {
  List<OrderProvider> _orderProviders = [];

  List<OrderProvider> get orderProviders => _orderProviders;

  OrderProvider getOrderProviderById(int id) {
    return _orderProviders.firstWhere((item) => item.order.id == id);
  }

  int getOrderProviderIndexById(int id) {
    return _orderProviders.indexWhere((item) => item.order.id == id);
  }

  void addOrderProviders(List<OrderProvider> orderProviders) {
    _orderProviders.addAll(orderProviders);
    notifyListeners();
  }

  void clearOrderProvidersList() {
    _orderProviders = [];
    notifyListeners();
  }

  void replaceOrderProviderById(int id, OrderProvider orderProvider) {
    int orderIndex = getOrderProviderIndexById(id);
    _orderProviders[orderIndex] = orderProvider;
    notifyListeners();
  }
}
