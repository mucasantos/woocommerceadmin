import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import 'package:recase/recase.dart';
import 'package:woocommerceadmin/src/orders/models/order.dart';
import 'package:woocommerceadmin/src/orders/providers/order_provider.dart';
import 'package:woocommerceadmin/src/orders/providers/order_providers_list.dart';

class ChangeOrderStatusModal extends StatefulWidget {
  final String baseurl;
  final String username;
  final String password;
  final int orderId;
  final GlobalKey<ScaffoldState> scaffoldKey;

  ChangeOrderStatusModal({
    Key key,
    @required this.baseurl,
    @required this.username,
    @required this.password,
    @required this.orderId,
    @required this.scaffoldKey,
  }) : super(key: key);

  @override
  _ChangeOrderStatusModalState createState() => _ChangeOrderStatusModalState();
}

class _ChangeOrderStatusModalState extends State<ChangeOrderStatusModal> {
  bool isInit = true;

  bool isOrderStatusOptionsReady = false;
  bool isOrderStatusOptionsError = false;
  String orderStatusOptionsError;
  List<String> orderStatusOptionsList = [];

  int selectedIndex = -1;

  @override
  void didChangeDependencies() {
    if (isInit) {
      fetchOrderStatusOptions(
          baseurl: widget.baseurl,
          username: widget.username,
          password: widget.password);
    }
    isInit = false;
    super.didChangeDependencies();
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Change Order Status"),
      titlePadding: EdgeInsets.fromLTRB(15, 20, 15, 0),
      content: Container(
          height: 300,
          child: isOrderStatusOptionsError
              ? SingleChildScrollView(
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                          child: Text(
                            orderStatusOptionsError,
                            style: Theme.of(context).textTheme.body1,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : !isOrderStatusOptionsReady
                  ? Container(
                      child: Center(
                        child: SpinKitPulse(
                          color: Theme.of(context).primaryColor,
                          size: 50,
                        ),
                      ),
                    )
                  : Column(
                      children:
                          orderStatusOptionsList.asMap().entries.map((item) {
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedIndex = item.key;
                            });
                          },
                          child: Row(
                            children: <Widget>[
                              SizedBox(
                                height: 30,
                                child: Radio(
                                  groupValue: selectedIndex,
                                  value: item.key,
                                  onChanged: (int value) {
                                    setState(() {
                                      selectedIndex = value;
                                    });
                                  },
                                ),
                              ),
                              Text(
                                item.value.titleCase,
                                style: Theme.of(context).textTheme.body1,
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    )),
      contentPadding: EdgeInsets.fromLTRB(15, 10, 15, 0),
      actions: <Widget>[
        FlatButton(
          child: Text("Cancel"),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        if (isOrderStatusOptionsReady && selectedIndex >= 0)
          FlatButton(
            child: Text("Apply"),
            onPressed: () async {
              await updateOrder(
                  baseurl: widget.baseurl,
                  username: widget.username,
                  password: widget.password,
                  orderId: widget.orderId,
                  orderStatus: orderStatusOptionsList[selectedIndex]);
              Navigator.of(context).pop();
            },
          )
      ],
    );
  }

  Future<void> fetchOrderStatusOptions({
    @required String baseurl,
    @required String username,
    @required String password,
  }) async {
    String url =
        "$baseurl/wp-json/wc/v3/reports/orders/totals?consumer_key=$username&consumer_secret=$password";
    setState(() {
      isOrderStatusOptionsReady = false;
      isOrderStatusOptionsError = false;
    });
    http.Response response;
    try {
      response = await http.get(url);
      if (response.statusCode == 200) {
        dynamic responseBody = json.decode(response.body);
        if (responseBody is List && responseBody.isNotEmpty) {
          List<String> tempList = [];
          responseBody.forEach((item) {
            if (item is Map &&
                item.containsKey("slug") &&
                item["slug"] is String &&
                item["slug"].isNotEmpty) {
              tempList.add(item["slug"]);
            }
          });
          setState(() {
            isOrderStatusOptionsReady = true;
            orderStatusOptionsList = tempList;
            selectedIndex = tempList.indexOf(
                Provider.of<OrderProvider>(context, listen: false)
                        .order
                        .status ??
                    "");
          });
        } else {
          setState(() {
            isOrderStatusOptionsReady = false;
            isOrderStatusOptionsError = true;
            orderStatusOptionsError = "Failed to fetch order status options";
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
          isOrderStatusOptionsReady = false;
          isOrderStatusOptionsError = true;
          orderStatusOptionsError =
              "Failed to fetch order status options. Error: $errorCode";
        });
      }
    } catch (e) {
      setState(() {
        isOrderStatusOptionsReady = false;
        isOrderStatusOptionsError = true;
        orderStatusOptionsError =
            "Failed to fetch order status options. Error: $e";
      });
    }
  }

  //Update Order
  Future<void> updateOrder({
    @required String baseurl,
    @required String username,
    @required String password,
    @required int orderId,
    @required String orderStatus,
  }) async {
    final String url =
        "$baseurl/wp-json/wc/v3/orders/$orderId?consumer_key=$username&consumer_secret=$password";
    setState(() {
      isOrderStatusOptionsReady = false;
    });

    http.Response response;
    try {
      response = await http.put(
        url,
        headers: {
          HttpHeaders.contentTypeHeader: "application/json",  
        },
        body: json.encode({"status": orderStatus}),
      );
      dynamic responseBody = json.decode(response.body);
      if (response.statusCode == 200) {
        if (responseBody is Map && responseBody.containsKey("id")) {
          final OrderProvider orderProvider =
              Provider.of<OrderProvider>(context, listen: false);
          orderProvider.replaceOrder(Order.fromJson(responseBody));
          final OrderProvidersList orderProvidersList =
              Provider.of<OrderProvidersList>(context, listen: false);
          orderProvidersList.replaceOrderProviderById(orderId, orderProvider);

          widget.scaffoldKey.currentState.showSnackBar(
            SnackBar(
              content: Text("Order updated successfully..."),
              duration: Duration(seconds: 3),
            ),
          );
          setState(() {
            isOrderStatusOptionsReady = true;
          });
        }
      } else {
        String errorCode = "";
        if (responseBody is Map && responseBody.containsKey("code")) {
          errorCode = responseBody["code"];
        }
        widget.scaffoldKey.currentState.showSnackBar(
          SnackBar(
            content: Text("Failed to update order. Error: $errorCode"),
            duration: Duration(seconds: 3),
          ),
        );
        setState(() {
          isOrderStatusOptionsReady = true;
        });
      }
    } on SocketException catch (_) {
      widget.scaffoldKey.currentState.showSnackBar(
        SnackBar(
          content: Text("Failed to update order. Error: Network not reachable"),
          duration: Duration(seconds: 3),
        ),
      );
      setState(() {
        isOrderStatusOptionsReady = true;
      });
    } catch (e) {
      widget.scaffoldKey.currentState.showSnackBar(
        SnackBar(
          content: Text("Failed to update order. Error: $e"),
          duration: Duration(seconds: 3),
        ),
      );
      setState(() {
        isOrderStatusOptionsReady = true;
      });
    }
  }
}
