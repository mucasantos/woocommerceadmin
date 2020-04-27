import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:recase/recase.dart';
import 'package:woocommerceadmin/src/orders/components/order_details/widgets/change_order_status_modal.dart';
import 'package:woocommerceadmin/src/orders/models/order.dart';
import 'package:woocommerceadmin/src/orders/providers/order_provider.dart';

class OrderDetailsGeneralWidget extends StatelessWidget {
  final String baseurl;
  final String username;
  final String password;
  final int orderId;
  final GlobalKey<ScaffoldState> scaffoldKey;

  OrderDetailsGeneralWidget({
    @required this.baseurl,
    @required this.username,
    @required this.password,
    @required this.orderId,
    @required this.scaffoldKey,
  });

  @override
  Widget build(BuildContext context) {
    final OrderProvider orderProvider = Provider.of<OrderProvider>(context);
    final Order orderData = orderProvider.order;
    Widget orderGeneralWidget = SizedBox.shrink();
    List<Widget> orderGeneralWidgetData = [];
    if (orderData?.id is int) {
      orderGeneralWidgetData.add(Text("Order ID: ${orderData.id}"));
    }

    if (orderData?.dateCreated is DateTime) {
      orderGeneralWidgetData.add(Text(
        "Created: " +
            DateFormat("EEEE, d/M/y h:mm:ss a").format(orderData.dateCreated),
      ));
    }

    if (orderData?.status is String) {
      orderGeneralWidgetData.add(
        Row(
          children: <Widget>[
            Text("Order Status: " + orderData.status.titleCase),
            SizedBox(
              width: 20,
            ),
            GestureDetector(
              child: Icon(
                Icons.edit,
                color: Theme.of(context).primaryColor,
              ),
              onTap: () async {
                return showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (BuildContext context) {
                    return ChangeNotifierProvider.value(
                      value: orderProvider,
                      child: ChangeOrderStatusModal(
                        baseurl: baseurl,
                        username: username,
                        password: password,
                        orderId: orderId,
                        scaffoldKey: scaffoldKey,
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      );
    }

    if (orderGeneralWidgetData.isNotEmpty) {
      orderGeneralWidget = ExpansionTile(
        title: Text(
          "General",
          style: Theme.of(context).textTheme.subhead,
        ),
        initiallyExpanded: true,
        children: <Widget>[
          Row(
            children: <Widget>[
              Flexible(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20.0, 0, 20.0, 10.0),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: orderGeneralWidgetData),
                ),
              ),
            ],
          )
        ],
      );
    }
    return orderGeneralWidget;
  }
}
