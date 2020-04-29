import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:woocommerceadmin/src/common/widgets/single_select.dart';
import 'package:woocommerceadmin/src/products/models/product.dart';
import 'package:woocommerceadmin/src/products/providers/product_provider.dart';
import 'package:woocommerceadmin/src/products/providers/product_providers_list.dart';

class EditProductInventoryScreen extends StatefulWidget {
  final String baseurl;
  final String username;
  final String password;

  EditProductInventoryScreen({
    @required this.baseurl,
    @required this.username,
    @required this.password,
  });

  @override
  _EditProductInventoryScreenState createState() =>
      _EditProductInventoryScreenState();
}

class _EditProductInventoryScreenState
    extends State<EditProductInventoryScreen> {
  bool _isInit = true;
  bool _isLoading = false;
  final scaffoldKey = new GlobalKey<ScaffoldState>();

  String sku;
  String stockStatus;
  bool manageStock;
  int stockQuantity;
  String backorders;

  final List<SingleSelectMenu> stockStatusOptions = [
    SingleSelectMenu(value: "instock", name: "In stock"),
    SingleSelectMenu(value: "outofstock", name: "Out of stock"),
    SingleSelectMenu(value: "onbackorder", name: "On backorder"),
  ];

   final List<SingleSelectMenu> backordersOptions = [
    SingleSelectMenu(value: "no", name: "Do not allow"),
    SingleSelectMenu(value: "notify", name: "Allow, but notify customer"),
    SingleSelectMenu(value: "yes", name: "Allow"),
  ];

  void didChangeDependencies() {
    if (_isInit) {
      final Product productData =
          Provider.of<ProductProvider>(context, listen: false).product;
      sku = productData?.sku ?? "";
      stockStatus = productData?.stockStatus ?? "";
      manageStock = productData?.manageStock ?? false;
      stockQuantity = productData?.stockQuantity ?? null;
      backorders = productData?.backorders ?? false;
    }
    _isInit = false;
    super.didChangeDependencies();
  }

  @override
  void initState() {
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
      body: _isLoading
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
                              height: 10,
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
                              selectedValue: stockStatus,
                              options: stockStatusOptions,
                              onChange: (value) {
                                setState(() {
                                  stockStatus = value;
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
                            if (stockStatus == "instock")
                              SingleSelect(
                                labelText: "Backorders",
                                labelTextStyle:
                                    Theme.of(context).textTheme.body2,
                                modalHeadingTextStyle:
                                    Theme.of(context).textTheme.subhead,
                                modalListTextStyle:
                                    Theme.of(context).textTheme.body1,
                                selectedValue: backorders,
                                options: backordersOptions,
                                onChange: (value) {
                                  setState(() {
                                    backorders = value;
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

    final ProductProvider productProvider =
        Provider.of<ProductProvider>(context, listen: false);
    final int productId = productProvider.product.id;
    String url =
        "${widget.baseurl}/wp-json/wc/v3/products/$productId?consumer_key=${widget.username}&consumer_secret=${widget.password}";
    http.Response response;
    setState(() {
      _isLoading = true;
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
          productProvider.replaceProduct(Product.fromJson(responseBody));
          Provider.of<ProductProvidersList>(context, listen: false)
              .replaceProductProviderById(productId, productProvider);
          Navigator.pop(
              context, "Product inventory details updated successfully...");
        } else {
          setState(() {
            _isLoading = false;
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
          _isLoading = false;
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
        _isLoading = false;
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
