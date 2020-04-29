import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:woocommerceadmin/src/customers/components/customer_details/screens/customer_details_screen.dart';
import 'package:woocommerceadmin/src/customers/models/customer.dart';
import 'package:woocommerceadmin/src/customers/providers/customer_provider.dart';

class CustomersListItemWidget extends StatelessWidget {
  final String baseurl;
  final String username;
  final String password;
  final CustomerProvider customerProvider;

  CustomersListItemWidget({
    @required this.baseurl,
    @required this.username,
    @required this.password,
    @required this.customerProvider,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChangeNotifierProvider.value(
                value: customerProvider,
                child: CustomerDetailsPage(
                  baseurl: baseurl,
                  username: username,
                  password: password,
                  id: customerProvider.customer.id,
                ),
              ),
            ),
          );
        },
        child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              _customerImage(customerProvider.customer, context),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        _customerIdAndUsername(customerProvider.customer, context),
                        _customerEmail(customerProvider.customer),
                        _customerName(customerProvider.customer),
                        _customerIsPaying(customerProvider.customer),
                        _customerDateCreated(customerProvider.customer),
                      ]),
                ),
              )
            ]),
      ),
    );
  }

  Widget _customerImage(Customer customerData, BuildContext context) {
    Widget customerImageWidget = Padding(
      padding: EdgeInsets.all(10),
      child: SizedBox(
        height: 140,
        width: 140,
        child: Icon(
          Icons.person,
          size: 30,
        ),
      ),
    );
    if (customerData?.avatarUrl is String &&
        customerData.avatarUrl.isNotEmpty) {
      customerImageWidget = ExtendedImage.network(
        customerData.avatarUrl,
        fit: BoxFit.fill,
        width: 140.0,
        height: 140.0,
        cache: true,
        enableLoadState: true,
        loadStateChanged: (ExtendedImageState state) {
          if (state.extendedImageLoadState == LoadState.loading) {
            return SpinKitPulse(
              color: Theme.of(context).primaryColor,
              size: 50,
            );
          }
          return null;
        },
      );
    }
    return customerImageWidget;
  }

  Widget _customerIdAndUsername(Customer customerData, BuildContext context) {
    String customerIdAndUsername = "";
    Widget customerIdAndUsernameWidget = SizedBox();

    if (customerData?.id is int) {
      customerIdAndUsername += "#${customerData.id}";
    }

    if (customerData?.username is String && customerData.username.isNotEmpty) {
      customerIdAndUsername += " ${customerData.username}";
    }

    customerIdAndUsernameWidget = Text(
      customerIdAndUsername,
      style: Theme.of(context)
          .textTheme
          .body1
          .copyWith(fontSize: 20.0, fontWeight: FontWeight.bold),
    );
    return customerIdAndUsernameWidget;
  }

  Widget _customerName(Customer customerData) {
    String customerName = "";
    Widget customerNameWidget = SizedBox();
    if (customerData?.firstName is String &&
        customerData.firstName.isNotEmpty) {
      customerName += customerData.firstName;
    }
    if (customerData?.lastName is String && customerData.lastName.isNotEmpty) {
      customerName += " ${customerData.lastName}";
    }
    if (customerName.isNotEmpty) {
      customerNameWidget = Text("Name: $customerName");
    }
    return customerNameWidget;
  }

  Widget _customerEmail(Customer customerData) {
    Widget customerEmailWidget = SizedBox();
    if (customerData?.email is String && customerData.email.isNotEmpty) {
      customerEmailWidget = Text(customerData.email);
    }
    return customerEmailWidget;
  }

  Widget _customerIsPaying(Customer customerData) {
    Widget customerIsPayingWidget = SizedBox();
    if (customerData?.isPayingCustomer is bool) {
      customerIsPayingWidget =
          Text("Is Paying: " + (customerData.isPayingCustomer ? "Yes" : "No"));
    }
    return customerIsPayingWidget;
  }

  Widget _customerDateCreated(Customer customerData) {
    Widget customerDateCreatedWidget = SizedBox();
    if (customerData?.dateCreated is DateTime) {
      customerDateCreatedWidget = Text(
        "Created: " +
            DateFormat("EEEE, d/M/y h:mm:ss a")
                .format(customerData.dateCreated),
      );
    }
    return customerDateCreatedWidget;
  }
}
