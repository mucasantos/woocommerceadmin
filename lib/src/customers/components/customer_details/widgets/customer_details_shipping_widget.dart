import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:woocommerceadmin/src/customers/models/customer.dart';
import 'package:woocommerceadmin/src/customers/providers/customer_provider.dart';

class CustomerDetailsShippingWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final CustomerProvider customerProvider =
        Provider.of<CustomerProvider>(context);
    final Customer customerData = customerProvider.customer;

    Widget customerShippingWidget = SizedBox.shrink();
    List<Widget> customerShippingWidgetData = [];
    if (customerData?.shipping != null) {
      String customerName = "";
      if (customerData.shipping?.firstName is String &&
          customerData.shipping.firstName.isNotEmpty) {
        customerName += customerData.shipping.firstName;
      }

      if (customerData.shipping?.lastName is String &&
          customerData.shipping.lastName.isNotEmpty) {
        customerName += " ${customerData.shipping.lastName}";
      }

      if (customerName.isNotEmpty) {
        customerShippingWidgetData.add(Text(
          customerName,
          style: Theme.of(context)
              .textTheme
              .body1
              .copyWith(fontWeight: FontWeight.bold),
        ));
      }

      if (customerData.shipping?.company is String &&
          customerData.shipping.company.isNotEmpty) {
        customerShippingWidgetData
            .add(Text("Company: ${customerData.shipping.company}"));
      }

      String shippingAddress = "";
      if (customerData.shipping?.address1 is String &&
          customerData.shipping.address1.isNotEmpty) {
        shippingAddress = customerData.shipping.address1;
      }

      if (customerData.shipping?.address2 is String &&
          customerData.shipping.address2.isNotEmpty) {
        shippingAddress += " ${customerData.shipping.address2}";
      }

      if (customerData.shipping?.city is String &&
          customerData.shipping.city.isNotEmpty) {
        shippingAddress += " ${customerData.shipping.city}";
      }

      if (customerData.shipping?.state is String &&
          customerData.shipping.state.isNotEmpty) {
        shippingAddress += " ${customerData.shipping.state}";
      }

      if (customerData.shipping?.postcode is String &&
          customerData.shipping.postcode.isNotEmpty) {
        shippingAddress += " ${customerData.shipping.postcode}";
      }

      if (customerData.shipping?.city is String &&
          customerData.shipping.city.isNotEmpty) {
        shippingAddress += " ${customerData.shipping.city}";
      }

      if (shippingAddress.isNotEmpty) {
        customerShippingWidgetData.add(
          GestureDetector(
            child: Text("Address: $shippingAddress"),
            onLongPress: () {
              Clipboard.setData(ClipboardData(text: shippingAddress));
              Scaffold.of(context).showSnackBar(
                SnackBar(
                  content: Text("Shipping Address Copied..."),
                  duration: Duration(seconds: 1),
                ),
              );
            },
          ),
        );
      }

      if (customerShippingWidgetData.isNotEmpty) {
        customerShippingWidget = ExpansionTile(
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
                        children: customerShippingWidgetData),
                  ),
                ),
              ],
            )
          ],
        );
      }
    }
    return customerShippingWidget;
  }
}
