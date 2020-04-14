import 'dart:convert';
import 'dart:io';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class CustomerDetailsPage extends StatefulWidget {
  final String baseurl;
  final String username;
  final String password;
  final int id;

  CustomerDetailsPage(
      {Key key,
      @required this.baseurl,
      @required this.username,
      @required this.password,
      @required this.id})
      : super(key: key);

  @override
  _CustomerDetailsPageState createState() => _CustomerDetailsPageState();
}

class _CustomerDetailsPageState extends State<CustomerDetailsPage> {
  Map customerData = Map();
  bool isCustomerDataReady = false;
  bool isCustomerDataError = false;
  String customerDataError;

  final scaffoldKey = new GlobalKey<ScaffoldState>();
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      new GlobalKey<RefreshIndicatorState>();

  @override
  void initState() {
    super.initState();
    fetchCustomerDetails();
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        title: Text("Customer Details"),
      ),
      body: !isCustomerDataReady
          ? !isCustomerDataError
              ? _mainLoadingWidget()
              : Container(
                  child: Center(
                    child: Text(customerDataError),
                  ),
                )
          : RefreshIndicator(
              key: _refreshIndicatorKey,
              onRefresh: fetchCustomerDetails,
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                padding: const EdgeInsets.all(0.0),
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        _customerGeneralWidget(),
                        _customerShippingWidget(),
                        _customerBillingWidget(),
                      ]),
                ),
              ),
            ),
    );
  }

  Future<Null> fetchCustomerDetails() async {
    String url =
        "${widget.baseurl}/wp-json/wc/v3/customers/${widget.id}?consumer_key=${widget.username}&consumer_secret=${widget.password}";
    setState(() {
      isCustomerDataError = false;
      isCustomerDataReady = false;
    });
    dynamic response;
    try {
      response = await http.get(url);
      if (response.statusCode == 200) {
        dynamic responseBody = json.decode(response.body);
        if (responseBody is Map &&
            responseBody.containsKey("id") &&
            responseBody["id"] != null) {
          setState(() {
            customerData = responseBody;
            isCustomerDataReady = true;
            isCustomerDataError = false;
          });
        } else {
          setState(() {
            isCustomerDataReady = false;
            isCustomerDataError = true;
            customerDataError = "Failed to fetch customer details.";
          });
        }
      } else {
        String errorCode = "";
        if (json.decode(response.body) is Map &&
            json.decode(response.body).containsKey("code") &&
            json.decode(response.body)["code"] is String) {
          errorCode = json.decode(response.body)["code"];
        }
        setState(() {
          isCustomerDataReady = false;
          isCustomerDataError = true;
          customerDataError =
              "Failed to fetch customer details. Error: $errorCode";
        });
      }
    } on SocketException catch (_) {
       setState(() {
        isCustomerDataReady = false;
        isCustomerDataError = true;
        customerDataError = "Failed to fetch customer details. Error: Netwok not reachable";
      });
    } catch (e) {
      setState(() {
        isCustomerDataReady = false;
        isCustomerDataError = true;
        customerDataError = "Failed to fetch customer details. Error: $e";
      });
    }
  }

  Widget _mainLoadingWidget() {
    Widget mainLoadingWidget = SizedBox.shrink();
    if (!isCustomerDataReady && !isCustomerDataError) {
      mainLoadingWidget = Container(
        child: Center(
          child: SpinKitPulse(
            color: Theme.of(context).primaryColor,
            size: 70,
          ),
        ),
      );
    }
    return mainLoadingWidget;
  }

  _customerGeneralWidget() {
    Widget customerGeneralWidget = SizedBox.shrink();
    List<Widget> customerGeneralWidgetData = [];
    if (isCustomerDataReady &&
        (customerData.containsKey("id") ||
            customerData.containsKey("username") ||
            customerData.containsKey("first_name") ||
            customerData.containsKey("last_name") ||
            customerData.containsKey("email") ||
            customerData.containsKey("date_created") ||
            customerData.containsKey("is_paying_customer"))) {
      if (customerData.containsKey("id") && customerData["id"] is int) {
        customerGeneralWidgetData
            .add(Text("Customer ID: ${customerData["id"]}"));
      }

      if (customerData.containsKey("username") &&
          customerData["username"] is String &&
          customerData["username"].toString().isNotEmpty) {
        customerGeneralWidgetData.add(
          Text("Username: ${customerData["username"]}"),
        );
      }

      String customerName = "";
      if (customerData.containsKey("first_name") &&
          customerData["first_name"] is String &&
          customerData["first_name"].toString().isNotEmpty) {
        customerName += customerData["first_name"];
      }
      if (customerData.containsKey("last_name") &&
          customerData["last_name"] is String &&
          customerData["last_name"].toString().isNotEmpty) {
        customerName += " ${customerData["last_name"]}";
      }
      if (customerName.isNotEmpty) {
        customerGeneralWidgetData.add(Text("Name: $customerName"));
      }

      if (customerData.containsKey("email") &&
          customerData["email"] is String &&
          customerData["email"].toString().isNotEmpty) {
        customerGeneralWidgetData.add(RichText(
            text: TextSpan(
                text: "Email: ",
                style: Theme.of(context).textTheme.body1.copyWith(fontSize: 18),
                children: [
              TextSpan(
                text: customerData["email"],
                style: TextStyle(color: Colors.blue),
                recognizer: TapGestureRecognizer()
                  ..onTap = () {
                    launch("mailto:${customerData["email"]}");
                  },
              )
            ])));
      }

      if (customerData.containsKey("date_created") &&
          customerData["date_created"] is String &&
          customerData["date_created"].toString().isNotEmpty) {
        customerGeneralWidgetData.add(Text(
          "Created: " +
              DateFormat("EEEE, d/M/y h:mm:ss a")
                  .format(DateTime.parse(customerData["date_created"])),
        ));
      }

      if (customerData.containsKey("is_paying_customer") &&
          customerData["is_paying_customer"] is bool) {
        customerGeneralWidgetData.add(Text("Is Paying: " +
            (customerData["is_paying_customer"] ? "Yes" : "No")));
      }

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

  _customerShippingWidget() {
    Widget customerShippingWidget = SizedBox.shrink();
    List<Widget> customerShippingWidgetData = [];
    if (isCustomerDataReady &&
        customerData.containsKey("shipping") &&
        customerData["shipping"] is Map) {
      String customerName = "";
      if (customerData["shipping"].containsKey("first_name") &&
          customerData["shipping"]["first_name"] is String &&
          customerData["shipping"]["first_name"].toString().isNotEmpty) {
        customerName += customerData["first_name"];
      }

      if (customerData["shipping"].containsKey("last_name") &&
          customerData["shipping"]["last_name"] is String &&
          customerData["shipping"]["last_name"].toString().isNotEmpty) {
        customerName += " ${customerData["last_name"]}";
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

      if (customerData["shipping"].containsKey("company") &&
          customerData["shipping"]["company"] is String &&
          customerData["shipping"]["company"].toString().isNotEmpty) {
        customerShippingWidgetData
            .add(Text("Company: ${customerData["shipping"]["company"]}"));
      }

      String shippingAddress = "";
      if (customerData["shipping"].containsKey("address_1") &&
          customerData["shipping"]["address_1"] is String &&
          customerData["shipping"]["address_1"].toString().isNotEmpty) {
        shippingAddress = customerData["shipping"]["address_1"].toString();
      }

      if (customerData["shipping"].containsKey("address_2") &&
          customerData["shipping"]["address_2"] is String &&
          customerData["shipping"]["address_2"].toString().isNotEmpty) {
        shippingAddress += " ${customerData["shipping"]["address_2"]}";
      }

      if (customerData["shipping"].containsKey("city") &&
          customerData["shipping"]["city"] is String &&
          customerData["shipping"]["city"].toString().isNotEmpty) {
        shippingAddress += " ${customerData["shipping"]["city"]}";
      }

      if (customerData["shipping"].containsKey("state") &&
          customerData["shipping"]["state"] is String &&
          customerData["shipping"]["state"].toString().isNotEmpty) {
        shippingAddress += " ${customerData["shipping"]["state"]}";
      }

      if (customerData["shipping"].containsKey("postcode") &&
          customerData["shipping"]["postcode"] is String &&
          customerData["shipping"]["postcode"].toString().isNotEmpty) {
        shippingAddress += " ${customerData["shipping"]["postcode"]}";
      }

      if (customerData["shipping"].containsKey("country") &&
          customerData["shipping"]["country"] is String &&
          customerData["shipping"]["country"].toString().isNotEmpty) {
        shippingAddress += " ${customerData["shipping"]["country"]}";
      }

      if (shippingAddress.isNotEmpty) {
        customerShippingWidgetData.add(GestureDetector(
          child: Text("Address: $shippingAddress"),
          onLongPress: () {
            Clipboard.setData(ClipboardData(text: shippingAddress));
            scaffoldKey.currentState.showSnackBar(SnackBar(
              content: Text("Shipping Address Copied..."),
              duration: Duration(seconds: 1),
            ));
          },
        ));
      }

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
    return customerShippingWidget;
  }

  _customerBillingWidget() {
    Widget customerBillingWidget = SizedBox.shrink();
    List<Widget> customerBillingWidgetData = [];

    String billingName = "";
    if (isCustomerDataReady &&
        customerData.containsKey("billing") &&
        customerData["billing"] is Map) {
      if (customerData["billing"].containsKey("first_name") &&
          customerData["billing"]["first_name"] is String &&
          customerData["billing"]["first_name"].toString().isNotEmpty) {
        billingName += customerData["billing"]["first_name"];
      }
      if (customerData["billing"].containsKey("last_name") &&
          customerData["billing"]["last_name"] is String &&
          customerData["billing"]["last_name"].toString().isNotEmpty) {
        billingName += " ${customerData["billing"]["last_name"]}";
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

      if (customerData["billing"].containsKey("phone") &&
          customerData["billing"]["phone"] is String &&
          customerData["billing"]["phone"].toString().isNotEmpty) {
        customerBillingWidgetData.add(RichText(
            text: TextSpan(
                text: "Phone: ",
                style: Theme.of(context).textTheme.body1.copyWith(fontSize: 18),
                children: [
              TextSpan(
                text: customerData["billing"]["phone"],
                style: TextStyle(color: Colors.blue),
                recognizer: TapGestureRecognizer()
                  ..onTap = () {
                    launch("tel:${customerData["billing"]["phone"]}");
                  },
              )
            ])));
      }

      if (customerData["billing"].containsKey("email") &&
          customerData["billing"]["email"] is String &&
          customerData["billing"]["email"].toString().isNotEmpty) {
        customerBillingWidgetData.add(RichText(
            text: TextSpan(
                text: "Email: ",
                style: Theme.of(context).textTheme.body1.copyWith(fontSize: 18),
                children: [
              TextSpan(
                text: customerData["billing"]["email"],
                style: TextStyle(color: Colors.blue),
                recognizer: TapGestureRecognizer()
                  ..onTap = () {
                    launch("mailto:${customerData["billing"]["email"]}");
                  },
              )
            ])));
      }

      String billingAddress = "";
      if (customerData["billing"].containsKey("address_1") &&
          customerData["billing"]["address_1"] is String &&
          customerData["billing"]["address_1"].toString().isNotEmpty) {
        billingAddress = customerData["billing"]["address_1"].toString();
      }

      if (customerData["billing"].containsKey("address_2") &&
          customerData["billing"]["address_2"] is String &&
          customerData["billing"]["address_2"].toString().isNotEmpty) {
        billingAddress += " ${customerData["billing"]["address_2"]}";
      }

      if (customerData["billing"].containsKey("city") &&
          customerData["billing"]["city"] is String &&
          customerData["billing"]["city"].toString().isNotEmpty) {
        billingAddress += " ${customerData["billing"]["city"]}";
      }

      if (customerData["billing"].containsKey("state") &&
          customerData["billing"]["state"] is String &&
          customerData["billing"]["state"].toString().isNotEmpty) {
        billingAddress += " ${customerData["billing"]["state"]}";
      }

      if (customerData["billing"].containsKey("postcode") &&
          customerData["billing"]["postcode"] is String &&
          customerData["billing"]["postcode"].toString().isNotEmpty) {
        billingAddress += " ${customerData["billing"]["postcode"]}";
      }

      if (customerData["billing"].containsKey("country") &&
          customerData["billing"]["country"] is String &&
          customerData["billing"]["country"].toString().isNotEmpty) {
        billingAddress += " ${customerData["billing"]["country"]}";
      }

      if (billingAddress.isNotEmpty) {
        customerBillingWidgetData.add(GestureDetector(
          child: Text("Address: $billingAddress"),
          onLongPress: () {
            Clipboard.setData(ClipboardData(text: billingAddress));
            scaffoldKey.currentState.showSnackBar(SnackBar(
              content: Text("Billing Address Copied..."),
              duration: Duration(seconds: 1),
            ));
          },
        ));
      }

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
