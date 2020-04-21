import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:woocommerceadmin/src/common/widgets/single_select.dart';
import 'package:woocommerceadmin/src/products/models/product.dart';
import 'package:woocommerceadmin/src/products/models/products.dart';

class EditProductGeneralScreen extends StatefulWidget {
  final String baseurl;
  final String username;
  final String password;
  final int id;

  EditProductGeneralScreen({
    @required this.baseurl,
    @required this.username,
    @required this.password,
    @required this.id,
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

  final scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  void didChangeDependencies() {
    if (_isInit) {
      final Product productData = Provider.of<Products>(context, listen: false)
          .findProductById(widget.id);
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
                              initialValue: slug is String ? slug : "",
                              style: Theme.of(context).textTheme.body2,
                              decoration: InputDecoration(labelText: "Slug"),
                              onChanged: (String value) {
                                setState(() {
                                  slug = value;
                                });
                              },
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Divider(),
                            SingleSelect(
                              labelText: "Type",
                              labelTextStyle: Theme.of(context).textTheme.body2,
                              modalHeadingTextStyle:
                                  Theme.of(context).textTheme.subhead,
                              modalListTextStyle:
                                  Theme.of(context).textTheme.body1,
                              selectedKey: type,
                              options: [
                                {"slug": "simple", "name": "Simple"},
                              ],
                              keyString: "slug",
                              valueString: "name",
                              onChange: (Map<String, dynamic> value) {
                                setState(() {
                                  type = value["slug"];
                                });
                              },
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Divider(),
                            SingleSelect(
                              labelText: "Status",
                              labelTextStyle: Theme.of(context).textTheme.body2,
                              modalHeadingTextStyle:
                                  Theme.of(context).textTheme.subhead,
                              modalListTextStyle:
                                  Theme.of(context).textTheme.body1,
                              selectedKey: status,
                              options: [
                                {"slug": "draft", "name": "Draft"},
                                {"slug": "pending", "name": "Pending"},
                                {"slug": "private", "name": "Private"},
                                {"slug": "publish", "name": "Publish"},
                              ],
                              keyString: "slug",
                              valueString: "name",
                              onChange: (Map<String, dynamic> value) {
                                setState(() {
                                  status = value["slug"];
                                });
                              },
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Divider(),
                            SingleSelect(
                              labelText: "Catalog Visibility",
                              labelTextStyle: Theme.of(context).textTheme.body2,
                              modalHeadingTextStyle:
                                  Theme.of(context).textTheme.subhead,
                              modalListTextStyle:
                                  Theme.of(context).textTheme.body1,
                              selectedKey: catalogVisibility,
                              options: [
                                {"slug": "visible", "name": "Visible"},
                                {"slug": "catalog", "name": "Catalog"},
                                {"slug": "search", "name": "Search"},
                                {"slug": "hidden", "name": "Hidden"},
                              ],
                              keyString: "slug",
                              valueString: "name",
                              onChange: (Map<String, dynamic> value) {
                                setState(() {
                                  catalogVisibility = value["slug"];
                                });
                              },
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Divider(),
                            InkWell(
                              onTap: () {
                                setState(() {
                                  featured = !featured;
                                });
                              },
                              child: Row(
                                children: <Widget>[
                                  Expanded(
                                    child: Text(
                                      "Featured",
                                      style: Theme.of(context).textTheme.body2,
                                    ),
                                  ),
                                  Checkbox(
                                    value: featured,
                                    onChanged: (bool value) {
                                      setState(() {
                                        featured = value;
                                      });
                                    },
                                  )
                                ],
                              ),
                            ),
                            Divider(),
                            InkWell(
                              onTap: () {
                                setState(() {
                                  virtual = !virtual;
                                });
                              },
                              child: Row(
                                children: <Widget>[
                                  Expanded(
                                    child: Text(
                                      "Virtual",
                                      style: Theme.of(context).textTheme.body2,
                                    ),
                                  ),
                                  Checkbox(
                                    value: virtual,
                                    onChanged: (bool value) {
                                      setState(() {
                                        virtual = value;
                                      });
                                    },
                                  )
                                ],
                              ),
                            ),
                            Divider(),
                            InkWell(
                              onTap: () {
                                setState(() {
                                  downloadable = !downloadable;
                                });
                              },
                              child: Row(
                                children: <Widget>[
                                  Expanded(
                                    child: Text(
                                      "Downloadable",
                                      style: Theme.of(context).textTheme.body2,
                                    ),
                                  ),
                                  Checkbox(
                                    value: downloadable,
                                    onChanged: (bool value) {
                                      setState(() {
                                        downloadable = value;
                                      });
                                    },
                                  )
                                ],
                              ),
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

    Products productsListData = Provider.of<Products>(context, listen: false);
    int productIndex = productsListData.getProductIndexById(widget.id);
    if (productIndex >= 0) {
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
            Product newProduct = Product.fromJson(responseBody);
            productsListData.replaceProductById(widget.id, newProduct);
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
              content: Text(
                  "Failed to update product, try again. Error: $errorCode"),
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
}
