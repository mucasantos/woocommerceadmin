import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import 'package:woocommerceadmin/src/products/models/product.dart';
import 'package:woocommerceadmin/src/products/providers/product_provider.dart';
import 'package:woocommerceadmin/src/products/providers/product_providers_list.dart';

class EditProductReviewsScreen extends StatefulWidget {
  final String baseurl;
  final String username;
  final String password;

  EditProductReviewsScreen({
    @required this.baseurl,
    @required this.username,
    @required this.password,
  });

  @override
  _EditProductReviewsScreenState createState() =>
      _EditProductReviewsScreenState();
}

class _EditProductReviewsScreenState extends State<EditProductReviewsScreen> {
  bool _isInit = true;
  bool _isLoading = false;
  final scaffoldKey = new GlobalKey<ScaffoldState>();

  bool reviewsAllowed = false;

  void didChangeDependencies() {
    if (_isInit) {
      final Product productData =
          Provider.of<ProductProvider>(context, listen: false).product;
      reviewsAllowed = productData?.reviewsAllowed ?? false;
    }
    _isInit = false;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        title: Text("Reviews"),
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
                      CheckboxListTile(
                        title: Text(
                          "Reviews Allowed",
                          style: Theme.of(context).textTheme.body2,
                        ),
                        value: reviewsAllowed,
                        onChanged: (bool value) {
                          setState(() {
                            reviewsAllowed = value;
                          });
                        },
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

    if (reviewsAllowed is bool) {
      updatedProductData["reviews_allowed"] = reviewsAllowed;
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
              context, "Product reviews details updated successfully...");
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
