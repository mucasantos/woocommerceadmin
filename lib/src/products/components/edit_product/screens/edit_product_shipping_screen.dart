import 'dart:convert';
import 'dart:io';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:woocommerceadmin/src/products/models/product.dart';
import 'package:woocommerceadmin/src/products/providers/product_provider.dart';
import 'package:woocommerceadmin/src/products/providers/product_providers_list.dart';

class EditProductShippingScreen extends StatefulWidget {
  final String baseurl;
  final String username;
  final String password;

  EditProductShippingScreen({
    @required this.baseurl,
    @required this.username,
    @required this.password,
  });

  @override
  _EditProductShippingScreenState createState() =>
      _EditProductShippingScreenState();
}

class _EditProductShippingScreenState extends State<EditProductShippingScreen> {
  bool _isInit = true;
  bool _isLoading = false;
  final scaffoldKey = new GlobalKey<ScaffoldState>();

  String weight;
  String length;
  String width;
  String height;
  String shippingClass;

  void didChangeDependencies() {
    if (_isInit) {
      final Product productData =
          Provider.of<ProductProvider>(context, listen: false).product;
      weight = productData?.weight ?? "";
      length = productData?.dimensions?.length ?? "";
      width = productData?.dimensions?.width ?? "";
      height = productData.dimensions?.height ?? "";
      shippingClass = productData?.shippingClass ?? "";
    }
    _isInit = false;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        title: Text("Shipping"),
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
                              initialValue: weight is String ? weight : "",
                              style: Theme.of(context).textTheme.body2,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                WhitelistingTextInputFormatter(
                                    RegExp(r"^\d*\.?\d*"))
                              ],
                              decoration: InputDecoration(labelText: "Weight"),
                              onChanged: (value) {
                                setState(() {
                                  weight = value;
                                });
                              },
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Divider(),
                            TextFormField(
                              initialValue: length is String ? length : "",
                              style: Theme.of(context).textTheme.body2,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                WhitelistingTextInputFormatter(
                                    RegExp(r"^\d*\.?\d*"))
                              ],
                              decoration: InputDecoration(labelText: "Length"),
                              onChanged: (value) {
                                setState(() {
                                  length = value;
                                });
                              },
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Divider(),
                            TextFormField(
                              initialValue: width is String ? width : "",
                              style: Theme.of(context).textTheme.body2,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                WhitelistingTextInputFormatter(
                                    RegExp(r"^\d*\.?\d*"))
                              ],
                              decoration: InputDecoration(labelText: "Width"),
                              onChanged: (value) {
                                setState(() {
                                  width = value;
                                });
                              },
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Divider(),
                            TextFormField(
                              initialValue: height is String ? height : "",
                              style: Theme.of(context).textTheme.body2,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                WhitelistingTextInputFormatter(
                                    RegExp(r"^\d*\.?\d*"))
                              ],
                              decoration: InputDecoration(labelText: "Height"),
                              onChanged: (value) {
                                setState(() {
                                  height = value;
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

    if (weight is String) {
      updatedProductData["weight"] = weight;
    }

    if (length is String || width is String || height is String) {
      updatedProductData["dimensions"] = {};
      if (length is String) {
        updatedProductData["dimensions"]["length"] = length;
      }
      if (width is String) {
        updatedProductData["dimensions"]["width"] = width;
      }
      if (height is String) {
        updatedProductData["dimensions"]["height"] = height;
      }
    }

    if (shippingClass is String && shippingClass.isNotEmpty) {
      updatedProductData["shippingClass"] = shippingClass;
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
              context, "Product shipping details updated successfully...");
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
