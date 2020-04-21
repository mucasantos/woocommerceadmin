import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:recase/recase.dart';
import 'package:woocommerceadmin/src/orders/components/order_details/screens/order_details_screen.dart';
import 'package:woocommerceadmin/src/orders/components/orders_list/widgets/orders_list_filters_modal.dart';
import 'package:barcode_scan/barcode_scan.dart';


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
  List ordersListData = [];
  int page = 1;
  bool hasMoreToLoad = true;
  bool isListLoading = false;
  bool isListError = false;
  String listError;

  bool isSearching = false;
  String searchValue = "";

  String sortOrderByValue = "date";
  String sortOrderValue = "desc";
  Map<String, bool> orderStatusOptions = {};

  final GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      new GlobalKey<RefreshIndicatorState>();

  @override
  void initState() {
    super.initState();
    fetchOrdersList();
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Future.delayed(
    //   Duration.zero,
    //   () => _showErrorAlert(context),
    // );
    return Scaffold(
      key: scaffoldKey,
      appBar: _myAppBar(),
      body: isListError && ordersListData.isEmpty
          ? _mainErrorWidget()
          : RefreshIndicator(
              key: _refreshIndicatorKey,
              onRefresh: handleRefresh,
              child: Column(
                children: <Widget>[
                  Expanded(
                    child: NotificationListener<ScrollNotification>(
                      onNotification: (ScrollNotification scrollInfo) {
                        if (hasMoreToLoad &&
                            !isListLoading &&
                            !isListError &&
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
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
                                                _orderDate(
                                                    ordersListData[index]),
                                                _orderIdAndBillingName(
                                                    ordersListData[index]),
                                                _orderStatus(
                                                    ordersListData[index]),
                                                _orderTotal(
                                                    ordersListData[index])
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
                      height: 60,
                      child: Center(
                        child: SpinKitPulse(
                          color: Colors.purple,
                          size: 50,
                        ),
                      ),
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
      isListError = false;
    });

    http.Response response;
    try {
      response = await http.get(url);
      if (response.statusCode == 200) {
        if (json.decode(response.body) is List) {
          if (json.decode(response.body).isNotEmpty) {
            setState(() {
              hasMoreToLoad = true;
              ordersListData.addAll(json.decode(response.body));
              isListLoading = false;
              isListError = false;
            });
          } else {
            setState(() {
              hasMoreToLoad = false;
              isListLoading = false;
              isListError = false;
            });
          }
        } else {
          setState(() {
            hasMoreToLoad = true;
            isListLoading = false;
            isListError = true;
            listError = "Failed to fetch orders";
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
          hasMoreToLoad = true;
          isListLoading = false;
          isListError = true;
          listError = "Failed to fetch orders. Error: $errorCode";
        });
      }
    } on SocketException catch (_) {
      setState(() {
        hasMoreToLoad = true;
        isListLoading = false;
        isListError = true;
        listError = "Failed to fetch orders. Error: Network not reachable";
      });
    } catch (e) {
      setState(() {
        hasMoreToLoad = true;
        isListLoading = false;
        isListError = true;
        listError = "Failed to fetch orders. Error: $e";
      });
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
    myAppBar = AppBar(
      title: Row(
        children: <Widget>[
          isSearching
              ? Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: Icon(Icons.search),
                )
              : SizedBox.shrink(),
          isSearching
              ? Expanded(
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
                )
              : Expanded(
                  child: Text("Orders List"),
                ),
          isSearching
              ? IconButton(
                  icon: Icon(Icons.center_focus_strong),
                  onPressed: scanBarcode,
                )
              : IconButton(
                  icon: Icon(Icons.search),
                  onPressed: () {
                    setState(() {
                      isSearching = !isSearching;
                    });
                  },
                ),
          IconButton(
            icon: Icon(Icons.filter_list),
            onPressed: () {
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
                    onSubmit:
                        (sortOrderByValue, sortOrderValue, orderStatusOptions) {
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
          isSearching
              ? IconButton(
                  icon: Icon(Icons.close),
                  onPressed: () {
                    bool isPreviousSearchValueNotEmpty = false;
                    if (searchValue.isNotEmpty) {
                      isPreviousSearchValueNotEmpty = true;
                    } else {
                      isPreviousSearchValueNotEmpty = false;
                    }
                    setState(() {
                      isSearching = !isSearching;
                      searchValue = "";
                    });
                    if (isPreviousSearchValueNotEmpty is bool &&
                        isPreviousSearchValueNotEmpty) {
                      handleRefresh();
                    }
                  },
                )
              : SizedBox.shrink(),
        ],
      ),
    );
    return myAppBar;
  }

  Widget _mainErrorWidget() {
    Widget mainErrorWidget = SizedBox.shrink();
    if (isListError && listError is String && listError.isNotEmpty)
      mainErrorWidget = Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 20, 10, 20),
              child: Text(
                listError ?? "",
                textAlign: TextAlign.center,
              ),
            ),
            Container(
              height: 45,
              width: 200,
              child: RaisedButton(
                color: Theme.of(context).primaryColor,
                textColor: Colors.white,
                child: Text("Retry"),
                onPressed: handleRefresh,
              ),
            )
          ],
        ),
      );
    return mainErrorWidget;
  }

  // void _showErrorAlert(BuildContext context) {
  //   if (isListError && ordersListData.isNotEmpty) {
  //     showDialog<void>(
  //         context: context,
  //         barrierDismissible: false,
  //         builder: (BuildContext context) {
  //           return AlertDialog(
  //             title: Text("Retry"),
  //             titlePadding: EdgeInsets.fromLTRB(15, 20, 15, 0),
  //             content: Container(
  //               height: 300,
  //               child: SingleChildScrollView(
  //                 child: Column(
  //                   crossAxisAlignment: CrossAxisAlignment.start,
  //                   children: <Widget>[
  //                     Text(
  //                       listError ?? "",
  //                       style: Theme.of(context).textTheme.body1,
  //                     ),
  //                     SizedBox(
  //                       height: 20,
  //                     ),
  //                     Text(
  //                       "Do you want to retry?",
  //                       style: Theme.of(context).textTheme.body1,
  //                     ),
  //                   ],
  //                 ),
  //               ),
  //             ),
  //             contentPadding: EdgeInsets.fromLTRB(15, 10, 15, 0),
  //             actions: <Widget>[
  //               FlatButton(
  //                 child: Text("No"),
  //                 onPressed: () {
  //                   Navigator.of(context).pop();
  //                 },
  //               ),
  //               FlatButton(
  //                 child: Text("Yes"),
  //                 onPressed: () async {
  //                   Navigator.of(context).pop();
  //                   fetchOrdersList();
  //                 },
  //               )
  //             ],
  //           );
  //         });
  //   }
  // }

  Widget _orderDate(Map orderDetailsMap) {
    Widget orderDateWidget = SizedBox();
    if (orderDetailsMap.containsKey("date_created") &&
        orderDetailsMap["date_created"] is String)
      orderDateWidget = Text(
        DateFormat("EEEE, dd/MM/yyyy h:mm:ss a").format(
          DateTime.parse(orderDetailsMap["date_created"]),
        ),
      );
    return orderDateWidget;
  }

  Widget _orderIdAndBillingName(Map orderDetailsMap) {
    Widget orderIdAndBillingNameWidget = SizedBox();
    String orderId = "";
    String billingName = "";
    if (orderDetailsMap.containsKey("id") && orderDetailsMap["id"] is int) {
      orderId = "#${orderDetailsMap["id"]}";
    }
    if (orderDetailsMap.containsKey("billing") &&
        orderDetailsMap["billing"] is Map) {
      if (orderDetailsMap["billing"].containsKey("first_name") &&
          orderDetailsMap["billing"]["first_name"] is String) {
        billingName =
            billingName + orderDetailsMap["billing"]["first_name"].toString();
      }
      if (orderDetailsMap["billing"].containsKey("last_name") &&
          orderDetailsMap["billing"]["last_name"] is String) {
        if (billingName.isNotEmpty) {
          billingName = billingName + " ";
        }
        billingName =
            billingName + orderDetailsMap["billing"]["last_name"].toString();
      }
    }
    orderIdAndBillingNameWidget = Text(
      "$orderId $billingName",
      style: Theme.of(context)
          .textTheme
          .body1
          .copyWith(fontSize: 20.0, fontWeight: FontWeight.bold),
    );
    return orderIdAndBillingNameWidget;
  }

  Widget _orderStatus(Map orderDetailsMap) {
    Widget orderStatusWidget = SizedBox();
    if (orderDetailsMap.containsKey("status") &&
        orderDetailsMap["status"] is String)
      orderStatusWidget = Text(
        "Status: " + orderDetailsMap["status"].toString().titleCase,
      );
    return orderStatusWidget;
  }

  Widget _orderTotal(Map orderDetailsMap) {
    Widget orderTotalWidget = SizedBox();
    if (orderDetailsMap.containsKey("total") &&
        orderDetailsMap["total"] is String)
      orderTotalWidget = Text(
        "Total: " +
            ((orderDetailsMap.containsKey("currency_symbol") &&
                    orderDetailsMap["currency_symbol"] is String)
                ? orderDetailsMap["currency_symbol"]
                : (orderDetailsMap.containsKey("currency") &&
                        orderDetailsMap["currency"] is String)
                    ? orderDetailsMap["currency"]
                    : "") +
            orderDetailsMap["total"],
      );
    return orderTotalWidget;
  }
}
