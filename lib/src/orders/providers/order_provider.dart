import 'package:flutter/foundation.dart';
import 'package:woocommerceadmin/src/orders/models/order.dart';

class OrderProvider with ChangeNotifier {
  Order _order;

  OrderProvider(Order order) {
    this._order = order;
    notifyListeners();
  }

  Order get order => _order;

  void replaceOrder(Order order) {
    _order = order;
    notifyListeners();
  }
}
