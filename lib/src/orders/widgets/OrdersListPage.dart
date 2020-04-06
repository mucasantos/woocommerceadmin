import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:recase/recase.dart';
import 'package:woocommerceadmin/src/orders/widgets/OrderDetailsPage.dart';
import 'package:barcode_scan/barcode_scan.dart';
import 'package:woocommerceadmin/src/orders/widgets/OrdersListFiltersModal.dart';

class OrdersListPage extends StatefulWidget {
  final String baseurl;
  final String username;
  final String password;

  OrdersListPage({
    Key key,
    @required this.baseurl,
    @required this.username,
    @required this.password,
  }) : super(key: key);

  @override
  _OrdersListPageState createState() => _OrdersListPageState();
}

class _OrdersListPageState extends State<OrdersListPage> {
  List ordersListData = List();
  int page = 1;
  bool hasMoreToLoad = true;
  bool isListLoading = false;

  bool isSearching = false;
  String searchValue = "";

  String sortOrderByValue = "date";
  String sortOrderValue = "desc";
  Map<String, bool> orderStatusOptions = {};

  final scaffoldKey = new GlobalKey<ScaffoldState>();
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
      key: scaffoldKey,
      appBar: _myAppBar(),
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
                                  baseurl: widget.baseurl,
                                  username: widget.username,
                                  password: widget.password,
                                  id: ordersListData[index]["id"],
                                ),
                              ),
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

  Future<void> fetchOrdersList() async {
    String url =
        "${widget.baseurl}/wp-json/wc/v3/orders?page=$page&per_page=20&consumer_key=${widget.username}&consumer_secret=${widget.password}";
    if (searchValue is String && searchValue.isNotEmpty) {
      url += "&search=$searchValue";
    }
    if (sortOrderByValue is String && sortOrderByValue.isNotEmpty) {
      url += "&orderby=$sortOrderByValue";
    }
    if (sortOrderValue is String && sortOrderValue.isNotEmpty) {
      url += "&order=$sortOrderValue";
    }
    if (orderStatusOptions is Map && orderStatusOptions.isNotEmpty) {
      orderStatusOptions.forEach((k, v) {
        if (v) {
          url += "&status[]=$k";
        }
      });
    }
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

  Future<void> handleLoadMore() async {
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

  Future<void> scanBarcode() async {
    try {
      String barcode = await BarcodeScanner.scan();
      setState(() {
        searchValue = barcode;
      });
      handleRefresh();
    } on PlatformException catch (e) {
      if (e.code == BarcodeScanner.CameraAccessDenied) {
        scaffoldKey.currentState.showSnackBar(SnackBar(
          content: Text("Camera permission is not granted"),
          duration: Duration(seconds: 3),
        ));
      } else {
        scaffoldKey.currentState.showSnackBar(SnackBar(
          content: Text("Unknown barcode scan error: $e"),
          duration: Duration(seconds: 3),
        ));
      }
    } on FormatException {
      scaffoldKey.currentState.showSnackBar(SnackBar(
        content: Text("Barcode scan cancelled"),
        duration: Duration(seconds: 3),
      ));
    } catch (e) {
      scaffoldKey.currentState.showSnackBar(SnackBar(
        content: Text("Unknown barcode scan error: $e"),
        duration: Duration(seconds: 3),
      ));
    }
  }

  Widget _myAppBar() {
    Widget myAppBar;

    if (isSearching) {
      myAppBar = AppBar(
        title: Row(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(right: 10),
              child: Icon(Icons.search),
            ),
            Expanded(
              child: TextField(
                controller: TextEditingController(text: searchValue),
                style: TextStyle(color: Colors.white),
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: "Search Orders",
                  hintStyle: TextStyle(
                    color: Color.fromRGBO(255, 255, 255, 0.6),
                  ),
                ),
                cursorColor: Colors.white,
                onSubmitted: (String value) {
                  setState(() {
                    searchValue = value;
                  });
                  handleRefresh();
                },
              ),
            ),
            GestureDetector(
              child: Padding(
                padding: const EdgeInsets.only(left: 10),
                child: Icon(Icons.center_focus_strong),
              ),
              onTap: scanBarcode,
            ),
            GestureDetector(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Icon(Icons.filter_list),
              ),
              onTap: () {
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (BuildContext context) {
                    return OrdersListFiltersModal(
                      baseurl: widget.baseurl,
                      username: widget.username,
                      password: widget.password,
                      sortOrderByValue: sortOrderByValue,
                      sortOrderValue: sortOrderValue,
                      orderStatusOptions: orderStatusOptions,
                      onSubmit: (sortOrderByValue, sortOrderValue,
                          orderStatusOptions) {
                        setState(() {
                          this.sortOrderByValue = sortOrderByValue;
                          this.sortOrderValue = sortOrderValue;
                          this.orderStatusOptions = orderStatusOptions;
                        });
                        handleRefresh();
                      },
                    );
                  },
                );
              },
            ),
            GestureDetector(
              child: Padding(
                padding: const EdgeInsets.only(right: 10),
                child: Icon(Icons.close),
              ),
              onTap: () {
                setState(() {
                  isSearching = !isSearching;
                  searchValue = "";
                });
                handleRefresh();
              },
            ),
          ],
        ),
      );
    } else {
      myAppBar = AppBar(
        title: Text("Orders List"),
        actions: <Widget>[
          GestureDetector(
            child: Padding(
              padding: const EdgeInsets.only(left: 10),
              child: Icon(Icons.search),
            ),
            onTap: () {
              setState(() {
                isSearching = !isSearching;
              });
            },
          ),
          GestureDetector(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Icon(Icons.filter_list),
            ),
            onTap: () {
              showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (BuildContext context) {
                    return OrdersListFiltersModal(
                      baseurl: widget.baseurl,
                      username: widget.username,
                      password: widget.password,
                      sortOrderByValue: sortOrderByValue,
                      sortOrderValue: sortOrderValue,
                      orderStatusOptions: orderStatusOptions,
                      onSubmit: (sortOrderByValue, sortOrderValue,
                          orderStatusOptions) {
                        setState(() {
                          this.sortOrderByValue = sortOrderByValue;
                          this.sortOrderValue = sortOrderValue;
                          this.orderStatusOptions = orderStatusOptions;
                        });
                        handleRefresh();
                      },
                    );
                  });
            },
          ),
        ],
      );
    }
    return myAppBar;
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
