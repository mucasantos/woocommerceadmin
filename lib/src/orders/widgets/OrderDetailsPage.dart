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
import 'package:woocommerceadmin/src/orders/widgets/ChangeOrderStatusModal.dart';
import 'package:woocommerceadmin/src/products/widgets/ProductDetailsPage.dart';

class OrderDetailsPage extends StatefulWidget {
  final String baseurl;
  final String username;
  final String password;
  final int id;

  OrderDetailsPage(
      {Key key,
      @required this.baseurl,
      @required this.username,
      @required this.password,
      @required this.id})
      : super(key: key);

  @override
  _OrderDetailsPageState createState() => _OrderDetailsPageState();
}

class _OrderDetailsPageState extends State<OrderDetailsPage> {
  bool isOrderDataReady = false;
  bool isError = false;
  Map orderDetails = Map();
  Map lineItemsDetails = {};

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
    super.initState();
    fetchOrderDetails();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        title: Text("Orders Details"),
      ),
      body: !isOrderDataReady
          ? !isError ? _mainLoadingWidget() : Text("Error Fetching Data")
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
          Map orderData = json.decode(response.body);

          // if (orderData.containsKey("line_items") &&
          //     orderData["line_items"] != null &&
          //     // orderData["line_items"].runtimeType == List &&
          //     orderData["line_items"].length > 0) {
          //   for (int i = 0; i < orderData["line_items"].length; i++) {
          //     String productId = "${orderData["line_items"][i]["product_id"]}";
          //     setState(() {
          //       lineItemsDetails.putIfAbsent(
          //           productId, () => {"ready": false, "data": {}});
          //     });
          //   }
          // }

          setState(() {
            orderDetails = orderData;
            isOrderDataReady = true;
            isError = false;
          });
          fetchOrderNotes();
        } else {
          setState(() {
            isOrderDataReady = false;
            isError = true;
          });
        }
      } else {
        setState(() {
          isOrderDataReady = false;
          isError = true;
        });
      }
    } catch (e) {
      setState(() {
        isOrderDataReady = false;
        isError = true;
      });
    }
  }

  Future<Null> fetchLineItemsDetails(String productId) async {
    String url =
        "${widget.baseurl}/wp-json/wc/v3/products/$productId?consumer_key=${widget.username}&consumer_secret=${widget.password}";
    if (isOrderDataReady) {
      final http.Response response = await http.get(url);
      if (response.statusCode == 200) {
        if (json.decode(response.body) is Map &&
            json.decode(response.body).containsKey("id")) {
          orderDetails = json.decode(response.body);
          // lineItemsDetails.update(productId,
          //     (oldData) => {"ready": true, "data": json.decode(response.body)},
          //     ifAbsent: () =>
          //         {"ready": true, "data": json.decode(response.body)});
          // print(lineItemsDetails);
          // setState(() {
          //   lineItemsDetails.update(
          //       productId,
          //       (oldData) =>
          //           {"ready": true, "data": json.decode(response.body)},
          //       ifAbsent: () =>
          //           {"ready": true, "data": json.decode(response.body)});
          // });
        } else {
          setState(() {
            lineItemsDetails.update(
                productId, (oldData) => {"ready": false, "data": {}},
                ifAbsent: () => {"ready": false, "data": {}});
          });
        }
      } else {
        setState(() {
          lineItemsDetails.update(
              productId, (oldData) => {"ready": false, "data": {}},
              ifAbsent: () => {"ready": false, "data": {}});
        });
      }
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
      response = await http.put(url, body: {
        "status": orderStatus
      });
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
      print(json.decode(response.body));
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
    } catch (e) {
      scaffoldKey.currentState.showSnackBar(SnackBar(
        content: Text("Failed to delete order note. Error: $e"),
        duration: Duration(seconds: 3),
      ));
    }
  }

  Widget _mainLoadingWidget() {
    Widget mainLoadingWidget = SizedBox.shrink();
    if (!isOrderDataReady && !isError) {
      mainLoadingWidget = Container(
        child: Center(
          child: SpinKitFadingCube(
            color: Theme.of(context).primaryColor,
            size: 30.0,
          ),
        ),
      );
    }
    return mainLoadingWidget;
  }

  Widget _orderGeneralWidget() {
    Widget orderGeneralWidget = SizedBox.shrink();
    List<Widget> orderGeneralData = [];
    if (isOrderDataReady &&
        (orderDetails.containsKey("id") ||
            orderDetails.containsKey("date_created") ||
            orderDetails.containsKey("status"))) {
      if (isOrderDataReady &&
          orderDetails.containsKey("id") &&
          orderDetails["id"] != null) {
        orderGeneralData.add(Text("Order ID: ${orderDetails["id"]}"));
      }

      if (isOrderDataReady &&
          orderDetails.containsKey("date_created") &&
          orderDetails["date_created"] is String) {
        orderGeneralData.add(Text(
          "Created: " +
              DateFormat("EEEE, d/M/y h:mm:ss a")
                  .format(DateTime.parse(orderDetails["date_created"])),
        ));
      }

      if (isOrderDataReady &&
          orderDetails.containsKey("status") &&
          orderDetails["status"] is String) {
        orderGeneralData.add(
          Row(
            children: <Widget>[
              Text("Order Status: " +
                  orderDetails["status"].toString().titleCase),
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
                          orderStatus: orderDetails["status"],
                          onSubmit: (String newOrderStatus) {
                            updateOrder(newOrderStatus);
                          },
                        );
                      });
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
        orderDetails.containsKey("line_items") &&
        orderDetails["line_items"] is List &&
        orderDetails["line_items"].isNotEmpty) {
      for (int i = 0; i < orderDetails["line_items"].length; i++) {
        List<Widget> orderProductsData = [];
        Widget lineItemsPrimaryImage = SizedBox(
          height: 120,
          width: 120,
        );

        if (orderDetails["line_items"][i].containsKey("product_id") &&
            orderDetails["line_items"][i]["product_id"] != null) {
          // String productId = "${orderDetails["line_items"][i]["product_id"]}";
          // fetchLineItemsDetails(productId);
          // print(lineItemsDetails);
          // if (lineItemsDetails.containsKey(productId) &&
          //     lineItemsDetails["$productId"]["ready"]) {
          //   if (lineItemsDetails["$productId"]["data"].containsKey("images") &&
          //       lineItemsDetails["$productId"]["data"]["images"] != null &&
          //       lineItemsDetails["$productId"]["data"]["images"].length > 0 &&
          //       lineItemsDetails["$productId"]["data"]["images"][0]
          //           .containsKey("src") &&
          //       lineItemsDetails["$productId"]["data"]["images"][0]["src"]
          //           .runtimeType is String) {
          //     String primaryImageSrc =
          //         lineItemsDetails["$productId"]["data"]["images"][0]["src"];
          //     print(primaryImageSrc);
          //     // lineItemsPrimaryImage = Image.network(lineItemsDetails["$productId"]["data"]["images"][0]["src"]);
          //   }
          // }
        }

        if (orderDetails["line_items"][i].containsKey("name") &&
            orderDetails["line_items"][i]["name"] is String &&
            orderDetails["line_items"][i]["name"].toString().isNotEmpty) {
          orderProductsData.add(Text(
            "${orderDetails["line_items"][i]["name"]}",
            style: Theme.of(context)
                .textTheme
                .body1
                .copyWith(fontWeight: FontWeight.bold),
          ));
        }

        if (orderDetails["line_items"][i].containsKey("sku") &&
            orderDetails["line_items"][i]["sku"] is String) {
          orderProductsData
              .add(Text("SKU: ${orderDetails["line_items"][i]["sku"]}"));
        }

        if (orderDetails["line_items"][i].containsKey("price") &&
            orderDetails["line_items"][i]["price"] is String) {
          orderProductsData
              .add(Text("Price: ${orderDetails["line_items"][i]["price"]}"));
        }

        if (orderDetails["line_items"][i].containsKey("quantity") &&
            orderDetails["line_items"][i]["quantity"] is int) {
          orderProductsData
              .add(Text("Qty: ${orderDetails["line_items"][i]["quantity"]}"));
        }

        if (orderDetails["line_items"][i].containsKey("meta_data") &&
            orderDetails["line_items"][i]["meta_data"] is List &&
            orderDetails["line_items"][i]["meta_data"].isNotEmpty) {
          for (int metaDataIndex = 0;
              metaDataIndex < orderDetails["line_items"][i]["meta_data"].length;
              metaDataIndex++) {
            if (orderDetails["line_items"][i]["meta_data"][metaDataIndex]
                    .containsKey("key") &&
                orderDetails["line_items"][i]["meta_data"][metaDataIndex]
                        ["key"] !=
                    null &&
                orderDetails["line_items"][i]["meta_data"][metaDataIndex]
                        ["key"] ==
                    "_tmcartepo_data") {
              orderProductsData.add(Text(orderDetails["line_items"][i]
                      ["meta_data"][metaDataIndex]["value"][0]["name"] +
                  ": " +
                  orderDetails["line_items"][i]["meta_data"][metaDataIndex]
                      ["value"][0]["value"]));
            }
          }
        }

        orderProductsCardData.add(Card(
          child: InkWell(
            onTap: () {
              if (orderDetails["line_items"][i].containsKey("product_id") &&
                  orderDetails["line_items"][i]["product_id"] is int) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ProductDetailsPage(
                            baseurl: widget.baseurl,
                            username: widget.username,
                            password: widget.password,
                            id: orderDetails["line_items"][i]["product_id"],
                          )),
                );
              }
            },
            child: Row(
              children: <Widget>[
                lineItemsPrimaryImage,
                Expanded(
                    child: Padding(
                  padding: EdgeInsets.all(10.0),
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
        (orderDetails.containsKey("payment_method_title") ||
            orderDetails.containsKey("total") ||
            orderDetails.containsKey("shipping_total") ||
            orderDetails.containsKey("total_tax"))) {
      if (orderDetails.containsKey("payment_method_title") &&
          orderDetails["payment_method_title"] is String &&
          orderDetails["payment_method_title"].isNotEmpty) {
        orderPaymentData.add(
            Text("Payment Gateway: ${orderDetails["payment_method_title"]}"));
      }

      if (orderDetails.containsKey("total") &&
          orderDetails["total"] is String &&
          orderDetails["total"].isNotEmpty) {
        orderPaymentData.add(
          Text(
            "Order Total: ${orderDetails["total"]}",
            style: Theme.of(context)
                .textTheme
                .body1
                .copyWith(fontWeight: FontWeight.bold),
          ),
        );
      }

      if (orderDetails.containsKey("total_tax") &&
          orderDetails["total_tax"] is String &&
          orderDetails["total_tax"].isNotEmpty) {
        orderPaymentData.add(Text("Taxes: " + orderDetails["total_tax"]));
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
        orderDetails.containsKey("shipping") &&
        orderDetails["shipping"] is Map) {
      if (orderDetails["shipping"].containsKey("first_name") &&
          orderDetails["shipping"]["first_name"] is String &&
          orderDetails["shipping"]["first_name"].isNotEmpty) {
        shippingName += orderDetails["shipping"]["first_name"];
      }
      if (orderDetails["shipping"].containsKey("last_name") &&
          orderDetails["shipping"]["last_name"] is String &&
          orderDetails["shipping"]["last_name"].isNotEmpty) {
        shippingName += " ${orderDetails["shipping"]["last_name"]}";
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

      if (orderDetails["shipping"].containsKey("address_1") &&
          orderDetails["shipping"]["address_1"] is String &&
          orderDetails["shipping"]["address_1"].isNotEmpty) {
        shippingAddress = orderDetails["shipping"]["address_1"].toString();
      }

      if (orderDetails["shipping"].containsKey("address_2") &&
          orderDetails["shipping"]["address_2"] is String &&
          orderDetails["shipping"]["address_2"].isNotEmpty) {
        shippingAddress += " ${orderDetails["shipping"]["address_2"]}";
      }

      if (orderDetails["shipping"].containsKey("city") &&
          orderDetails["shipping"]["city"] is String &&
          orderDetails["shipping"]["city"].isNotEmpty) {
        shippingAddress += " ${orderDetails["shipping"]["city"]}";
      }

      if (orderDetails["shipping"].containsKey("state") &&
          orderDetails["shipping"]["state"] is String &&
          orderDetails["shipping"]["state"].isNotEmpty) {
        shippingAddress += " ${orderDetails["shipping"]["state"]}";
      }

      if (orderDetails["shipping"].containsKey("postcode") &&
          orderDetails["shipping"]["postcode"] is String &&
          orderDetails["shipping"]["postcode"].isNotEmpty) {
        shippingAddress += " ${orderDetails["shipping"]["postcode"]}";
      }

      if (orderDetails["shipping"].containsKey("country") &&
          orderDetails["shipping"]["country"] is String &&
          orderDetails["shipping"]["country"].isNotEmpty) {
        shippingAddress += " ${orderDetails["shipping"]["country"]}";
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
        orderDetails.containsKey("billing") &&
        orderDetails["billing"] != null) {
      if (orderDetails["billing"].containsKey("first_name") &&
          orderDetails["billing"]["first_name"] is String &&
          orderDetails["billing"]["first_name"].isNotEmpty) {
        billingName += orderDetails["billing"]["first_name"];
      }
      if (orderDetails["billing"].containsKey("last_name") &&
          orderDetails["billing"]["last_name"] is String &&
          orderDetails["billing"]["last_name"].isNotEmpty) {
        billingName += " ${orderDetails["billing"]["last_name"]}";
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

      if (orderDetails["billing"].containsKey("phone") &&
          orderDetails["billing"]["phone"] is String &&
          orderDetails["billing"]["phone"].isNotEmpty) {
        orderBillingWidgetData.add(RichText(
            text: TextSpan(
                text: "Phone: ",
                style: Theme.of(context).textTheme.body1.copyWith(fontSize: 18),
                children: [
              TextSpan(
                text: orderDetails["billing"]["phone"],
                style: TextStyle(color: Colors.blue),
                recognizer: TapGestureRecognizer()
                  ..onTap = () {
                    launch("tel:${orderDetails["billing"]["phone"]}");
                  },
              )
            ])));
      }

      if (orderDetails["billing"].containsKey("email") &&
          orderDetails["billing"]["email"] is String &&
          orderDetails["billing"]["email"].isNotEmpty) {
        orderBillingWidgetData.add(RichText(
            text: TextSpan(
                text: "Email: ",
                style: Theme.of(context).textTheme.body1.copyWith(fontSize: 18),
                children: [
              TextSpan(
                text: orderDetails["billing"]["email"],
                style: TextStyle(color: Colors.blue),
                recognizer: TapGestureRecognizer()
                  ..onTap = () {
                    launch("mailto:${orderDetails["billing"]["email"]}");
                  },
              )
            ])));
      }

      if (orderDetails["billing"].containsKey("address_1") &&
          orderDetails["billing"]["address_1"] is String &&
          orderDetails["billing"]["address_1"].isNotEmpty) {
        billingAddress = orderDetails["billing"]["address_1"].toString();
      }

      if (orderDetails["billing"].containsKey("address_2") &&
          orderDetails["billing"]["address_2"] is String &&
          orderDetails["billing"]["address_2"].isNotEmpty) {
        billingAddress += " ${orderDetails["billing"]["address_2"]}";
      }

      if (orderDetails["billing"].containsKey("city") &&
          orderDetails["billing"]["city"] is String &&
          orderDetails["billing"]["city"].isNotEmpty) {
        billingAddress += " ${orderDetails["billing"]["city"]}";
      }

      if (orderDetails["billing"].containsKey("state") &&
          orderDetails["billing"]["state"] is String &&
          orderDetails["billing"]["state"].isNotEmpty) {
        billingAddress += " ${orderDetails["billing"]["state"]}";
      }

      if (orderDetails["billing"].containsKey("postcode") &&
          orderDetails["billing"]["postcode"] is String &&
          orderDetails["billing"]["postcode"].isNotEmpty) {
        billingAddress += " ${orderDetails["billing"]["postcode"]}";
      }

      if (orderDetails["billing"].containsKey("country") &&
          orderDetails["billing"]["country"] is String &&
          orderDetails["billing"]["country"].isNotEmpty) {
        billingAddress += " ${orderDetails["billing"]["country"]}";
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
          child: SpinKitFadingCube(
            color: Theme.of(context).primaryColor,
            size: 30,
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
                                      .copyWith(fontSize: 18),
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
