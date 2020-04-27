import 'package:flutter/foundation.dart';
import 'package:woocommerceadmin/src/orders/models/order_note.dart';

class OrderNoteProvider with ChangeNotifier {
  OrderNote _orderNote;

  OrderNoteProvider(OrderNote orderNote) {
    this._orderNote = orderNote;
  }

  OrderNote get orderNote => _orderNote;

  void replaceOrderNotes(OrderNote orderNotes) {
    _orderNote = orderNotes;
    notifyListeners();
  }
}
