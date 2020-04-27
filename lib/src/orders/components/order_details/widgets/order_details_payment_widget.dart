import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:woocommerceadmin/src/orders/models/order.dart';
import 'package:woocommerceadmin/src/orders/providers/order_provider.dart';

class OrderDetailsPaymentWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final OrderProvider orderProvider = Provider.of<OrderProvider>(context);
    final Order orderData = orderProvider.order;
    Widget orderPaymentWidget = SizedBox.shrink();
    List<Widget> orderPaymentWidgetData = [];

    if (orderData?.paymentMethodTitle is String &&
        orderData.paymentMethodTitle.isNotEmpty) {
      orderPaymentWidgetData
          .add(Text("Payment Gateway: ${orderData.paymentMethodTitle}"));
    }

    if (orderData?.total is String && orderData.total.isNotEmpty) {
      orderPaymentWidgetData.add(
        Text(
          "Order Total: ${orderData.total}",
          style: Theme.of(context)
              .textTheme
              .body1
              .copyWith(fontWeight: FontWeight.bold),
        ),
      );
    }

    if (orderData?.totalTax is String && orderData.totalTax.isNotEmpty) {
      orderPaymentWidgetData.add(Text("Taxes: ${orderData.totalTax}"));
    }

    if (orderPaymentWidgetData.isNotEmpty) {
      orderPaymentWidget = ExpansionTile(
        title: Text(
          "Payment",
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
                      children: orderPaymentWidgetData),
                ),
              ),
            ],
          )
        ],
      );
    }
    return orderPaymentWidget;
  }
}
