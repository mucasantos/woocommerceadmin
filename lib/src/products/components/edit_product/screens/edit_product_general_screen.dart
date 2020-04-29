import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:woocommerceadmin/src/common/widgets/single_select.dart';
import 'package:woocommerceadmin/src/products/models/product.dart';
import 'package:woocommerceadmin/src/products/providers/product_provider.dart';
import 'package:woocommerceadmin/src/products/providers/product_providers_list.dart';

class EditProductGeneralScreen extends StatefulWidget {
  final String baseurl;
  final String username;
  final String password;

  EditProductGeneralScreen({
    @required this.baseurl,
    @required this.username,
    @required this.password,
  });

  @override
  _EditProductGeneralScreenState createState() =>
      _EditProductGeneralScreenState();
}

class _EditProductGeneralScreenState extends State<EditProductGeneralScreen> {
  bool _isInit = true;
  bool isLoading = false;

  String slug;
  String type;
  String status;
  String catalogVisibility;
  bool featured;
  bool virtual;
  bool downloadable;

  final List<SingleSelectMenu> typeOptions = [
    SingleSelectMenu(value: "simple", name: "Simple"),
  ];

  final List<SingleSelectMenu> statusOptions = [
    SingleSelectMenu(value: "draft", name: "Draft"),
    SingleSelectMenu(value: "pending", name: "Pending"),
    SingleSelectMenu(value: "private", name: "Private"),
    SingleSelectMenu(value: "publish", name: "Publish"),
  ];

  final List<SingleSelectMenu> catalogVisibilityOptions = [
    SingleSelectMenu(value: "visible", name: "Visible"),
    SingleSelectMenu(value: "catalog", name: "Catalog"),
    SingleSelectMenu(value: "search", name: "Search"),
    SingleSelectMenu(value: "hidden", name: "Hidden"),
  ];

  final scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  void didChangeDependencies() {
    if (_isInit) {
      final Product productData =
          Provider.of<ProductProvider>(context, listen: false).product;
      slug = productData?.slug ?? "";
      type = productData?.type ?? "";
      status = productData?.status ?? "";
      catalogVisibility = productData?.catalogVisibility ?? "";
      featured = productData?.featured ?? false;
      virtual = productData?.virtual ?? false;
      downloadable = productData?.downloadable ?? false;
    }
    _isInit = false;
    super.didChangeDependencies();
  }

  @override
  void setState(Function fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        title: Text("General Details"),
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
                      ListTile(
                        title: TextFormField(
                          initialValue: slug is String ? slug : "",
                          style: Theme.of(context).textTheme.body2,
                          decoration: InputDecoration(labelText: "Slug"),
                          onChanged: (String value) {
                            setState(() {
                              slug = value;
                            });
                          },
                        ),
                      ),
                      ListTile(
                        title: SingleSelect(
                          labelText: "Type",
                          labelTextStyle: Theme.of(context).textTheme.body2,
                          modalHeadingTextStyle:
                              Theme.of(context).textTheme.subhead,
                          modalListTextStyle: Theme.of(context).textTheme.body1,
                          selectedValue: type,
                          options: typeOptions,
                          onChange: (value) {
                            setState(() {
                              type = value;
                            });
                          },
                        ),
                      ),
                      ListTile(
                        title: SingleSelect(
                          labelText: "Status",
                          labelTextStyle: Theme.of(context).textTheme.body2,
                          modalHeadingTextStyle:
                              Theme.of(context).textTheme.subhead,
                          modalListTextStyle: Theme.of(context).textTheme.body1,
                          selectedValue: status,
                          options: statusOptions,
                          onChange: (value) {
                            setState(() {
                              status = value;
                            });
                          },
                        ),
                      ),
                      ListTile(
                        title: SingleSelect(
                          labelText: "Catalog Visibility",
                          labelTextStyle: Theme.of(context).textTheme.body2,
                          modalHeadingTextStyle:
                              Theme.of(context).textTheme.subhead,
                          modalListTextStyle: Theme.of(context).textTheme.body1,
                          selectedValue: catalogVisibility,
                          options: catalogVisibilityOptions,
                          onChange: (value) {
                            setState(() {
                              catalogVisibility = value;
                            });
                          },
                        ),
                      ),
                      CheckboxListTile(
                        title: Text(
                          "Featured",
                          style: Theme.of(context).textTheme.body2,
                        ),
                        value: featured,
                        onChanged: (bool value) {
                          setState(() {
                            featured = value;
                          });
                        },
                      ),
                      CheckboxListTile(
                        title: Text(
                          "Virtual",
                          style: Theme.of(context).textTheme.body2,
                        ),
                        value: virtual,
                        onChanged: (bool value) {
                          setState(() {
                            virtual = value;
                          });
                        },
                      ),
                      CheckboxListTile(
                        title: Text(
                          "Downloadable",
                          style: Theme.of(context).textTheme.body2,
                        ),
                        value: downloadable,
                        onChanged: (bool value) {
                          setState(() {
                            downloadable = value;
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

    if (slug is String) {
      updatedProductData["slug"] = slug;
    }

    if (type is String && type.isNotEmpty) {
      updatedProductData["type"] = type;
    }

    if (status is String && status.isNotEmpty) {
      updatedProductData["status"] = status;
    }

    if (catalogVisibility is String && catalogVisibility.isNotEmpty) {
      updatedProductData["catalog_visibility"] = catalogVisibility;
    }

    if (featured is bool) {
      updatedProductData["featured"] = featured;
    }

    if (virtual is bool) {
      updatedProductData["virtual"] = virtual;
    }

    if (downloadable is bool) {
      updatedProductData["downloadable"] = downloadable;
    }

    final ProductProvider productProvider =
        Provider.of<ProductProvider>(context, listen: false);
    final int productId = productProvider.product.id;
    String url =
        "${widget.baseurl}/wp-json/wc/v3/products/$productId?consumer_key=${widget.username}&consumer_secret=${widget.password}";
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
          productProvider.replaceProduct(Product.fromJson(responseBody));
          Provider.of<ProductProvidersList>(context, listen: false)
              .replaceProductProviderById(productId, productProvider);
          Navigator.pop(
              context, "Product general details updated successfully...");
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
