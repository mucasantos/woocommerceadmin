import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:woocommerceadmin/src/orders/models/order.dart';
import 'package:woocommerceadmin/src/orders/providers/order_provider.dart';

class OrderDetailsShippingWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final OrderProvider orderProvider = Provider.of<OrderProvider>(context);
    final Order orderData = orderProvider.order;

    Widget orderShippingWidget = SizedBox.shrink();
    List<Widget> orderShippingData = [];
    String shippingName = "";
    String shippingAddress = "";

    if (orderData?.shipping?.firstName is String &&
        orderData.shipping.firstName.isNotEmpty) {
      shippingName += orderData.shipping.firstName;
    }
    if (orderData?.shipping?.lastName is String &&
        orderData.shipping.lastName.isNotEmpty) {
      shippingName += " ${orderData.shipping.lastName}";
    }
    if (shippingName.isNotEmpty) {
      orderShippingData.add(Text(
        shippingName,
        style: Theme.of(context)
            .textTheme
            .body1
            .copyWith(fontWeight: FontWeight.bold),
      ));
    }

    if (orderData?.shipping?.address1 is String &&
        orderData.shipping.address1.isNotEmpty) {
      shippingAddress = orderData.shipping.address1;
    }

    if (orderData?.shipping?.address2 is String &&
        orderData.shipping.address2.isNotEmpty) {
      shippingAddress += " ${orderData.shipping.address2}";
    }

    if (orderData?.shipping?.city is String &&
        orderData.shipping.city.isNotEmpty) {
      shippingAddress += " ${orderData.shipping.city}";
    }

    if (orderData?.shipping?.state is String &&
        orderData.shipping.state.isNotEmpty) {
      shippingAddress += " ${orderData.shipping.state}";
    }

    if (orderData?.shipping?.postcode is String &&
        orderData.shipping.postcode.isNotEmpty) {
      shippingAddress += " ${orderData.shipping.postcode}";
    }

    if (orderData?.shipping?.city is String &&
        orderData.shipping.city.isNotEmpty) {
      shippingAddress += " ${orderData.shipping.city}";
    }

    if (shippingAddress.isNotEmpty) {
      orderShippingData.add(GestureDetector(
        child: Text("Address: $shippingAddress"),
        onLongPress: () {
          Clipboard.setData(ClipboardData(text: shippingAddress));
          Scaffold.of(context).showSnackBar(SnackBar(
            content: Text("Shipping Address Copied..."),
            duration: Duration(seconds: 1),
          ));
        },
      ));
    }

    if (orderShippingData.isNotEmpty) {
      orderShippingWidget = ExpansionTile(
        title: Text(
          "Shipping",
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
                      children: orderShippingData),
                ),
              ),
            ],
          )
        ],
      );
    }
    return orderShippingWidget;
  }
}
