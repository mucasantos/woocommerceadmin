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
import 'dart:convert';
import 'package:recase/recase.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:woocommerceadmin/src/orders/components/order_details/widgets/change_order_status_modal.dart';
import 'package:woocommerceadmin/src/products/components/product_details/screens/product_details_screen.dart';

class OrderDetailsPage extends StatefulWidget {
  final String baseurl;
  final String username;
  final String password;
  final int id;
  final Map<String, dynamic> orderData;
  final bool preFetch;

  OrderDetailsPage({
    Key key,
    @required this.baseurl,
    @required this.username,
    @required this.password,
    @required this.id,
    this.orderData,
    this.preFetch,
  }) : super(key: key);

  @override
  _OrderDetailsPageState createState() => _OrderDetailsPageState();
}

class _OrderDetailsPageState extends State<OrderDetailsPage> {
  bool isOrderDataReady = true;
  bool isOrderDataError = false;
  String orderDataError;
  Map orderData = {};

  bool isOrderNotesDataReady = false;
  bool isOrderNotesDataError = false;
  List orderNotesData = [];
  String orderNotesDataError;

  bool isCustomerNewOrderNote = false;
  String newOrderNote = "";

  final scaffoldKey = new GlobalKey<ScaffoldState>();
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      new GlobalKey<RefreshIndicatorState>();

