import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:recase/recase.dart';
import 'package:woocommerceadmin/src/orders/components/order_details/screens/order_details_screen.dart';
import 'package:woocommerceadmin/src/orders/components/orders_list/widgets/orders_list_item_widget.dart';
import 'package:woocommerceadmin/src/orders/models/order.dart';
import 'package:woocommerceadmin/src/orders/models/orders.dart';

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
    return Consumer<Orders>(
      builder: (context, ordersListData, _) {
        return ListView.builder(
          itemCount: ordersListData.orders.length,
          itemBuilder: (BuildContext context, int index) {
            return OrdersListItemWidget(
              baseurl: baseurl,
              username: username,
              password: password,
              orderData: ordersListData.orders[index],
            );
          },
        );
      },
    );
  }
}
