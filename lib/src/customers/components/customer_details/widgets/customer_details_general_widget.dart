import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:woocommerceadmin/src/customers/models/customer.dart';
import 'package:woocommerceadmin/src/customers/providers/customer_provider.dart';

class CustomerDetailsGeneralWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final CustomerProvider customerProvider =
        Provider.of<CustomerProvider>(context);
    final Customer customerData = customerProvider.customer;

    Widget customerGeneralWidget = SizedBox.shrink();
    List<Widget> customerGeneralWidgetData = [];

    if (customerData?.id is int) {
      customerGeneralWidgetData.add(Text("Customer ID: ${customerData.id}"));
    }

    if (customerData?.username is String && customerData.username.isNotEmpty) {
      customerGeneralWidgetData.add(
        Text("Username: ${customerData.username}"),
      );
    }

    String customerName = "";
    if (customerData?.firstName is String &&
        customerData.firstName.isNotEmpty) {
      customerName += customerData.firstName;
    }

    if (customerData?.lastName is String && customerData.lastName.isNotEmpty) {
      customerName += " ${customerData.lastName}";
    }

    if (customerName.isNotEmpty) {
      customerGeneralWidgetData.add(Text("Name: $customerName"));
    }

    if (customerData?.email is String && customerData.email.isNotEmpty) {
      customerGeneralWidgetData.add(RichText(
          text: TextSpan(
              text: "Email: ",
              style: Theme.of(context).textTheme.body1.copyWith(fontSize: 18),
              children: [
            TextSpan(
              text: customerData.email,
              style: TextStyle(color: Colors.blue),
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  launch("mailto:${customerData.email}");
                },
            )
          ])));
    }

    if (customerData?.dateCreated is DateTime) {
      customerGeneralWidgetData.add(Text(
        "Created: " +
            DateFormat("EEEE, d/M/y h:mm:ss a")
                .format(customerData.dateCreated),
      ));
    }

    if (customerData?.isPayingCustomer is bool) {
      customerGeneralWidgetData.add(
          Text("Is Paying: " + (customerData.isPayingCustomer ? "Yes" : "No")));
    }

    if (customerGeneralWidgetData.isNotEmpty) {
      customerGeneralWidget = ExpansionTile(
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
                      children: customerGeneralWidgetData),
                ),
              ),
            ],
          )
        ],
      );
    }
    
    return customerGeneralWidget;
  }
}