  @override
  void initState() {
    if (widget.preFetch ?? true) {
      fetchOrderDetails();
    } else {
      if (widget.orderData is Map &&
          widget.orderData.containsKey("id") &&
          widget.orderData["id"] is int) {
        orderData = widget.orderData;
      } else {
        fetchOrderDetails();
      }
    }
    fetchOrderNotes();
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
              key: _refreshIndicatorKey,
              onRefresh: fetchOrderDetails,
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
                        _orderGeneralWidget(),
                        _orderProductsWidget(),
                        _orderPaymentWidget(),
                        _orderShippingWidget(),
                        _orderBillingWidget(),
                        _orderNotesWidget(),
                      ]),
                ),
              ),
            ),
    );
  }

  Future<Null> fetchOrderDetails() async {
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
          setState(() {
            orderData = responseBody;
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

  //Update Order
  Future<Null> updateOrder(String orderStatus) async {
    String url =
        "${widget.baseurl}/wp-json/wc/v3/orders/${widget.id}?consumer_key=${widget.username}&consumer_secret=${widget.password}";
    setState(() {
      isOrderDataReady = false;
    });

    http.Response response;
    try {
      response = await http.put(url, body: {"status": orderStatus});
      if (json.decode(response.body) is Map &&
          json.decode(response.body).containsKey("id")) {
        scaffoldKey.currentState.showSnackBar(SnackBar(
          content: Text("Order updated successfully..."),
          duration: Duration(seconds: 3),
        ));
        fetchOrderDetails();
      } else {
        String errorCode = "";
        if (json.decode(response.body) is Map &&
            json.decode(response.body).containsKey("code")) {
          errorCode = json.decode(response.body)["code"];
        }
        scaffoldKey.currentState.showSnackBar(SnackBar(
          content: Text("Failed to update order. Error: $errorCode"),
          duration: Duration(seconds: 3),
        ));
        setState(() {
          isOrderDataReady = true;
        });
      }
    } on SocketException catch (_) {
      scaffoldKey.currentState.showSnackBar(SnackBar(
        content: Text("Failed to update order. Error: Network not reachable"),
        duration: Duration(seconds: 3),
      ));
      setState(() {
        isOrderDataReady = true;
      });
    } catch (e) {
      scaffoldKey.currentState.showSnackBar(SnackBar(
        content: Text("Failed to update order. Error: $e"),
        duration: Duration(seconds: 3),
      ));
      setState(() {
        isOrderDataReady = true;
      });
    }
  }

  //Order Notes Functions Below
  Future<Null> fetchOrderNotes() async {
    String url =
        "${widget.baseurl}/wp-json/wc/v3/orders/${widget.id}/notes?consumer_key=${widget.username}&consumer_secret=${widget.password}";
    setState(() {
      isOrderNotesDataReady = false;
      isOrderNotesDataError = false;
    });

    http.Response response;
    try {
      response = await http.get(url);
      if (response.statusCode == 200) {
        if (json.decode(response.body) is List &&
            !json.decode(response.body).isEmpty) {
          setState(() {
            orderNotesData = json.decode(response.body);
            isOrderNotesDataReady = true;
            isOrderNotesDataError = false;
          });
        } else {
          setState(() {
            isOrderNotesDataReady = false;
            isOrderNotesDataError = true;
            orderNotesDataError = "Failed to fetch order notes";
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
          isOrderNotesDataReady = false;
          isOrderNotesDataError = true;
          orderNotesDataError =
              "Failed to fetch order notes. Error: $errorCode";
        });
      }
    } on SocketException catch (_) {
      setState(() {
        isOrderNotesDataReady = false;
        isOrderNotesDataError = true;
        orderNotesDataError =
            "Failed to fetch order notes. Error: Network not reachable";
      });
    } catch (e) {
      setState(() {
        isOrderNotesDataReady = false;
        isOrderNotesDataError = true;
        orderNotesDataError = "Failed to fetch order notes. Error: $e";
      });
    }
  }

  //Create Order Note
  Future<Null> addOrderNote() async {
    String url =
        "${widget.baseurl}/wp-json/wc/v3/orders/${widget.id}/notes?consumer_key=${widget.username}&consumer_secret=${widget.password}";
    setState(() {
      isOrderNotesDataReady = false;
      isOrderNotesDataError = false;
    });

    http.Response response;
    try {
      response = await http.post(url, body: {
        "customer_note": isCustomerNewOrderNote.toString(),
        "note": newOrderNote
      });
      if (json.decode(response.body) is Map &&
          json.decode(response.body).containsKey("id")) {
        scaffoldKey.currentState.showSnackBar(SnackBar(
          content: Text("Order note added successfully..."),
          duration: Duration(seconds: 3),
        ));
        fetchOrderNotes();
      } else {
        String errorCode = "";
        if (json.decode(response.body) is Map &&
            json.decode(response.body).containsKey("code")) {
          errorCode = json.decode(response.body)["code"];
        }
        scaffoldKey.currentState.showSnackBar(SnackBar(
          content: Text("Failed to add order note. Error: $errorCode"),
          duration: Duration(seconds: 3),
        ));
      }
    } on SocketException catch (_) {
      scaffoldKey.currentState.showSnackBar(SnackBar(
        content: Text("Failed to add order note. Error: Network not reachable"),
        duration: Duration(seconds: 3),
      ));
    } catch (e) {
      scaffoldKey.currentState.showSnackBar(SnackBar(
        content: Text("Failed to add order note. Error: $e"),
        duration: Duration(seconds: 3),
      ));
    }
  }

  //Delete Order Note
  Future<Null> deleteOrderNote(orderNoteId) async {
    String url =
        "${widget.baseurl}/wp-json/wc/v3/orders/${widget.id}/notes/$orderNoteId?force=true&consumer_key=${widget.username}&consumer_secret=${widget.password}";
    setState(() {
      isOrderNotesDataReady = false;
      isOrderNotesDataError = false;
    });

    http.Response response;
    try {
      response = await http.delete(url);
      if (json.decode(response.body) is Map &&
          json.decode(response.body).containsKey("id")) {
        scaffoldKey.currentState.showSnackBar(SnackBar(
          content: Text("Order note deleted successfully..."),
          duration: Duration(seconds: 3),
        ));
        fetchOrderNotes();
      } else {
        String errorCode = "";
        if (json.decode(response.body) is Map &&
            json.decode(response.body).containsKey("code")) {
          errorCode = json.decode(response.body)["code"];
        }
        scaffoldKey.currentState.showSnackBar(SnackBar(
          content: Text("Failed to delete order note. Error: $errorCode"),
          duration: Duration(seconds: 3),
        ));
      }
    } on SocketException catch (_) {
      scaffoldKey.currentState.showSnackBar(SnackBar(
        content:
            Text("Failed to delete order note. Error: Network not reachable"),
        duration: Duration(seconds: 3),
      ));
    } catch (e) {
      scaffoldKey.currentState.showSnackBar(SnackBar(
        content: Text("Failed to delete order note. Error: $e"),
        duration: Duration(seconds: 3),
      ));
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
    Widget productDataErrorWidget = SizedBox.shrink();
    if (isOrderDataError &&
        !isOrderDataReady &&
        orderDataError is String &&
        orderDataError.isNotEmpty) {
      productDataErrorWidget = Container(
        child: Center(
          child: Text(orderDataError),
        ),
      );
    }
    return productDataErrorWidget;
  }

  Widget _orderGeneralWidget() {
    Widget orderGeneralWidget = SizedBox.shrink();
    List<Widget> orderGeneralData = [];
    if (isOrderDataReady &&
        (orderData.containsKey("id") ||
            orderData.containsKey("date_created") ||
            orderData.containsKey("status"))) {
      if (isOrderDataReady &&
          orderData.containsKey("id") &&
          orderData["id"] is int) {
        orderGeneralData.add(Text("Order ID: ${orderData["id"]}"));
      }

      if (isOrderDataReady &&
          orderData.containsKey("date_created") &&
          orderData["date_created"] is String) {
        orderGeneralData.add(Text(
          "Created: " +
              DateFormat("EEEE, d/M/y h:mm:ss a")
                  .format(DateTime.parse(orderData["date_created"])),
        ));
      }

      if (isOrderDataReady &&
          orderData.containsKey("status") &&
          orderData["status"] is String) {
        orderGeneralData.add(
          Row(
            children: <Widget>[
              Text("Order Status: " + orderData["status"].toString().titleCase),
              SizedBox(
                width: 20,
              ),
              GestureDetector(
                child: Icon(
                  Icons.edit,
                  color: Theme.of(context).primaryColor,
                ),
                onTap: () async {
                  return showDialog<void>(
                    context: context,
                    barrierDismissible: false,
                    builder: (BuildContext context) {
                      return ChangeOrderStatusModal(
                        baseurl: widget.baseurl,
                        username: widget.username,
                        password: widget.password,
                        orderStatus: orderData["status"],
                        onSubmit: (String newOrderStatus) {
                          updateOrder(newOrderStatus);
                        },
                      );
                    },
                  );
                },
              ),
            ],
          ),
        );
      }

      orderGeneralWidget = ExpansionTile(
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
                      children: orderGeneralData),
                ),
              ),
            ],
          )
        ],
      );
    }
    return orderGeneralWidget;
  }

  Widget _orderProductsWidget() {
    Widget orderProductsWidget = SizedBox.shrink();
    List<Widget> orderProductsCardData = [];

    if (isOrderDataReady &&
        orderData.containsKey("line_items") &&
        orderData["line_items"] is List &&
        orderData["line_items"].isNotEmpty) {
      for (int i = 0; i < orderData["line_items"].length; i++) {
        List<Widget> orderProductsData = [];
        Widget lineItemsPrimaryImage = SizedBox(
          height: 140,
          width: 140,
        );

        if (orderData["line_items"][i].containsKey("product_id") &&
            orderData["line_items"][i]["product_id"] is int) {
          lineItemsPrimaryImage = LineItemsProductsImage(
            baseurl: widget.baseurl,
            username: widget.username,
            password: widget.password,
            id: orderData["line_items"][i]["product_id"],
          );
        }

        if (orderData["line_items"][i].containsKey("name") &&
            orderData["line_items"][i]["name"] is String &&
            orderData["line_items"][i]["name"].toString().isNotEmpty) {
          orderProductsData.add(Text(
            "${orderData["line_items"][i]["name"]}",
            style: Theme.of(context)
                .textTheme
                .body1
                .copyWith(fontWeight: FontWeight.bold),
          ));
        }

        if (orderData["line_items"][i].containsKey("sku") &&
            orderData["line_items"][i]["sku"] is String) {
          orderProductsData
              .add(Text("SKU: ${orderData["line_items"][i]["sku"]}"));
        }

        if (orderData["line_items"][i].containsKey("price") &&
            orderData["line_items"][i]["price"] is String) {
          orderProductsData
              .add(Text("Price: ${orderData["line_items"][i]["price"]}"));
        }

        if (orderData["line_items"][i].containsKey("quantity") &&
            orderData["line_items"][i]["quantity"] is int) {
          orderProductsData
              .add(Text("Qty: ${orderData["line_items"][i]["quantity"]}"));
        }

        if (orderData["line_items"][i].containsKey("meta_data") &&
            orderData["line_items"][i]["meta_data"] is List &&
            orderData["line_items"][i]["meta_data"].isNotEmpty) {
          for (int metaDataIndex = 0;
              metaDataIndex < orderData["line_items"][i]["meta_data"].length;
              metaDataIndex++) {
            if (orderData["line_items"][i]["meta_data"][metaDataIndex]
                    .containsKey("key") &&
                orderData["line_items"][i]["meta_data"][metaDataIndex]["key"]
                    is String &&
                orderData["line_items"][i]["meta_data"][metaDataIndex]["key"] ==
                    "_tmcartepo_data") {
              if (orderData["line_items"][i]["meta_data"][metaDataIndex]
                      ["value"] is List &&
                  orderData["line_items"][i]["meta_data"][metaDataIndex]
                          ["value"]
                      .isNotEmpty) {
                for (int tmcartepoDataIndex = 0;
                    tmcartepoDataIndex <
                        orderData["line_items"][i]["meta_data"][metaDataIndex]
                                ["value"]
                            .length;
                    tmcartepoDataIndex++) {
                  orderProductsData.add(
                    Text(
                        '${orderData["line_items"][i]["meta_data"][metaDataIndex]["value"][tmcartepoDataIndex]["name"]}: ${orderData["line_items"][i]["meta_data"][metaDataIndex]["value"][tmcartepoDataIndex]["value"]}'),
                  );
                }
              }
              break;
            }
          }
        }

        orderProductsCardData.add(Card(
          child: InkWell(
            onTap: () {
              if (orderData["line_items"][i].containsKey("product_id") &&
                  orderData["line_items"][i]["product_id"] is int) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProductDetailsScreen(
                      baseurl: widget.baseurl,
                      username: widget.username,
                      password: widget.password,
                      id: orderData["line_items"][i]["product_id"],
                    ),
                  ),
                );
              }
            },
            child: Row(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: lineItemsPrimaryImage,
                ),
                Expanded(
                    child: Padding(
                  padding: EdgeInsets.all(10),
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: orderProductsData),
                ))
              ],
            ),
          ),
        ));
      }

      orderProductsWidget = ExpansionTile(
        title: Text(
          "Products",
          style: Theme.of(context).textTheme.subhead,
        ),
        initiallyExpanded: true,
        children: <Widget>[
          Row(
            children: <Widget>[
              Flexible(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(10.0, 0, 10.0, 10.0),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: orderProductsCardData),
                ),
              ),
            ],
          )
        ],
      );
    }
    return orderProductsWidget;
  }

  Widget _orderPaymentWidget() {
    Widget orderPaymentWidget = SizedBox.shrink();
    List<Widget> orderPaymentData = [];
    if (isOrderDataReady &&
        (orderData.containsKey("payment_method_title") ||
            orderData.containsKey("total") ||
            orderData.containsKey("shipping_total") ||
            orderData.containsKey("total_tax"))) {
      if (orderData.containsKey("payment_method_title") &&
          orderData["payment_method_title"] is String &&
          orderData["payment_method_title"].isNotEmpty) {
        orderPaymentData
            .add(Text("Payment Gateway: ${orderData["payment_method_title"]}"));
      }

      if (orderData.containsKey("total") &&
          orderData["total"] is String &&
          orderData["total"].isNotEmpty) {
        orderPaymentData.add(
          Text(
            "Order Total: ${orderData["total"]}",
            style: Theme.of(context)
                .textTheme
                .body1
                .copyWith(fontWeight: FontWeight.bold),
          ),
        );
      }

      if (orderData.containsKey("total_tax") &&
          orderData["total_tax"] is String &&
          orderData["total_tax"].isNotEmpty) {
        orderPaymentData.add(Text("Taxes: " + orderData["total_tax"]));
      }

      orderPaymentWidget = ExpansionTile(
        title: Text(
          "Payment",
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
                      children: orderPaymentData),
                ),
              ),
            ],
          )
        ],
      );
    }
    return orderPaymentWidget;
  }

  Widget _orderShippingWidget() {
    Widget orderShippingWidget = SizedBox.shrink();
    List<Widget> orderShippingData = [];
    String shippingName = "";
    String shippingAddress = "";

    if (isOrderDataReady &&
        orderData.containsKey("shipping") &&
        orderData["shipping"] is Map) {
      if (orderData["shipping"].containsKey("first_name") &&
          orderData["shipping"]["first_name"] is String &&
          orderData["shipping"]["first_name"].isNotEmpty) {
        shippingName += orderData["shipping"]["first_name"];
      }
      if (orderData["shipping"].containsKey("last_name") &&
          orderData["shipping"]["last_name"] is String &&
          orderData["shipping"]["last_name"].isNotEmpty) {
        shippingName += " ${orderData["shipping"]["last_name"]}";
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

      if (orderData["shipping"].containsKey("address_1") &&
          orderData["shipping"]["address_1"] is String &&
          orderData["shipping"]["address_1"].isNotEmpty) {
        shippingAddress = orderData["shipping"]["address_1"].toString();
      }

      if (orderData["shipping"].containsKey("address_2") &&
          orderData["shipping"]["address_2"] is String &&
          orderData["shipping"]["address_2"].isNotEmpty) {
        shippingAddress += " ${orderData["shipping"]["address_2"]}";
      }

      if (orderData["shipping"].containsKey("city") &&
          orderData["shipping"]["city"] is String &&
          orderData["shipping"]["city"].isNotEmpty) {
        shippingAddress += " ${orderData["shipping"]["city"]}";
      }

      if (orderData["shipping"].containsKey("state") &&
          orderData["shipping"]["state"] is String &&
          orderData["shipping"]["state"].isNotEmpty) {
        shippingAddress += " ${orderData["shipping"]["state"]}";
      }

      if (orderData["shipping"].containsKey("postcode") &&
          orderData["shipping"]["postcode"] is String &&
          orderData["shipping"]["postcode"].isNotEmpty) {
        shippingAddress += " ${orderData["shipping"]["postcode"]}";
      }

      if (orderData["shipping"].containsKey("country") &&
          orderData["shipping"]["country"] is String &&
          orderData["shipping"]["country"].isNotEmpty) {
        shippingAddress += " ${orderData["shipping"]["country"]}";
      }

      if (shippingAddress.isNotEmpty) {
        orderShippingData.add(GestureDetector(
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

  Widget _orderBillingWidget() {
    Widget orderBillingWidget = SizedBox.shrink();
    List<Widget> orderBillingWidgetData = [];
    String billingName = "";
    String billingAddress = "";

    if (isOrderDataReady &&
        orderData.containsKey("billing") &&
        orderData["billing"] is Map) {
      if (orderData["billing"].containsKey("first_name") &&
          orderData["billing"]["first_name"] is String &&
          orderData["billing"]["first_name"].isNotEmpty) {
        billingName += orderData["billing"]["first_name"];
      }
      if (orderData["billing"].containsKey("last_name") &&
          orderData["billing"]["last_name"] is String &&
          orderData["billing"]["last_name"].isNotEmpty) {
        billingName += " ${orderData["billing"]["last_name"]}";
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

      if (orderData["billing"].containsKey("phone") &&
          orderData["billing"]["phone"] is String &&
          orderData["billing"]["phone"].isNotEmpty) {
        orderBillingWidgetData.add(
          Text.rich(
            TextSpan(
              text: "Phone: ",
              style: Theme.of(context).textTheme.body1,
              children: [
                TextSpan(
                  text: orderData["billing"]["phone"],
                  style: TextStyle(color: Colors.blue),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      launch("tel:${orderData["billing"]["phone"]}");
                    },
                )
              ],
            ),
          ),
        );
      }

      if (orderData["billing"].containsKey("email") &&
          orderData["billing"]["email"] is String &&
          orderData["billing"]["email"].isNotEmpty) {
        orderBillingWidgetData.add(
          Text.rich(
            TextSpan(
              text: "Email: ",
              style: Theme.of(context).textTheme.body1,
              children: [
                TextSpan(
                  text: orderData["billing"]["email"],
                  style: TextStyle(color: Colors.blue),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      launch("mailto:${orderData["billing"]["email"]}");
                    },
                )
              ],
            ),
          ),
        );
      }

      if (orderData["billing"].containsKey("address_1") &&
          orderData["billing"]["address_1"] is String &&
          orderData["billing"]["address_1"].isNotEmpty) {
        billingAddress = orderData["billing"]["address_1"].toString();
      }

      if (orderData["billing"].containsKey("address_2") &&
          orderData["billing"]["address_2"] is String &&
          orderData["billing"]["address_2"].isNotEmpty) {
        billingAddress += " ${orderData["billing"]["address_2"]}";
      }

      if (orderData["billing"].containsKey("city") &&
          orderData["billing"]["city"] is String &&
          orderData["billing"]["city"].isNotEmpty) {
        billingAddress += " ${orderData["billing"]["city"]}";
      }

      if (orderData["billing"].containsKey("state") &&
          orderData["billing"]["state"] is String &&
          orderData["billing"]["state"].isNotEmpty) {
        billingAddress += " ${orderData["billing"]["state"]}";
      }

      if (orderData["billing"].containsKey("postcode") &&
          orderData["billing"]["postcode"] is String &&
          orderData["billing"]["postcode"].isNotEmpty) {
        billingAddress += " ${orderData["billing"]["postcode"]}";
      }

      if (orderData["billing"].containsKey("country") &&
          orderData["billing"]["country"] is String &&
          orderData["billing"]["country"].isNotEmpty) {
        billingAddress += " ${orderData["billing"]["country"]}";
      }

      if (billingAddress.isNotEmpty) {
        orderBillingWidgetData.add(GestureDetector(
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

  Widget _orderNotesWidget() {
    Widget orderNotesWidget = SizedBox.shrink();
    List<Widget> orderNotesWidgetData = [];

    orderNotesWidgetData.add(
      Row(
        children: <Widget>[
          Expanded(
            child: RaisedButton(
              child: Text("Add Order Note",
                  style: Theme.of(context).textTheme.body1.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      )),
              color: Theme.of(context).primaryColor,
              onPressed: () async {
                return showDialog<void>(
                    context: context,
                    barrierDismissible: false,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text("Add Order Note"),
                        titlePadding: EdgeInsets.fromLTRB(15, 20, 15, 0),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Row(
                              children: <Widget>[
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    "Is Customer Note?",
                                    style: Theme.of(context).textTheme.body1,
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: Center(
                                    child: Switch(
                                        value: isCustomerNewOrderNote,
                                        onChanged: (bool value) {
                                          setState(() {
                                            isCustomerNewOrderNote = value;
                                          });
                                        }),
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: <Widget>[
                                Expanded(
                                  child: TextField(
                                    decoration: InputDecoration(
                                        border: OutlineInputBorder(),
                                        hintText: "Add order note here...",
                                        hintStyle:
                                            Theme.of(context).textTheme.body1),
                                    keyboardType: TextInputType.multiline,
                                    maxLines: 4,
                                    style: Theme.of(context).textTheme.body1,
                                    onChanged: (value) {
                                      setState(() {
                                        newOrderNote = value;
                                      });
                                    },
                                  ),
                                )
                              ],
                            )
                          ],
                        ),
                        contentPadding: EdgeInsets.fromLTRB(15, 10, 15, 0),
                        actions: <Widget>[
                          FlatButton(
                            child: Text("No"),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                          FlatButton(
                            child: Text("Yes"),
                            onPressed: () {
                              addOrderNote();
                              Navigator.of(context).pop();
                            },
                          )
                        ],
                      );
                    });
              },
            ),
          ),
        ],
      ),
    );

    if (!isOrderNotesDataReady && !isOrderNotesDataError) {
      orderNotesWidgetData.add(Container(
        height: 100,
        child: Center(
          child: SpinKitPulse(
            color: Theme.of(context).primaryColor,
            size: 50,
          ),
        ),
      ));
    }

    if (isOrderNotesDataError && !isOrderNotesDataReady) {
      orderNotesWidgetData.add(Container(
        height: 200,
        child: Center(
          child: Text(
            orderNotesDataError,
            textAlign: TextAlign.center,
          ),
        ),
      ));
    }

    if (isOrderNotesDataReady) {
      orderNotesData.forEach((item) {
        if (item is Map &&
            (item.containsKey("note") ||
                item.containsKey("date_created") ||
                item.containsKey("author") ||
                item.containsKey("customer_note"))) {
          orderNotesWidgetData.add(Card(
            color: (item["customer_note"] is bool && item["customer_note"])
                ? Colors.purple[100]
                : Colors.white,
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          item.containsKey("note") && item["note"] is String
                              ? Linkify(
                                  text: item["note"],
                                  style: Theme.of(context)
                                      .textTheme
                                      .body1
                                      .copyWith(fontSize: 16),
                                  onOpen: (link) async {
                                    if (await canLaunch(link.url)) {
                                      await launch(link.url);
                                    }
                                  },
                                  options: LinkifyOptions(humanize: false),
                                )
                              : SizedBox.shrink(),
                          item.containsKey("author") &&
                                  item["author"] is String &&
                                  item.containsKey("date_created") &&
                                  item["date_created"] is String
                              ? Text(
                                  "Note added" +
                                      (item["author"].toString().isNotEmpty
                                          ? " by ${item["author"]}"
                                          : "") +
                                      (item["date_created"]
                                              .toString()
                                              .isNotEmpty
                                          ? " at " +
                                              DateFormat(
                                                      "EEEE, d/M/y h:mm:ss a")
                                                  .format(DateTime.parse(
                                                      item["date_created"]))
                                          : ""),
                                  style: Theme.of(context)
                                      .textTheme
                                      .body1
                                      .copyWith(fontSize: 12),
                                )
                              : SizedBox.shrink(),
                        ]),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(15),
                  child: Center(
                    child: GestureDetector(
                      child: Icon(
                        Icons.delete,
                        color: Colors.red,
                      ),
                      onTap: () async {
                        return showDialog<void>(
                            context: context,
                            barrierDismissible: false,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text("Delete Order Note"),
                                titlePadding:
                                    EdgeInsets.fromLTRB(15, 20, 15, 0),
                                content: Text(
                                  "Do you really want to delete this order note?",
                                  style: Theme.of(context).textTheme.body1,
                                ),
                                contentPadding:
                                    EdgeInsets.fromLTRB(15, 10, 15, 0),
                                actions: <Widget>[
                                  FlatButton(
                                    child: Text("No"),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                  FlatButton(
                                    child: Text("Yes"),
                                    onPressed: () {
                                      if (item.containsKey("id") &&
                                          item["id"] is int) {
                                        deleteOrderNote(item["id"]);
                                      }
                                      Navigator.of(context).pop();
                                    },
                                  )
                                ],
                              );
                            });
                      },
                    ),
                  ),
                )
              ],
            ),
          ));
        }
      });
    }
    orderNotesWidget = ExpansionTile(
      title: Text(
        "Order Notes",
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
                    children: orderNotesWidgetData),
              ),
            ),
          ],
        )
      ],
    );
    return orderNotesWidget;
  }
}

