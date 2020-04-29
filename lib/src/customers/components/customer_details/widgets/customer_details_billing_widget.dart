import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:woocommerceadmin/src/customers/models/customer.dart';
import 'package:woocommerceadmin/src/customers/providers/customer_provider.dart';

class CustomerDetailsBillingWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final CustomerProvider customerProvider =
        Provider.of<CustomerProvider>(context);
    final Customer customerData = customerProvider.customer;

    Widget customerBillingWidget = SizedBox.shrink();
    List<Widget> customerBillingWidgetData = [];

    String billingName = "";

    if (customerData?.billing?.firstName is String &&
        customerData.billing.firstName.isNotEmpty) {
      billingName += customerData.billing.firstName;
    }
    if (customerData?.billing?.lastName is String &&
        customerData.billing.lastName.isNotEmpty) {
      billingName += " ${customerData.billing.lastName}";
    }
    if (billingName.isNotEmpty) {
      customerBillingWidgetData.add(Text(
        billingName,
        style: Theme.of(context)
            .textTheme
            .body1
            .copyWith(fontWeight: FontWeight.bold),
      ));
    }

    if (customerData?.billing?.phone is String &&
        customerData.billing.phone.isNotEmpty) {
      customerBillingWidgetData.add(RichText(
          text: TextSpan(
              text: "Phone: ",
              style: Theme.of(context).textTheme.body1.copyWith(fontSize: 18),
              children: [
            TextSpan(
              text: customerData.billing.phone,
              style: TextStyle(color: Colors.blue),
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  launch("tel:${customerData.billing.phone}");
                },
            )
          ])));
    }

    if (customerData?.billing?.email is String &&
        customerData.billing.email.isNotEmpty) {
      customerBillingWidgetData.add(RichText(
          text: TextSpan(
              text: "Email: ",
              style: Theme.of(context).textTheme.body1.copyWith(fontSize: 18),
              children: [
            TextSpan(
              text: customerData.billing.email,
              style: TextStyle(color: Colors.blue),
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  launch("mailto:${customerData.billing.email}");
                },
            )
          ])));
    }

    String billingAddress = "";
    if (customerData?.billing?.address1 is String &&
        customerData.billing.address1.isNotEmpty) {
      billingAddress = customerData.billing.address1;
    }

    if (customerData?.billing?.address2 is String &&
        customerData.billing.address2.isNotEmpty) {
      billingAddress += " ${customerData.billing.address2}";
    }

    if (customerData?.billing?.city is String &&
        customerData.billing.city.isNotEmpty) {
      billingAddress += " ${customerData.billing.city}";
    }

    if (customerData?.billing?.state is String &&
        customerData.billing.state.isNotEmpty) {
      billingAddress += " ${customerData.billing.state}";
    }

    if (customerData?.billing?.postcode is String &&
        customerData.billing.postcode.isNotEmpty) {
      billingAddress += " ${customerData.billing.postcode}";
    }

    if (customerData?.billing?.country is String &&
        customerData.billing.country.isNotEmpty) {
      billingAddress += " ${customerData.billing.country}";
    }

    if (billingAddress.isNotEmpty) {
      customerBillingWidgetData.add(GestureDetector(
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

    if (customerBillingWidgetData.isNotEmpty) {
      customerBillingWidget = ExpansionTile(
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
                      children: customerBillingWidgetData),
                ),
              ),
            ],
          )
        ],
      );
    }
    return customerBillingWidget;
  }
}
