import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'dart:convert';
import 'package:woocommerceadmin/src/orders/components/orders_list/widgets/orders_list_filters_modal.dart';
import 'package:barcode_scan/barcode_scan.dart';
import 'package:woocommerceadmin/src/orders/components/orders_list/widgets/orders_list_widget.dart';
import 'package:woocommerceadmin/src/orders/models/order.dart';
import 'package:woocommerceadmin/src/orders/providers/orders_list_provider.dart';

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
  int _page = 1;
  bool _hasMoreToLoad = true;
  bool _isListLoading = false;
  bool _isListError = false;
  String _listError;

  bool isSearching = false;
  String searchValue = "";

  String sortOrderByValue = "date";
  String sortOrderValue = "desc";
  Map<String, bool> orderStatusOptions = {};

  final GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  void initState() {
    fetchOrdersList();
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
    // Future.delayed(
    //   Duration.zero,
    //   () => _showErrorAlert(context),
    // );
    return Scaffold(
      key: scaffoldKey,
      appBar: _myAppBar(),
      body: Consumer<OrdersListProvider>(
        builder: (context, ordersListData, _) {
          return _isListError && ordersListData.orders.isEmpty
              ? _mainErrorWidget()
              : RefreshIndicator(
                  onRefresh: handleRefresh,
                  child: Column(
                    children: <Widget>[
                      Expanded(
                        child: NotificationListener<ScrollNotification>(
                          onNotification: (ScrollNotification scrollInfo) {
                            if (_hasMoreToLoad &&
                                !_isListLoading &&
                                !_isListError &&
                                scrollInfo.metrics.pixels ==
                                    scrollInfo.metrics.maxScrollExtent) {
                              handleLoadMore();
                            }
                          },
                          child: OrdersListWidget(
                            baseurl: widget.baseurl,
                            username: widget.username,
                            password: widget.password,
                          ),
                        ),
                      ),
                      if (_isListLoading)
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
                );
        },
      ),
    );
  }

  Future<void> fetchOrdersList() async {
    String url =
        "${widget.baseurl}/wp-json/wc/v3/orders?page=$_page&per_page=20&consumer_key=${widget.username}&consumer_secret=${widget.password}";
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
      _isListLoading = true;
      _isListError = false;
    });

    http.Response response;
    try {
      response = await http.get(url);
      if (response.statusCode == 200) {
        dynamic responseBody = json.decode(response.body);
        if (responseBody is List) {
          if (responseBody.isNotEmpty) {
            final List<Order> loadedOrders = [];
            responseBody.forEach((item) {
              loadedOrders.add(Order.fromJson(item));
            });
            Provider.of<OrdersListProvider>(context, listen: false).addOrders(loadedOrders);
            setState(() {
              _hasMoreToLoad = true;
              _isListLoading = false;
              _isListError = false;
            });
          } else {
            setState(() {
              _hasMoreToLoad = false;
              _isListLoading = false;
              _isListError = false;
            });
          }
        } else {
          setState(() {
            _hasMoreToLoad = true;
            _isListLoading = false;
            _isListError = true;
            _listError = "Failed to fetch orders";
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
          _hasMoreToLoad = true;
          _isListLoading = false;
          _isListError = true;
          _listError = "Failed to fetch orders. Error: $errorCode";
        });
      }
    } on SocketException catch (_) {
      setState(() {
        _hasMoreToLoad = true;
        _isListLoading = false;
        _isListError = true;
        _listError = "Failed to fetch orders. Error: Network not reachable";
      });
    } catch (e) {
      setState(() {
        _hasMoreToLoad = true;
        _isListLoading = false;
        _isListError = true;
        _listError = "Failed to fetch orders. Error: $e";
      });
      throw e;
    }
  }

  Future<void> handleLoadMore() async {
    setState(() {
      _page++;
    });
    await fetchOrdersList();
  }

  Future<void> handleRefresh() async {
    setState(() {
      _page = 1;
      Provider.of<OrdersListProvider>(context, listen: false).clearOrdersList();
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
    if (_isListError && _listError is String && _listError.isNotEmpty)
      mainErrorWidget = Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 20, 10, 20),
              child: Text(
                _listError ?? "",
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

}
