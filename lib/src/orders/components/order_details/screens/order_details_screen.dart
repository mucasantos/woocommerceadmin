import 'dart:io';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:linkify/linkify.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'package:recase/recase.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:woocommerceadmin/src/orders/components/order_details/widgets/change_order_status_modal.dart';
import 'package:woocommerceadmin/src/orders/components/order_details/widgets/order_details_billing_widget.dart';
import 'package:woocommerceadmin/src/orders/components/order_details/widgets/order_details_general_widget.dart';
import 'package:woocommerceadmin/src/orders/components/order_details/widgets/order_details_line_items_widget.dart';
import 'package:woocommerceadmin/src/orders/components/order_details/widgets/order_details_order_notes_widget.dart';
import 'package:woocommerceadmin/src/orders/components/order_details/widgets/order_details_payment_widget.dart';
import 'package:woocommerceadmin/src/orders/components/order_details/widgets/order_details_shipping_widget.dart';
import 'package:woocommerceadmin/src/orders/models/order.dart';
import 'package:woocommerceadmin/src/orders/providers/order_provider.dart';

class OrderDetailsPage extends StatefulWidget {
  final String baseurl;
  final String username;
  final String password;
  final int id;
  // final Map<String, dynamic> orderData;
  // final bool preFetch;

  OrderDetailsPage({
    Key key,
    @required this.baseurl,
    @required this.username,
    @required this.password,
    @required this.id,
    // this.orderData,
    // this.preFetch,
  }) : super(key: key);

  @override
  _OrderDetailsPageState createState() => _OrderDetailsPageState();
}

class _OrderDetailsPageState extends State<OrderDetailsPage> {
  bool isOrderDataReady = true;
  bool isOrderDataError = false;
  String orderDataError;

  final GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  void initState() {
    // if (widget.preFetch ?? true) {
    //   fetchOrderDetails();
    // } else {
    //   if (widget.orderData is Map &&
    //       widget.orderData.containsKey("id") &&
    //       widget.orderData["id"] is int) {
    //     orderData = widget.orderData;
    //   } else {
    //     fetchOrderDetails();
    //   }
    // }
    // fetchOrderNotes();
    super.initState();
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
        title: Text("Orders Details"),
      ),
      body: !isOrderDataReady
          ? !isOrderDataError ? _mainLoadingWidget() : _orderDataErrorWidget()
          : RefreshIndicator(
              onRefresh: () async {
                fetchOrderDetails();
              },
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
                        OrderDetailsGeneralWidget(
                            baseurl: widget.baseurl,
                            username: widget.username,
                            password: widget.password,
                            orderId: widget.id,
                            scaffoldKey: scaffoldKey),
                        OrderDetailsLineItemsWidget(
                          baseurl: widget.baseurl,
                          username: widget.username,
                          password: widget.password,
                        ),
                        OrderDetailsPaymentWidget(),
                        OrderDetailsShippingWidget(),
                        OrderDetailsBillingWidget(),
                        OrderDetailsOrderNotesWidget(
                          baseurl: widget.baseurl,
                          username: widget.username,
                          password: widget.password,
                          orderId: widget.id,
                        ),
                      ]),
                ),
              ),
            ),
    );
  }

  Future<void> fetchOrderDetails() async {
    String url =
        "${widget.baseurl}/wp-json/wc/v3/orders/${widget.id}?consumer_key=${widget.username}&consumer_secret=${widget.password}";

    setState(() {
      isOrderDataReady = false;
    });

    http.Response response;
    try {
      response = await http.get(url);
      if (response.statusCode == 200) {
        if (json.decode(response.body) is Map &&
            json.decode(response.body).containsKey("id")) {
          Map responseBody = json.decode(response.body);
          Provider.of<OrderProvider>(context, listen: false)
              .replaceOrder(Order.fromJson(responseBody));
          setState(() {
            isOrderDataReady = true;
            isOrderDataError = false;
          });
        } else {
          setState(() {
            isOrderDataReady = false;
            isOrderDataError = true;
            orderDataError = "Failed to fetch order details";
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
          isOrderDataReady = false;
          isOrderDataError = true;
          orderDataError = "Failed to fetch order details. Error $errorCode";
        });
      }
    } on SocketException catch (_) {
      setState(() {
        isOrderDataReady = false;
        isOrderDataError = true;
        orderDataError =
            "Failed to fetch order details. Error: Network not reachable";
      });
    } catch (e) {
      setState(() {
        isOrderDataReady = false;
        isOrderDataError = true;
        orderDataError = "Failed to fetch order details. Error $e";
      });
    }
  }

  Widget _mainLoadingWidget() {
    Widget mainLoadingWidget = SizedBox.shrink();
    if (!isOrderDataReady && !isOrderDataError) {
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

  Widget _orderDataErrorWidget() {
    Widget orderDataErrorWidget = SizedBox.shrink();
    if (isOrderDataError &&
        !isOrderDataReady &&
        orderDataError is String &&
        orderDataError.isNotEmpty) {
      orderDataErrorWidget = Container(
        child: Center(
          child: Text(orderDataError),
        ),
      );
    }
    return orderDataErrorWidget;
  }
}
