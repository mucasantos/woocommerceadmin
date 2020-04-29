import 'package:flutter/foundation.dart';
import 'package:woocommerceadmin/src/customers/providers/customer_provider.dart';

class CustomerProvidersList with ChangeNotifier {
  List<CustomerProvider> _customerProviders = [];

  List<CustomerProvider> get customerProviders => _customerProviders;

  CustomerProvider getCusomerProviderById(int id) {
    return _customerProviders.firstWhere((item) => item.customer.id == id);
  }

  int getCustomerProviderIndexById(int id) {
    return _customerProviders.indexWhere((item) => item.customer.id == id);
  }

  void addCustomerProviders(List<CustomerProvider> customerProviders) {
    _customerProviders.addAll(customerProviders);
    notifyListeners();
  }

  void clearCustomerProvidersList() {
    _customerProviders = [];
    notifyListeners();
  }

  void replaceCustomerProviderById(int id, CustomerProvider customerProvider) {
    int customerIndex = getCustomerProviderIndexById(id);
    _customerProviders[customerIndex] = customerProvider;
    notifyListeners();
  }
}
