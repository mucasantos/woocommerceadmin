import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:woocommerceadmin/src/orders/components/orders_list/widgets/orders_list_appbar.dart';
import 'dart:convert';
import 'package:woocommerceadmin/src/orders/components/orders_list/widgets/orders_list_widget.dart';
import 'package:woocommerceadmin/src/orders/models/order.dart';
import 'package:woocommerceadmin/src/orders/providers/order_provider.dart';
import 'package:woocommerceadmin/src/orders/providers/order_providers_list.dart';
import 'package:woocommerceadmin/src/orders/providers/orders_list_filters_provider.dart';

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
      appBar: OrdersListAppbar.getAppBar(
        context: context,
        handleRefresh: handleRefresh,
        baseurl: widget.baseurl,
        username: widget.username,
        password: widget.password,
      ),
      body: Consumer<OrderProvidersList>(
        builder: (context, orderProvidersList, _) {
          return _isListError && orderProvidersList.orderProviders.isEmpty
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

  Future<void> fetchOrdersList({
    int perPage = 25,
  }) async {
    final OrdersListFiltersProvider ordersListFiltersProvider =
        Provider.of<OrdersListFiltersProvider>(context, listen: false);
    String url =
        "${widget.baseurl}/wp-json/wc/v3/orders?page=$_page&per_page=$perPage&consumer_key=${widget.username}&consumer_secret=${widget.password}";
    if (ordersListFiltersProvider?.searchValue is String &&
        ordersListFiltersProvider.searchValue.isNotEmpty) {
      url += "&search=${ordersListFiltersProvider.searchValue}";
    }
    if (ordersListFiltersProvider?.sortOrderByValue is String &&
        ordersListFiltersProvider.sortOrderByValue.isNotEmpty) {
      url += "&orderby=${ordersListFiltersProvider.sortOrderByValue}";
    }
    if (ordersListFiltersProvider?.sortOrderValue is String &&
        ordersListFiltersProvider.sortOrderValue.isNotEmpty) {
      url += "&order=${ordersListFiltersProvider.sortOrderValue}";
    }
    if (ordersListFiltersProvider?.selectedOrderStatus is List &&
        ordersListFiltersProvider.selectedOrderStatus.isNotEmpty) {
      ordersListFiltersProvider.selectedOrderStatus.forEach((item) {
          url += "&status[]=$item";
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
            final List<OrderProvider> loadedOrderProviders = [];
            responseBody.forEach((item) {
              loadedOrderProviders.add(OrderProvider(Order.fromJson(item)));
            });
            Provider.of<OrderProvidersList>(context, listen: false)
                .addOrderProviders(loadedOrderProviders);
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
      Provider.of<OrderProvidersList>(context, listen: false)
          .clearOrderProvidersList();
    });
    await fetchOrdersList();
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
