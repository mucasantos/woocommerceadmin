import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:recase/recase.dart';

class OrdersListFiltersModal extends StatefulWidget {
  final String baseurl;
  final String username;
  final String password;
  final String sortOrderByValue;
  final String sortOrderValue;
  final Map<String, bool> orderStatusOptions;
  final void Function(String, String, Map<String, bool>) onSubmit;

  OrdersListFiltersModal({
    Key key,
    @required this.baseurl,
    @required this.username,
    @required this.password,
    @required this.sortOrderByValue,
    @required this.sortOrderValue,
    @required this.orderStatusOptions,
    @required this.onSubmit,
  }) : super(key: key);

  @override
  _OrdersListFiltersModalState createState() => _OrdersListFiltersModalState();
}

class _OrdersListFiltersModalState extends State<OrdersListFiltersModal> {
  String sortOrderByValue = "date";
  String sortOrderValue = "desc";

  bool isOrderStatusOptionsReady = false;
  bool isOrderStatusOptionsError = false;
  String orderStatusOptionsError;
  Map<String, bool> orderStatusOptions = {};

  @override
  void initState() {
    super.initState();
    sortOrderByValue = widget.sortOrderByValue;
    sortOrderValue = widget.sortOrderValue;
    orderStatusOptions = widget.orderStatusOptions;
    fetchOrderStatusOptions();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Sort & Filter"),
      titlePadding: EdgeInsets.fromLTRB(15, 20, 15, 0),
      content: Container(
        height: 400,
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                "Sort by",
                style: Theme.of(context).textTheme.subhead,
              ),
              Row(
                children: <Widget>[
                  Expanded(
                    child: Container(
                      child: DropdownButton<String>(
                        underline: SizedBox.shrink(),
                        value: sortOrderByValue,
                        onChanged: (String newValue) {
                          FocusScope.of(context).requestFocus(FocusNode());
                          setState(() {
                            sortOrderByValue = newValue;
                          });
                        },
                        items: <String>[
                          "date",
                          "id",
                          "title",
                          "slug",
                          "include"
                        ].map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(
                              value.titleCase,
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.body1,
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  InkWell(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Icon(
                        Icons.arrow_downward,
                        color: (sortOrderValue == "desc")
                            ? Theme.of(context).primaryColor
                            : Colors.black,
                      ),
                    ),
                    onTap: () {
                      setState(() {
                        sortOrderValue = "desc";
                      });
                    },
                  ),
                  InkWell(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Icon(
                        Icons.arrow_upward,
                        color: (sortOrderValue == "asc")
                            ? Theme.of(context).primaryColor
                            : Colors.black,
                      ),
                    ),
                    onTap: () {
                      setState(() {
                        sortOrderValue = "asc";
                      });
                    },
                  ),
                ],
              ),
              Text(
                "Filter by",
                style: Theme.of(context).textTheme.subhead,
              ),
              SizedBox(
                height: 10,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 10),
                child: Text(
                  "Order Status",
                  style: Theme.of(context)
                      .textTheme
                      .body1
                      .copyWith(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              isOrderStatusOptionsError
                  ? Row(
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
                    )
                  : isOrderStatusOptionsReady
                      ? Column(
                          children: orderStatusOptions.keys.map((String key) {
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  orderStatusOptions[key] =
                                      !orderStatusOptions[key];
                                });
                              },
                              child: Row(
                                children: <Widget>[
                                  SizedBox(
                                    height: 30,
                                    child: Checkbox(
                                      value: orderStatusOptions[key],
                                      onChanged: (bool value) {
                                        setState(() {
                                          orderStatusOptions[key] = value;
                                        });
                                      },
                                    ),
                                  ),
                                  Text(
                                    key.titleCase,
                                    style: Theme.of(context).textTheme.body1,
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        )
                      : Container(
                          padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
                          child: Center(
                            child: SpinKitFadingCube(
                              color: Theme.of(context).primaryColor,
                              size: 30.0,
                            ),
                          ),
                        )
            ],
          ),
        ),
      ),
      contentPadding: EdgeInsets.fromLTRB(15, 10, 15, 0),
      actions: <Widget>[
        FlatButton(
          child: Text("Close"),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        FlatButton(
          child: Text("Ok"),
          onPressed: () {
            widget.onSubmit(
                sortOrderByValue, sortOrderValue, orderStatusOptions);
            Navigator.of(context).pop();
          },
        )
      ],
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
        if (json.decode(response.body) is List &&
            !json.decode(response.body).isEmpty) {
          Map<String, bool> tempMap = orderStatusOptions;
          json.decode(response.body).forEach((item) {
            if (item is Map &&
                item.containsKey("slug") &&
                item["slug"] is String &&
                item["slug"].isNotEmpty) {
              tempMap.putIfAbsent(item["slug"], () => false);
            }
          });
          setState(() {
            isOrderStatusOptionsReady = true;
            orderStatusOptions = tempMap;
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
}