class LineItemsProductsImage extends StatefulWidget {
  final String baseurl;
  final String username;
  final String password;
  final int id;

  LineItemsProductsImage(
      {Key key,
      @required this.baseurl,
      @required this.username,
      @required this.password,
      @required this.id})
      : super(key: key);

  @override
  _LineItemsProductsImageState createState() => _LineItemsProductsImageState();
}

class _LineItemsProductsImageState extends State<LineItemsProductsImage> {
  bool isProductDataReady = false;
  Map productData = {};
  bool isProductDataError = false;

  @override
  void initState() {
    super.initState();
    fetchLineItemsDetails(widget.id);
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  Widget build(BuildContext context) {
    return isProductDataError
        ? SizedBox(
            height: 140,
            width: 140,
          )
        : (isProductDataReady &&
                productData.containsKey("images") &&
                productData["images"] is List &&
                productData["images"].isNotEmpty &&
                productData["images"][0] is Map &&
                productData["images"][0].containsKey("src") &&
                productData["images"][0]["src"] is String)
            ? ExtendedImage.network(
                productData["images"][0]["src"],
                height: 140,
                width: 140,
                fit: BoxFit.contain,
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
              )
            : Container(
                height: 140,
                width: 140,
                child: Center(
                  child: SpinKitPulse(
                    color: Theme.of(context).primaryColor,
                    size: 50,
                  ),
                ),
              );
  }

  Future<Null> fetchLineItemsDetails(int productId) async {
    String url =
        "${widget.baseurl}/wp-json/wc/v3/products/$productId?consumer_key=${widget.username}&consumer_secret=${widget.password}";
    setState(() {
      isProductDataError = false;
      isProductDataReady = false;
    });
    try {
      final http.Response response = await http.get(url);
      if (response.statusCode == 200) {
        if (json.decode(response.body) is Map &&
            json.decode(response.body).containsKey("id")) {
          setState(() {
            productData = json.decode(response.body);
            isProductDataReady = true;
            isProductDataError = false;
          });
        } else {
          setState(() {
            isProductDataReady = false;
            isProductDataError = true;
          });
        }
      } else {
        setState(() {
          isProductDataReady = false;
          isProductDataError = true;
        });
      }
    } catch (e) {
      setState(() {
        isProductDataReady = false;
        isProductDataError = true;
      });
    }
  }
}
