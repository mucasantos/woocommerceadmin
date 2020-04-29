import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:woocommerceadmin/src/customers/components/customers_list/widgets/customers_list_item_widget.dart';
import 'package:woocommerceadmin/src/customers/providers/customer_providers_list.dart';

class CustomerListWidget extends StatelessWidget {
  final String baseurl;
  final String username;
  final String password;

  CustomerListWidget({
    @required this.baseurl,
    @required this.username,
    @required this.password,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<CustomerProvidersList>(
      builder: (context, customersListProvider, _) {
        return ListView.builder(
          itemCount: customersListProvider.customerProviders.length,
          itemBuilder: (BuildContext context, int index) {
            return CustomersListItemWidget(
              baseurl: baseurl,
              username: username,
              password: password,
              customerProvider: customersListProvider.customerProviders[index],
            );
          },
        );
      },
    );
  }
}
