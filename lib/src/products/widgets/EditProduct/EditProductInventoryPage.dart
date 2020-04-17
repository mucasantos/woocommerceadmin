import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart' as http;
import 'package:woocommerceadmin/src/common/widgets/SingleSelect.dart';

class EditProductInventoryPage extends StatefulWidget {
  final String baseurl;
  final String username;
  final String password;
  final int id;
  final String sku;
  final String stockStatus;
  final bool manageStock;
  final int stockQuantity;
  final String backorders;

  EditProductInventoryPage({
    @required this.baseurl,
    @required this.username,
    @required this.password,
    @required this.id,
    @required this.sku,
    @required this.stockStatus,
    @required this.manageStock,
    @required this.stockQuantity,
    @required this.backorders,
  });

  @override
  _EditProductInventoryPageState createState() =>
      _EditProductInventoryPageState();
}

class _EditProductInventoryPageState extends State<EditProductInventoryPage> {
  String sku;
  String stockStatus;
  bool manageStock;
  int stockQuantity;
  String backorders;

  bool isLoading = false;

  final scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  void initState() {
    sku = widget.sku;
    stockStatus = widget.stockStatus;
    manageStock = widget.manageStock;
    stockQuantity = widget.stockQuantity;
    backorders = widget.backorders;
    super.initState();
  }

  @override
  void setState(Function fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (stockStatus == "outofstock") {
      manageStock = false;
    }
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        title: Text("Inventory"),
      ),
      body: isLoading
          ? Container(
              child: Center(
                child: SpinKitPulse(
                  color: Theme.of(context).primaryColor,
                  size: 70,
                ),
              ),
            )
          : Column(
              children: <Widget>[
                Expanded(
                  child: ListView(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            SizedBox(
                              height: 20,
                            ),
                            TextFormField(
                              initialValue: sku is String ? sku : null,
                              style: Theme.of(context).textTheme.body2,
                              decoration: InputDecoration(labelText: "SKU"),
                              onChanged: (value) {
                                setState(() {
                                  sku = value;
                                });
                              },
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Divider(),
                            SingleSelect(
                              labelText: "Stock Status",
                              labelTextStyle: Theme.of(context).textTheme.body2,
                              modalHeadingTextStyle:
                                  Theme.of(context).textTheme.subhead,
                              modalListTextStyle:
                                  Theme.of(context).textTheme.body1,
                              selectedKey: stockStatus,
                              options: [
                                {"slug": "instock", "name": "In Stock"},
                                {"slug": "outofstock", "name": "Out of Stock"},
                                {"slug": "onbackorder", "name": "On Backorder"},
                              ],
                              keyString: "slug",
                              valueString: "name",
                              onChange: (Map<String, dynamic> value) {
                                setState(() {
                                  stockStatus = value["slug"];
                                });
                              },
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            if (stockStatus == "instock")
                              Column(
                                children: <Widget>[
                                  Divider(),
                                  InkWell(
                                    onTap: () {
                                      setState(() {
                                        manageStock = !manageStock;
                                      });
                                    },
                                    child: Row(
                                      children: <Widget>[
                                        Expanded(
                                          child: Text(
                                            "Manage Stock",
                                            style: Theme.of(context)
                                                .textTheme
                                                .body2,
                                          ),
                                        ),
                                        Checkbox(
                                          value: manageStock,
                                          onChanged: (bool value) {
                                            setState(() {
                                              manageStock = value;
                                            });
                                          },
                                        )
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            if (stockStatus == "instock" && manageStock)
                              Column(
                                children: <Widget>[
                                  TextFormField(
                                    initialValue: stockQuantity is int
                                        ? "$stockQuantity"
                                        : "",
                                    style: Theme.of(context).textTheme.body2,
                                    keyboardType: TextInputType.number,
                                    inputFormatters: [
                                      WhitelistingTextInputFormatter.digitsOnly
                                    ],
                                    decoration: InputDecoration(
                                        labelText: "Stock Quantity"),
                                    onChanged: (String value) {
                                      try {
                                        setState(() {
                                          stockQuantity = int.parse(value);
                                        });
                                      } catch (e) {
                                        try {
                                          setState(() {
                                            stockQuantity =
                                                double.parse(value).toInt();
                                          });
                                        } catch (e) {}
                                      }
                                    },
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                ],
                              ),
                            Divider(),
                            SingleSelect(
                              labelText: "Backorders",
                              labelTextStyle: Theme.of(context).textTheme.body2,
                              modalHeadingTextStyle:
                                  Theme.of(context).textTheme.subhead,
                              modalListTextStyle:
                                  Theme.of(context).textTheme.body1,
                              selectedKey: backorders,
                              options: [
                                {"slug": "no", "name": "Do not allow"},
                                {
                                  "slug": "notify",
                                  "name": "Allow, but notify customer"
                                },
                                {"slug": "yes", "name": "Allow"},
                              ],
                              keyString: "slug",
                              valueString: "name",
                              onChange: (Map<String, dynamic> value) {
                                setState(() {
                                  backorders = value["slug"];
                                });
                              },
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Divider(),
                          ],
                        ),
                      ),
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
                            "Submit",
                            style: Theme.of(context).textTheme.button,
                          ),
                          color: Theme.of(context).primaryColor,
                          onPressed: () {
                            updateProductData();
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

  Future<void> updateProductData() async {
    Map<String, dynamic> updatedProductData = {};

    if (sku is String) {
      updatedProductData["sku"] = sku;
    }

    if (stockStatus is String && stockStatus.isNotEmpty) {
      updatedProductData["stock_status"] = stockStatus;
    }

    if (manageStock is bool) {
      updatedProductData["manage_stock"] = manageStock;
      if (manageStock && stockQuantity is int) {
        updatedProductData["stock_quantity"] = stockQuantity;
      }
    }

    if (backorders is String && backorders.isNotEmpty) {
      updatedProductData["backorders"] = backorders;
    }

    String url =
        "${widget.baseurl}/wp-json/wc/v3/products/${widget.id}?consumer_key=${widget.username}&consumer_secret=${widget.password}";
    http.Response response;
    setState(() {
      isLoading = true;
    });
    try {
      response = await http.put(
        url,
        headers: {HttpHeaders.contentTypeHeader: "application/json"},
        body: json.encode(updatedProductData),
      );
      if (response.statusCode == 200) {
        dynamic responseBody = json.decode(response.body);
        if (responseBody is Map &&
            responseBody.containsKey("id") &&
            responseBody["id"] is int) {
          Navigator.pop(context, "Product inventory details updated successfully...");
        } else {
          setState(() {
            isLoading = false;
          });
          scaffoldKey.currentState.showSnackBar(
            SnackBar(
              content: Text("Failed to update product, try again"),
              duration: Duration(seconds: 3),
            ),
          );
        }
      } else {
        setState(() {
          isLoading = false;
        });
        String errorCode = "";
        if (json.decode(response.body) is Map &&
            json.decode(response.body).containsKey("code")) {
          errorCode = json.decode(response.body)["code"];
        }
        scaffoldKey.currentState.showSnackBar(
          SnackBar(
            content:
                Text("Failed to update product, try again. Error: $errorCode"),
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      scaffoldKey.currentState.showSnackBar(
        SnackBar(
          content: Text("Failed to update product, try again. Error: $e"),
          duration: Duration(seconds: 3),
        ),
      );
    }
  }
}
