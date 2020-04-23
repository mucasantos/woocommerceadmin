import 'package:flutter/foundation.dart';
import 'package:woocommerceadmin/src/orders/models/order.dart';

class OrdersListProvider with ChangeNotifier {
  List<Order> _orders = [];

  List<Order> get orders => [..._orders];

  Order getOrderById(int id) {
    return _orders.firstWhere((item) => item.id == id);
  }

  int getOrderIndexById(int id) {
    final orderIndex = _orders.indexWhere((item) => item.id == id);
    return orderIndex;
  }

  void addOrders(List<Order> orders) {
    _orders.addAll(orders);
    notifyListeners();
  }

  void clearOrdersList() {
    _orders = [];
    notifyListeners();
  }

  void replaceOrderById(int id, Order order) {
    int orderIndex = getOrderIndexById(id);
    _orders[orderIndex] = order;
    notifyListeners();
  }
}
