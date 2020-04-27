import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:woocommerceadmin/src/orders/components/orders_list/widgets/orders_list_item_widget.dart';
import 'package:woocommerceadmin/src/orders/providers/order_providers_list.dart';

class OrdersListWidget extends StatelessWidget {
  final String baseurl;
  final String username;
  final String password;

  OrdersListWidget({
    @required this.baseurl,
    @required this.username,
    @required this.password,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<OrderProvidersList>(
      builder: (context, ordersListProvider, _) {
        return ListView.builder(
          itemCount: ordersListProvider.orderProviders.length,
          itemBuilder: (BuildContext context, int index) {
            return OrdersListItemWidget(
              baseurl: baseurl,
              username: username,
              password: password,
              orderProvider: ordersListProvider.orderProviders[index],
            );
          },
        );
      },
    );
  }
}
