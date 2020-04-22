import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:woocommerceadmin/src/orders/components/order_details/screens/order_details_screen.dart';
import 'package:woocommerceadmin/src/orders/models/order.dart';
import 'package:recase/recase.dart';

class OrdersListItemWidget extends StatelessWidget {
  final String baseurl;
  final String username;
  final String password;
  final Order orderData;

  OrdersListItemWidget({
    @required this.baseurl,
    @required this.username,
    @required this.password,
    @required this.orderData,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => OrderDetailsPage(
                baseurl: baseurl,
                username: username,
                password: password,
                id: orderData.id,
              ),
            ),
          );
        },
        child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        _orderDate(orderData),
                        _orderIdAndBillingName(orderData, context),
                        _orderStatus(orderData),
                        _orderTotal(orderData)
                      ]),
                ),
              )
            ]),
      ),
    );
  }

  Widget _orderDate(Order orderData) {
    Widget orderDateWidget = SizedBox();
    if (orderData?.dateCreated is DateTime)
      orderDateWidget = Text(
        DateFormat("EEEE, dd/MM/yyyy h:mm:ss a").format(orderData.dateCreated),
      );
    return orderDateWidget;
  }

  Widget _orderIdAndBillingName(Order orderData, BuildContext context) {
    Widget orderIdAndBillingNameWidget = SizedBox();
    String orderId = "";
    String billingName = "";
    if (orderData?.id is int) {
      orderId = "#${orderData.id}";
    }
    if ((orderData?.billing != null) ?? false) {
      if (orderData.billing?.firstName is String) {
        billingName = billingName + orderData.billing.firstName;
      }
      if (orderData.billing?.lastName is String) {
        if (billingName.isNotEmpty) {
          billingName = billingName + " ";
        }
        billingName = billingName + orderData.billing.lastName;
      }
    }
    orderIdAndBillingNameWidget = Text(
      "$orderId $billingName",
      style: Theme.of(context)
          .textTheme
          .body1
          .copyWith(fontSize: 20.0, fontWeight: FontWeight.bold),
    );
    return orderIdAndBillingNameWidget;
  }

  Widget _orderStatus(Order orderData) {
    Widget orderStatusWidget = SizedBox();
    if (orderData?.status is String)
      orderStatusWidget = Text(
        "Status: " + orderData.status.titleCase,
      );
    return orderStatusWidget;
  }

  Widget _orderTotal(Order orderData) {
    Widget orderTotalWidget = SizedBox();
    if (orderData?.total is String)
      orderTotalWidget = Text("Total: " +
          (orderData?.currencySymbol ?? orderData?.currency ?? "") +
          orderData.total);
    return orderTotalWidget;
  }
}
