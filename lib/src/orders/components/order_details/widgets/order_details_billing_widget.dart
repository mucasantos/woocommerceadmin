import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:woocommerceadmin/src/orders/models/order.dart';
import 'package:woocommerceadmin/src/orders/providers/order_provider.dart';

class OrderDetailsBillingWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final OrderProvider orderProvider = Provider.of<OrderProvider>(context);
    final Order orderData = orderProvider.order;

    Widget orderBillingWidget = SizedBox.shrink();
    List<Widget> orderBillingWidgetData = [];
    String billingName = "";
    String billingAddress = "";

    if (orderData?.billing?.firstName is String &&
        orderData.billing.firstName.isNotEmpty) {
      billingName += orderData.billing.firstName;
    }
    if (orderData?.billing?.lastName is String &&
        orderData.billing.lastName.isNotEmpty) {
      billingName += " ${orderData.billing.lastName}";
    }
    if (billingName.isNotEmpty) {
      orderBillingWidgetData.add(Text(
        billingName,
        style: Theme.of(context)
            .textTheme
            .body1
            .copyWith(fontWeight: FontWeight.bold),
      ));
    }

    if (orderData?.billing?.phone is String &&
        orderData.billing.phone.isNotEmpty) {
      orderBillingWidgetData.add(
        Text.rich(
          TextSpan(
            text: "Phone: ",
            style: Theme.of(context).textTheme.body1,
            children: [
              TextSpan(
                text: orderData.billing.phone,
                style: TextStyle(color: Colors.blue),
                recognizer: TapGestureRecognizer()
                  ..onTap = () {
                    launch("tel:${orderData.billing.phone}");
                  },
              )
            ],
          ),
        ),
      );
    }

    if (orderData.billing.email is String &&
        orderData.billing.email.isNotEmpty) {
      orderBillingWidgetData.add(
        Text.rich(
          TextSpan(
            text: "Email: ",
            style: Theme.of(context).textTheme.body1,
            children: [
              TextSpan(
                text: orderData.billing.email,
                style: TextStyle(color: Colors.blue),
                recognizer: TapGestureRecognizer()
                  ..onTap = () {
                    launch("mailto:${orderData.billing.email}");
                  },
              )
            ],
          ),
        ),
      );
    }

    if (orderData?.billing?.address1 is String &&
        orderData.billing.address1.isNotEmpty) {
      billingAddress = orderData.billing.address1;
    }

    if (orderData?.billing?.address2 is String &&
        orderData.billing.address2.isNotEmpty) {
      billingAddress += " ${orderData.billing.address2}";
    }

    if (orderData?.billing?.city is String &&
        orderData.billing.city.isNotEmpty) {
      billingAddress += " ${orderData.billing.city}";
    }

    if (orderData?.billing?.state is String &&
        orderData.billing.state.isNotEmpty) {
      billingAddress += " ${orderData.billing.state}";
    }

    if (orderData?.billing?.postcode is String &&
        orderData.billing.postcode.isNotEmpty) {
      billingAddress += " ${orderData.billing.postcode}";
    }

    if (orderData?.billing?.country is String &&
        orderData.billing.country.isNotEmpty) {
      billingAddress += " ${orderData.billing.country}";
    }

    if (billingAddress.isNotEmpty) {
      orderBillingWidgetData.add(GestureDetector(
        child: Text("Address: $billingAddress"),
        onLongPress: () {
          Clipboard.setData(ClipboardData(text: billingAddress));
          Scaffold.of(context).showSnackBar(SnackBar(
            content: Text("Billing Address Copied..."),
            duration: Duration(seconds: 1),
          ));
        },
      ));
    }

    if (orderBillingWidgetData.isNotEmpty) {
      orderBillingWidget = ExpansionTile(
        title: Text(
          "Billing",
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
                      children: orderBillingWidgetData),
                ),
              ),
            ],
          )
        ],
      );
    }
    return orderBillingWidget;
  }
}
