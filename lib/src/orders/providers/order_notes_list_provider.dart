import 'package:flutter/foundation.dart';
import 'package:woocommerceadmin/src/orders/providers/order_note_provider.dart';

class OrderNoteProvidersList with ChangeNotifier{
  List<OrderNoteProvider> _orderNoteProviders = [];

  List<OrderNoteProvider> get orderNoteProvider => _orderNoteProviders;

  OrderNoteProvider getOrderNoteProviderById(int id) {
    return _orderNoteProviders.firstWhere((item) => item.orderNote.id == id);
  }

  int getOrderNoteProviderIndexById(int id) {
    return _orderNoteProviders.indexWhere((item) => item.orderNote.id == id);
  }

  void clearOrderNoteProvidersList(){
    _orderNoteProviders = [];
    notifyListeners();
  }

  void addOrderNoteProviders(List<OrderNoteProvider> orderNoteProviders) {
    _orderNoteProviders.addAll(orderNoteProviders);
    notifyListeners();
  }

  void insertOrderNoteProviderAtTop(OrderNoteProvider orderNoteProvider){
    _orderNoteProviders.insert(0, orderNoteProvider);
    notifyListeners();
  }

  void deleteOrderNoteProvider(int id){
    _orderNoteProviders.removeWhere((item) => item.orderNote.id == id);
    notifyListeners();
  }
}