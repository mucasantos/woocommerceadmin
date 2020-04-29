import 'dart:convert';
import 'dart:io';
import 'package:recase/recase.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:woocommerceadmin/src/common/widgets/multi_select.dart';
import 'package:woocommerceadmin/src/common/widgets/single_select.dart';
import 'package:woocommerceadmin/src/orders/providers/orders_list_filters_provider.dart';

class OrdersListFiltersScreen extends StatefulWidget {
  final String baseurl;
  final String username;
  final String password;
  final Function handleRefresh;

  OrdersListFiltersScreen({
    Key key,
    @required this.baseurl,
    @required this.username,
    @required this.password,
    @required this.handleRefresh,
  }) : super(key: key);

  @override
  _OrdersListFiltersScreenState createState() =>
      _OrdersListFiltersScreenState();
}

class _OrdersListFiltersScreenState extends State<OrdersListFiltersScreen> {
  bool _isInit = true;
  String sortOrderByValue = "date";
  String sortOrderValue = "desc";

  bool isOrderStatusOptionsReady = true;
  bool isOrderStatusOptionsError = false;
  String orderStatusOptionsError;
  // Map<String, bool> orderStatusOptions = {};
  // List<Map<String, String>> orderStatusOptions = [];

  final List<SingleSelectMenu> sortOrderByOptions = [
    SingleSelectMenu(value: "date", name: "Date"),
    SingleSelectMenu(value: "id", name: "Id"),
    SingleSelectMenu(value: "name", name: "Name"),
    SingleSelectMenu(value: "include", name: "Include"),
  ];

  List<MultiSelectMenu> orderStatusOptions = [
    // MultiSelectMenu(value: "processing", name: "Processing"),
    // MultiSelectMenu(value: "completed", name: "Completed"),
    // MultiSelectMenu(value: "pending", name: "Pending Payment"),
    // MultiSelectMenu(value: "failed", name: "Failed"),
  ];

  List selectedOrderStatus = [
    // "processing",
    // "completed",
  ];

  @override
  void didChangeDependencies() {
    if (_isInit) {
      OrdersListFiltersProvider ordersListFiltersProvider =
          Provider.of<OrdersListFiltersProvider>(context, listen: false);
      sortOrderByValue = ordersListFiltersProvider.sortOrderByValue;
      sortOrderValue = ordersListFiltersProvider.sortOrderValue;
      selectedOrderStatus = ordersListFiltersProvider.selectedOrderStatus;
      // if (orderStatusOptions.isEmpty) {
      fetchOrderStatusOptions();
      // }
    }
    _isInit = false;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Orders List Filters"),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: ListView(
              children: <Widget>[
                ListTile(
                  title: SingleSelect(
                    labelText: "Sort by",
                    labelTextStyle: Theme.of(context).textTheme.body2,
                    modalHeadingTextStyle: Theme.of(context).textTheme.subhead,
                    modalListTextStyle: Theme.of(context).textTheme.body1,
                    selectedValue: sortOrderByValue,
                    options: sortOrderByOptions,
                    onChange: (value) {
                      setState(() {
                        sortOrderByValue = value;
                      });
                    },
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      IconButton(
                        icon: Icon(
                          Icons.arrow_downward,
                          color: (sortOrderValue == "desc")
                              ? Theme.of(context).primaryColor
                              : Colors.black,
                        ),
                        onPressed: () {
                          setState(() {
                            sortOrderValue = "desc";
                          });
                        },
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.arrow_upward,
                          color: (sortOrderValue == "asc")
                              ? Theme.of(context).primaryColor
                              : Colors.black,
                        ),
                        onPressed: () {
                          setState(() {
                            sortOrderValue = "asc";
                          });
                        },
                      ),
                    ],
                  ),
                ),
                ListTile(
                  title: MultiSelect(
                    labelText: "Filter by order status",
                    labelTextStyle: Theme.of(context).textTheme.body2,
                    modalHeadingTextStyle: Theme.of(context).textTheme.subhead,
                    modalListTextStyle: Theme.of(context).textTheme.body1,
                    isLoading: !isOrderStatusOptionsReady,
                    selectedValuesList: selectedOrderStatus,
                    options: orderStatusOptions,
                    onChange: (value) {
                      setState(() {
                        selectedOrderStatus = value;
                      });
                    },
                  ),
                )
              ],
            ),
          ),
          Row(
            children: <Widget>[
              Expanded(
                child: Container(
                  height: 50,
                  child: RaisedButton(
                    child: Text(
                      "Apply",
                      style: Theme.of(context).textTheme.button,
                    ),
                    color: Theme.of(context).primaryColor,
                    onPressed: () {
                      Provider.of<OrdersListFiltersProvider>(context,
                              listen: false)
                          .changeFilterModalValues(
                        sortOrderByValue: sortOrderByValue,
                        sortOrderValue: sortOrderValue,
                        selectedOrderStatus: selectedOrderStatus,
                      );
                      widget.handleRefresh();
                      Navigator.pop(context);
                    },
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> fetchOrderStatusOptions() async {
    String url =
        "${widget.baseurl}/wp-json/wc/v3/reports/orders/totals?consumer_key=${widget.username}&consumer_secret=${widget.password}";
    setState(() {
      isOrderStatusOptionsReady = false;
      isOrderStatusOptionsError = false;
    });
    http.Response response;
    try {
      response = await http.get(url);
      if (response.statusCode == 200) {
        dynamic resposeBody = json.decode(response.body);
        if (resposeBody is List && resposeBody.isNotEmpty) {
          List<MultiSelectMenu> tempOrderStatusOptions = [];
          resposeBody.forEach(
            (item) {
              if (item is Map &&
                  item.containsKey("slug") &&
                  item["slug"] is String &&
                  item["slug"].isNotEmpty) {
                tempOrderStatusOptions.add(
                  MultiSelectMenu(
                      value: item["slug"], name: item["slug"].toString().titleCase),
                );
              }
            },
          );
          setState(() {
            isOrderStatusOptionsReady = true;
            orderStatusOptions = tempOrderStatusOptions;
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
    } on SocketException catch (_) {
      setState(() {
        isOrderStatusOptionsReady = false;
        isOrderStatusOptionsError = true;
        orderStatusOptionsError =
            "Failed to fetch order status options. Error: Network not reachable";
      });
    } catch (e) {
      setState(() {
        isOrderStatusOptionsReady = false;
        isOrderStatusOptionsError = true;
        orderStatusOptionsError =
            "Failed to fetch order status options. Error: $e";
      });
    }
  }
}
