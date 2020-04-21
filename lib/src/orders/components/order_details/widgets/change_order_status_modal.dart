import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:recase/recase.dart';

class ChangeOrderStatusModal extends StatefulWidget {
  final String baseurl;
  final String username;
  final String password;
  final String orderStatus;
  final void Function(String value) onSubmit;

  ChangeOrderStatusModal({
    Key key,
    @required this.baseurl,
    @required this.username,
    @required this.password,
    @required this.orderStatus,
    @required this.onSubmit,
  }) : super(key: key);

  @override
  _ChangeOrderStatusModalState createState() => _ChangeOrderStatusModalState();
}

class _ChangeOrderStatusModalState extends State<ChangeOrderStatusModal> {
  bool isOrderStatusOptionsReady = false;
  bool isOrderStatusOptionsError = false;
  String orderStatusOptionsError;
  List<String> orderStatusOptionsList = [];

  int selectedIndex = -1;

  @override
  void initState() {
    super.initState();
    if (widget.orderStatus is String && widget.orderStatus.isNotEmpty) {}
    fetchOrderStatusOptions();
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
            : isOrderStatusOptionsReady
                ? Column(
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
                  )
                : Container(
                    padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
                    child: Center(
                      child: SpinKitPulse(
                        color: Theme.of(context).primaryColor,
                        size: 30.0,
                      ),
                    ),
                  ),
      ),
      contentPadding: EdgeInsets.fromLTRB(15, 10, 15, 0),
      actions: <Widget>[
        FlatButton(
          child: Text("Cancel"),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        FlatButton(
          child: Text("Apply"),
          onPressed: () {
            if (isOrderStatusOptionsReady && selectedIndex >= 0) {
              widget.onSubmit(orderStatusOptionsList[selectedIndex]);
            }
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
          List<String> tempList = [];
          json.decode(response.body).forEach((item) {
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
            selectedIndex = tempList.indexOf(widget.orderStatus);
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
