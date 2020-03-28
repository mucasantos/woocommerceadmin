import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:recase/recase.dart';
import 'package:woocommerceadmin/src/orders/widgets/OrderDetailsPage.dart';

class OrdersListPage extends StatefulWidget {
  @override
  _OrdersListPageState createState() => _OrdersListPageState();
}

class _OrdersListPageState extends State<OrdersListPage> {
  String baseurl = "https://www.kalashcards.com";
  String username = "ck_33c3f3430550132c2840167648ea0b3ab2d56941";
  String password = "cs_f317f1650e418657d745eabf02e955e2c70bba46";
  List ordersListData = List();
  int page = 1;
  bool hasMoreToLoad = true;
  bool isListLoading = false;

  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      new GlobalKey<RefreshIndicatorState>();

  @override
  void initState() {
    super.initState();
    fetchOrdersList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Orders List"),
      ),
      body: RefreshIndicator(
        key: _refreshIndicatorKey,
        onRefresh: handleRefresh,
        child: Column(
          children: <Widget>[
            Expanded(
              child: NotificationListener<ScrollNotification>(
                onNotification: (ScrollNotification scrollInfo) {
                  if (hasMoreToLoad &&
                      !isListLoading &&
                      scrollInfo.metrics.pixels ==
                          scrollInfo.metrics.maxScrollExtent) {
                    handleLoadMore();
                  }
                },
                child: ListView.builder(
                    itemCount: ordersListData.length,
                    itemBuilder: (BuildContext context, int index) {
                      return Card(
                        child: InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => OrderDetailsPage(
                                        id: ordersListData[index]["id"],
                                      )),
                            );
                          },
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              mainAxisSize: MainAxisSize.max,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: <Widget>[
                                          _orderDate(ordersListData[index]),
                                          _orderIdAndBillingName(
                                              ordersListData[index]),
                                          _orderStatus(ordersListData[index]),
                                          _orderTotal(ordersListData[index])
                                        ]),
                                  ),
                                )
                              ]),
                        ),
                      );
                    }),
              ),
            ),
            if (isListLoading)
              Container(
                height: 60.0,
                color: Colors.white,
                child: Center(
                    child: SpinKitFadingCube(
                  color: Colors.purple,
                  size: 30.0,
                )),
              ),
          ],
        ),
      ),
    );
  }

  fetchOrdersList() async {
    String url =
        "$baseurl/wp-json/wc/v3/orders?page=$page&per_page=20&consumer_key=$username&consumer_secret=$password";
    setState(() {
      isListLoading = true;
    });
    final response = await http.get(url);
    if (response.statusCode == 200) {
      if (json.decode(response.body) is List &&
          !json.decode(response.body).isEmpty) {
        setState(() {
          hasMoreToLoad = true;
          ordersListData.addAll(json.decode(response.body));
          isListLoading = false;
        });
      } else {
        setState(() {
          hasMoreToLoad = false;
          isListLoading = false;
        });
      }
    } else {
      setState(() {
        hasMoreToLoad = false;
        isListLoading = false;
      });
      throw Exception("Failed to get response.");
    }
  }

  handleLoadMore() async {
    setState(() {
      page++;
    });
    await fetchOrdersList();
  }

  Future<void> handleRefresh() async {
    setState(() {
      page = 1;
      ordersListData = [];
    });
    await fetchOrdersList();
  }

  Widget _orderDate(Map orderDetailsMap) {
    Widget orderDateWidget = SizedBox();
    if (orderDetailsMap.containsKey("date_created") &&
        orderDetailsMap["date_created"] != null)
      orderDateWidget = Text(
        DateFormat("EEEE, d/M/y h:mm:ss a")
            .format(DateTime.parse(orderDetailsMap["date_created"])),
      );
    return orderDateWidget;
  }

  Widget _orderIdAndBillingName(Map orderDetailsMap) {
    Widget orderIdAndBillingNameWidget = SizedBox();
    String orderId = "";
    String billingName = "";
    if (orderDetailsMap.containsKey("id") && orderDetailsMap["id"] != null) {
      orderId = "#${orderDetailsMap["id"]}";
    }
    if (orderDetailsMap.containsKey("billing") &&
        orderDetailsMap["billing"] != null) {
      if (orderDetailsMap["billing"].containsKey("first_name") &&
          orderDetailsMap["billing"]["first_name"] != null) {
        billingName =
            billingName + orderDetailsMap["billing"]["first_name"].toString();
      }
      if (orderDetailsMap["billing"].containsKey("last_name") &&
          orderDetailsMap["billing"]["last_name"] != null) {
        if (billingName.isNotEmpty) {
          billingName = billingName + " ";
        }
        billingName =
            billingName + orderDetailsMap["billing"]["last_name"].toString();
      }
      orderIdAndBillingNameWidget = Text(
        "$orderId $billingName",
        style: Theme.of(context)
            .textTheme
            .body1
            .copyWith(fontSize: 20.0, fontWeight: FontWeight.bold),
      );
    }
    return orderIdAndBillingNameWidget;
  }

  Widget _orderStatus(Map orderDetailsMap) {
    Widget orderStatusWidget = SizedBox();
    if (orderDetailsMap.containsKey("status") &&
        orderDetailsMap["status"] != null)
      orderStatusWidget = Text(
        "Status: " + orderDetailsMap["status"].toString().titleCase,
      );
    return orderStatusWidget;
  }

  Widget _orderTotal(Map orderDetailsMap) {
    Widget orderTotalWidget = SizedBox();
    if (orderDetailsMap.containsKey("total") &&
        orderDetailsMap["total"] != null)
      orderTotalWidget = Text(
        "Total: " +
            ((orderDetailsMap.containsKey("currency_symbol") &&
                    orderDetailsMap["currency_symbol"] != null)
                ? orderDetailsMap["currency_symbol"]
                : (orderDetailsMap.containsKey("currency") &&
                        orderDetailsMap["currency"] != null)
                    ? orderDetailsMap["currency"]
                    : "") +
            orderDetailsMap["total"],
      );
    return orderTotalWidget;
  }
}
