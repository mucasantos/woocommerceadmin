import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart' as http;
import 'package:woocommerceadmin/src/customers/components/customer_details/widgets/customer_details_billing_widget.dart';
import 'package:woocommerceadmin/src/customers/components/customer_details/widgets/customer_details_general_widget.dart';
import 'package:woocommerceadmin/src/customers/components/customer_details/widgets/customer_details_shipping_widget.dart';

class CustomerDetailsPage extends StatefulWidget {
  final String baseurl;
  final String username;
  final String password;
  final int id;

  CustomerDetailsPage({
    Key key,
    @required this.baseurl,
    @required this.username,
    @required this.password,
    @required this.id,
  }) : super(key: key);

  @override
  _CustomerDetailsPageState createState() => _CustomerDetailsPageState();
}

class _CustomerDetailsPageState extends State<CustomerDetailsPage> {
  Map customerData = Map();
  bool isCustomerDataReady = true;
  bool isCustomerDataError = false;
  String customerDataError;

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Customer Details"),
      ),
      body: !isCustomerDataReady
          ? !isCustomerDataError
              ? _mainLoadingWidget()
              : Container(
                  padding: EdgeInsets.all(10),
                  child: Center(
                    child: Text(customerDataError ?? ""),
                  ),
                )
          : RefreshIndicator(
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
                        CustomerDetailsGeneralWidget(),
                        CustomerDetailsShippingWidget(),
                        CustomerDetailsBillingWidget(),
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
        customerDataError =
            "Failed to fetch customer details. Error: Netwok not reachable";
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
}
