import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:woocommerceadmin/src/products/models/product.dart';
import 'package:woocommerceadmin/src/products/models/products.dart';

class EditProductCategoriesScreen extends StatefulWidget {
  final String baseurl;
  final String username;
  final String password;
  final int id;

  EditProductCategoriesScreen({
    @required this.baseurl,
    @required this.username,
    @required this.password,
    @required this.id,
  });

  @override
  _EditProductCategoriesScreenState createState() =>
      _EditProductCategoriesScreenState();
}

class _EditProductCategoriesScreenState
    extends State<EditProductCategoriesScreen> {
  bool _isInit = true;
  List _selectedProductCategories = [];

  int page = 1;
  bool hasMoreToLoad = true;
  bool isListLoading = false;
  bool isListError = false;
  String listError;
  List productCategoriesListData = [];

  bool isUpdateLoading = false;

  final scaffoldKey = new GlobalKey<ScaffoldState>();
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();

  @override
  void initState() {
    fetchProductCategoriesList();
    super.initState();
  }

  void didChangeDependencies() {
    if (_isInit) {
      final Product productData = Provider.of<Products>(context, listen: false)
          .getProductById(widget.id);
      if (productData?.categories is List &&
          productData.categories.isNotEmpty) {
        for (int i = 0; i < productData.categories.length; i++) {
          _selectedProductCategories.add(productData.categories[i].toJson());
        }
      }
    }
    _isInit = false;
    super.didChangeDependencies();
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        title: Text("Categories"),
      ),
      body: isListError && productCategoriesListData.isEmpty
          ? _mainErrorWidget()
          : isUpdateLoading
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
                      child: RefreshIndicator(
                        key: _refreshIndicatorKey,
                        onRefresh: handleRefresh,
                        child: NotificationListener<ScrollNotification>(
                          onNotification: (ScrollNotification scrollInfo) {
                            if (hasMoreToLoad &&
                                !isListLoading &&
                                scrollInfo.metrics.pixels ==
                                    scrollInfo.metrics.maxScrollExtent) {
                              handleLoadMore();
                            }
                          },
                          child: ListView.builder(
                            physics: AlwaysScrollableScrollPhysics(),
                            itemCount: productCategoriesListData.length,
                            itemBuilder: (BuildContext context, int index) {
                              return Column(
                                children: <Widget>[
                                  CheckboxListTile(
                                    title: Text(
                                      productCategoriesListData[index]["name"],
                                      style: Theme.of(context).textTheme.body1,
                                    ),
                                    controlAffinity:
                                        ListTileControlAffinity.leading,
                                    value: productCategoriesListData[index]
                                        ["selected"],
                                    onChanged: (bool value) {
                                      setState(() {
                                        productCategoriesListData[index]
                                                ["selected"] =
                                            !productCategoriesListData[index]
                                                ["selected"];
                                      });
                                    },
                                  ),
                                  Divider(
                                    height: 0,
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                    if (isListLoading)
                      Container(
                        height: 60,
                        child: Center(
                            child: SpinKitPulse(
                          color: Theme.of(context).primaryColor,
                          size: 50,
                        )),
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

  Future<void> fetchProductCategoriesList() async {
    String url =
        "${widget.baseurl}/wp-json/wc/v3/products/categories?page=$page&per_page=20&consumer_key=${widget.username}&consumer_secret=${widget.password}";

    setState(() {
      isListLoading = true;
      isListError = false;
    });
    http.Response response;
    try {
      response = await http.get(url);
      if (response.statusCode == 200) {
        dynamic responseBody = json.decode(response.body);
        if (responseBody is List) {
          if (responseBody.isNotEmpty) {
            for (int i = 0; i < responseBody.length; i++) {
              responseBody[i].putIfAbsent("selected", () => false);
              for (int j = 0; j < _selectedProductCategories.length; j++) {
                if (responseBody[i]["id"] ==
                    _selectedProductCategories[j]["id"]) {
                  responseBody[i]["selected"] = true;
                }
              }
            }
            setState(() {
              hasMoreToLoad = true;
              productCategoriesListData.addAll(responseBody);
              isListLoading = false;
              isListError = false;
            });
          } else {
            setState(() {
              hasMoreToLoad = false;
              isListLoading = false;
              isListError = false;
              listError = "Invalid response received from server";
            });
          }
        } else {
          setState(() {
            hasMoreToLoad = true;
            isListLoading = false;
            isListError = true;
            listError = "Failed to fetch product categories";
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
          hasMoreToLoad = true;
          isListLoading = false;
          isListError = true;
          listError = "Failed to fetch product categories. Error: $errorCode";
        });
      }
    } on SocketException catch (_) {
      setState(() {
        hasMoreToLoad = true;
        isListLoading = false;
        isListError = true;
        listError =
            "Failed to fetch product  categories. Error: Network not reachable";
      });
    } catch (e) {
      setState(() {
        hasMoreToLoad = true;
        isListLoading = false;
        isListError = true;
        listError = "Failed to fetch product categories. Error: $e";
      });
    }
  }

  Future<void> updateProductData() async {
    List updatedProductCategoriesIdList = [];
    for (int i = 0; i < productCategoriesListData.length; i++) {
      if (productCategoriesListData[i].containsKey("selected") &&
          productCategoriesListData[i]["selected"] &&
          productCategoriesListData[i].containsKey("id") &&
          productCategoriesListData[i]["id"] is int) {
        updatedProductCategoriesIdList
            .add({"id": productCategoriesListData[i]["id"]});
      }
    }

    Map<String, dynamic> updatedProductData = {
      "categories": updatedProductCategoriesIdList,
    };

    Products productsListData = Provider.of<Products>(context, listen: false);
    int productIndex = productsListData.getProductIndexById(widget.id);
    if (productIndex >= 0) {
      String url =
          "${widget.baseurl}/wp-json/wc/v3/products/${widget.id}?consumer_key=${widget.username}&consumer_secret=${widget.password}";
      http.Response response;
      setState(() {
        isUpdateLoading = true;
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
                context, "Product categories details updated successfully...");
          } else {
            setState(() {
              isUpdateLoading = false;
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
            isUpdateLoading = false;
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
          isUpdateLoading = false;
        });
        scaffoldKey.currentState.showSnackBar(
          SnackBar(
            content: Text("Failed to update product, try again. Error: $e"),
            duration: Duration(seconds: 3),
          ),
        );
      }
    } else {
      scaffoldKey.currentState.showSnackBar(
        SnackBar(
          content: Text(
              "Failed to update product, try again. Error: Can't find product index"),
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  Future<void> handleLoadMore() async {
    setState(() {
      page++;
    });
    await fetchProductCategoriesList();
  }

  Future<void> handleRefresh() async {
    setState(() {
      page = 1;
      productCategoriesListData = [];
    });
    await fetchProductCategoriesList();
  }

  Widget _mainErrorWidget() {
    Widget mainErrorWidget = SizedBox.shrink();
    if (isListError && listError is String && listError.isNotEmpty)
      mainErrorWidget = Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 20, 10, 20),
              child: Text(
                listError ?? "",
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
}
