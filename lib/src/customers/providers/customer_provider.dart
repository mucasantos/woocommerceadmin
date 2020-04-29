import 'package:flutter/foundation.dart';
import 'package:woocommerceadmin/src/customers/models/customer.dart';

class CustomerProvider with ChangeNotifier {
  Customer _customer;

  CustomerProvider(Customer customer) {
    this._customer = customer;
    notifyListeners();
  }

  Customer get customer => _customer;

  void replaceCustomer(Customer customer) {
    _customer = customer;
    notifyListeners();
  }
}
