import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:recase/recase.dart';
import 'package:validators/sanitizers.dart';

class EditProductPage extends StatefulWidget {
  final String baseurl;
  final String username;
  final String password;
  final int id;
  EditProductPage(
      {Key key,
      @required this.baseurl,
      @required this.username,
      @required this.password,
      @required this.id})
      : super(key: key);

  @override
  _EditProductPageState createState() => _EditProductPageState();
}

class _EditProductPageState extends State<EditProductPage> {
  final scaffoldKey = new GlobalKey<ScaffoldState>();

  bool isProductDataReady = false;
  bool isProductDataError = true;
  Map productData = Map();
  String productDataError;

  //Product Local States
  String name = "";
  String sku = "";
  String status = "";
  bool featured;
  DateTime dateOnSaleFrom;
  DateTime dateOnSaleTo;
  String regularPrice = "";
  String salePrice = "";
  bool manageStock;
  String stockStatus = "";
  int stockQuantity;
  String weight = "";
  String length = "";
  String width = "";
  String height = "";
  String type = "";
  bool downloadable;
  bool virtual;

  @override
  void initState() {
    super.initState();
    fetchProductData();
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
          title: Text("Edit Product"),
        ),
        body: isProductDataError
            ? _productDataErrorWidget()
            : !isProductDataReady
                ? _mainLoadingWidget()
                : Column(
                    children: <Widget>[
                      Expanded(
                        child: SingleChildScrollView(
                            scrollDirection: Axis.vertical,
                            padding: const EdgeInsets.all(0.0),
                            child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                mainAxisSize: MainAxisSize.max,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  _mainLoadingWidget(),
                                  _productGeneralWidget(),
                                  _productStatusWidget(),
                                  _productPricingWidget(),
                                  _productInventoryWidget(),
                                  _productShippingWidget(),
                                ])),
                      ),
                      _submitButtonWidget()
                    ],
                  ));
  }

  Future<void> fetchProductData() async {
    String url =
        "${widget.baseurl}/wp-json/wc/v3/products/${widget.id}?consumer_key=${widget.username}&consumer_secret=${widget.password}";
    setState(() {
      isProductDataReady = false;
      isProductDataError = false;
    });
    http.Response response;
    try {
      response = await http.get(url);

      if (response.statusCode == 200) {
        dynamic responseBody = json.decode(response.body);
        if (responseBody is Map &&
            responseBody.containsKey("id") &&
            responseBody["id"] != null) {
          if (responseBody.containsKey("name") &&
              responseBody["name"] != null &&
              responseBody["name"].toString().isNotEmpty) {
            setState(() {
              name = responseBody["name"];
            });
          }

          if (responseBody.containsKey("sku") &&
              responseBody["sku"] != null &&
              responseBody["sku"].toString().isNotEmpty) {
            setState(() {
              sku = responseBody["sku"];
            });
          }

          if (responseBody.containsKey("status") &&
              responseBody["status"] != null &&
              responseBody["status"].toString().isNotEmpty) {
            setState(() {
              status = responseBody["status"];
            });
          }

          if (responseBody.containsKey("featured") &&
              responseBody["featured"] != null &&
              responseBody["featured"] is bool) {
            setState(() {
              featured = responseBody["featured"];
            });
          }

          if (responseBody.containsKey("regular_price") &&
              responseBody["regular_price"] != null &&
              responseBody["regular_price"].toString().isNotEmpty) {
            setState(() {
              regularPrice = responseBody["regular_price"];
            });
          }

          if (responseBody.containsKey("sale_price") &&
              responseBody["sale_price"] != null &&
              responseBody["sale_price"].toString().isNotEmpty) {
            setState(() {
              salePrice = responseBody["sale_price"];
            });
          }

          if (responseBody.containsKey("date_on_sale_from") &&
              responseBody["date_on_sale_from"] is String &&
              responseBody["date_on_sale_from"].isNotEmpty) {
            setState(() {
              dateOnSaleFrom = toDate(responseBody["date_on_sale_from"]);
            });
          }

          if (responseBody.containsKey("date_on_sale_to") &&
              responseBody["date_on_sale_to"] != null &&
              responseBody["date_on_sale_to"] is DateTime) {
            setState(() {
              dateOnSaleTo = toDate(responseBody["date_on_sale_to"]);
            });
          }

          if (responseBody.containsKey("manage_stock") &&
              responseBody["manage_stock"] != null &&
              responseBody["manage_stock"] is bool) {
            setState(() {
              manageStock = responseBody["manage_stock"];
            });
          }

          if (responseBody.containsKey("stock_status") &&
              responseBody["stock_status"] != null &&
              responseBody["stock_status"].toString().isNotEmpty) {
            setState(() {
              stockStatus = responseBody["stock_status"];
            });
          }

          if (responseBody.containsKey("stock_quantity") &&
              responseBody["stock_quantity"] != null &&
              responseBody["stock_quantity"] is int) {
            setState(() {
              stockQuantity = responseBody["stock_quantity"];
            });
          }

          if (responseBody.containsKey("weight") &&
              responseBody["weight"] != null &&
              responseBody["weight"].toString().isNotEmpty) {
            setState(() {
              weight = responseBody["weight"];
            });
          }

          if (responseBody.containsKey("dimensions") &&
              responseBody["dimensions"] != null) {
            if (responseBody["dimensions"].containsKey("length") &&
                responseBody["dimensions"]["length"] != null &&
                responseBody["dimensions"]["length"].toString().isNotEmpty) {
              setState(() {
                length = responseBody["dimensions"]["length"];
              });
            }

            if (responseBody["dimensions"].containsKey("width") &&
                responseBody["dimensions"]["width"] != null &&
                responseBody["dimensions"]["width"].toString().isNotEmpty) {
              setState(() {
                width = responseBody["dimensions"]["width"];
              });
            }

            if (responseBody["dimensions"].containsKey("height") &&
                responseBody["dimensions"]["height"] != null &&
                responseBody["dimensions"]["height"].toString().isNotEmpty) {
              setState(() {
                height = responseBody["dimensions"]["height"];
              });
            }
          }

          if (responseBody.containsKey("type") &&
              responseBody["type"] != null &&
              responseBody["type"].toString().isNotEmpty) {
            setState(() {
              type = responseBody["type"];
            });
          }

          if (responseBody.containsKey("virtual") &&
              responseBody["virtual"] != null &&
              responseBody["virtual"] is bool) {
            setState(() {
              virtual = responseBody["virtual"];
            });
          }

          if (responseBody.containsKey("downloadable") &&
              responseBody["downloadable"] != null &&
              responseBody["downloadable"] is bool) {
            setState(() {
              downloadable = responseBody["downloadable"];
            });
          }

          // if ('categories' in responseJson && Array.isArray(responseJson.categories) && responseJson.categories.length) {
          //     let selectedProductCategories = []
          //     responseJson.categories.forEach(item => {
          //         if (item.id) {
          //             selectedProductCategories.push(item.id.toString())
          //         }
          //     })
          //     this.setState({
          //         selectedProductCategories: selectedProductCategories
          //     })
          // }
          setState(() {
            productData = responseBody;
            isProductDataReady = true;
            isProductDataError = false;
          });
        } else {
          setState(() {
            isProductDataReady = false;
            isProductDataError = true;
            productDataError = "Failed to fetch product details";
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
          isProductDataReady = false;
          isProductDataError = true;
          productDataError =
              "Failed to fetch product details. Error: $errorCode";
        });
      }
    } on SocketException catch (_) {
      setState(() {
        isProductDataReady = false;
        isProductDataError = true;
        productDataError =
            "Failed to fetch product details. Error: Network not reachable";
      });
    } catch (e) {
      setState(() {
        isProductDataReady = false;
        isProductDataError = true;
        productDataError = "Failed to fetch product details. Error: $e";
      });
    }
  }

  updateProductData() async {
    Map<String, dynamic> updatedProductData = {};
    if (name is String) {
      updatedProductData["name"] = name;
    }
    if (sku is String) {
      updatedProductData["sku"] = sku;
    }
    if (status is String) {
      updatedProductData["status"] = status;
    }
    if (regularPrice is String) {
      updatedProductData["regular_price"] = regularPrice;
    }
    if (salePrice is String) {
      updatedProductData["sale_price"] = salePrice;
    }
    if (dateOnSaleFrom is DateTime) {
      updatedProductData["date_on_sale_from"] =
          DateFormat("yyyy-MM-dd").format(dateOnSaleFrom);
    }
    if (dateOnSaleTo is DateTime) {
      updatedProductData["date_on_sale_to"] =
          DateFormat("yyyy-MM-dd").format(dateOnSaleTo);
    }
    if (stockStatus is String) {
      updatedProductData["stock_status"] = stockStatus;
    }
    if (manageStock is bool) {
      updatedProductData["manage_stock"] = manageStock;
      if (manageStock && stockQuantity is int) {
        updatedProductData["stock_quantity"] = stockQuantity;
      }
    }
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
    String url =
        "${widget.baseurl}/wp-json/wc/v3/products/${widget.id}?consumer_key=${widget.username}&consumer_secret=${widget.password}";
    http.Response response;
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
            responseBody["id"] != null) {
          scaffoldKey.currentState.showSnackBar(SnackBar(
            content: Text("Product updated successfully..."),
            duration: Duration(seconds: 3),
          ));
          Navigator.pop(context, "Product updated successfully...");
        } else {
          scaffoldKey.currentState.showSnackBar(SnackBar(
            content: Text("Failed to update product"),
            duration: Duration(seconds: 3),
          ));
        }
      } else {
        String errorCode = "";
        if (json.decode(response.body) is Map &&
            json.decode(response.body).containsKey("code")) {
          errorCode = json.decode(response.body)["code"];
        }
        scaffoldKey.currentState.showSnackBar(SnackBar(
          content: Text("Failed to update product. Error: $errorCode"),
          duration: Duration(seconds: 3),
        ));
      }
    } catch (e) {
      scaffoldKey.currentState.showSnackBar(SnackBar(
        content: Text("Failed to update product. Error: $e"),
        duration: Duration(seconds: 3),
      ));
    }
  }

  Widget _mainLoadingWidget() {
    Widget mainLoadingWidget = SizedBox.shrink();
    if (!isProductDataReady && !isProductDataError) {
      mainLoadingWidget = Container(
        child: Center(
          child: SpinKitPulse(
            color: Theme.of(context).primaryColor,
            size: 70,
          ),
        ),
      );
    }
    return mainLoadingWidget;
  }

  Widget _productDataErrorWidget() {
    Widget productDataErrorWidget = SizedBox.shrink();
    if (isProductDataError &&
        !isProductDataReady &&
        productDataError is String &&
        productDataError.isNotEmpty) {
      productDataErrorWidget = Container(
        padding: EdgeInsets.all(10),
        child: Center(
          child: Text(productDataError),
        ),
      );
    }
    return productDataErrorWidget;
  }

  Widget _productGeneralWidget() {
    Widget productGeneralWidget = SizedBox.shrink();
    if (isProductDataReady) {
      List<Widget> productGeneralData = [];
      productGeneralData.add(
        TextFormField(
          initialValue: name is String ? name : "",
          style: Theme.of(context).textTheme.body2,
          decoration: InputDecoration(labelText: "Name"),
          onChanged: (value) {
            setState(() {
              name = value;
            });
          },
        ),
      );

      productGeneralData.add(
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
      );

      productGeneralWidget = ExpansionTile(
        title: Text(
          "General",
          style: Theme.of(context).textTheme.subhead,
        ),
        initiallyExpanded: true,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: productGeneralData),
                ),
              ),
            ],
          )
        ],
      );
    }
    return productGeneralWidget;
  }

  Widget _productStatusWidget() {
    Widget productStatusWidget = SizedBox.shrink();
    if (isProductDataReady) {
      List<Widget> productStatusData = [];

      productStatusData.add(Row(
        children: <Widget>[
          Expanded(
            child: Text(
              "Status",
              style: Theme.of(context).textTheme.body2,
            ),
          ),
          Expanded(
            child: Center(
              child: DropdownButton<String>(
                value: status,
                onChanged: (String newValue) {
                  FocusScope.of(context).requestFocus(FocusNode());
                  setState(() {
                    status = newValue;
                  });
                },
                items: <String>['draft', 'private', 'pending', 'publish']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(
                      value.titleCase,
                      style: Theme.of(context).textTheme.body2,
                      textAlign: TextAlign.center,
                    ),
                  );
                }).toList(),
              ),
            ),
          )
        ],
      ));

      productStatusWidget = ExpansionTile(
        title: Text(
          "Status",
          style: Theme.of(context).textTheme.subhead,
        ),
        initiallyExpanded: true,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20.0, 0, 20.0, 10.0),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: productStatusData),
                ),
              ),
            ],
          )
        ],
      );
    }
    return productStatusWidget;
  }

  Widget _productPricingWidget() {
    Widget productPricingWidget = SizedBox.shrink();
    if (isProductDataReady) {
      List<Widget> productPricingData = [];

      productPricingData.add(TextFormField(
        initialValue: regularPrice is String ? regularPrice : "",
        style: Theme.of(context).textTheme.body2,
        keyboardType: TextInputType.number,
        inputFormatters: [
          WhitelistingTextInputFormatter(RegExp(r"^\d*\.?\d*"))
        ],
        decoration: InputDecoration(
          labelText: "Regular Price",
        ),
        onChanged: (value) {
          setState(() {
            regularPrice = value;
          });
        },
      ));

      productPricingData.add(TextFormField(
        initialValue: salePrice is String ? salePrice : "",
        style: Theme.of(context).textTheme.body2,
        keyboardType: TextInputType.number,
        inputFormatters: [
          WhitelistingTextInputFormatter(RegExp(r"^\d*\.?\d*"))
        ],
        decoration: InputDecoration(labelText: "Sale Price"),
        onChanged: (value) {
          setState(() {
            salePrice = value;
          });
        },
      ));

      productPricingData.add(Row(
        children: <Widget>[
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
              child: Text(
                "Sale From Date: ",
                style: Theme.of(context).textTheme.body2,
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
              child: Center(
                child: RaisedButton(
                  onPressed: () async {
                    FocusScope.of(context).requestFocus(FocusNode());
                    final DateTime picked = await showDatePicker(
                      context: context,
                      initialDate: (dateOnSaleFrom is DateTime)
                          ? dateOnSaleFrom
                          : DateTime.now().subtract(Duration(days: 6)),
                      firstDate: DateTime(2015, 8),
                      lastDate: DateTime(2101),
                    );
                    if (picked != dateOnSaleFrom)
                      setState(() {
                        dateOnSaleFrom = picked;
                      });
                  },
                  child: Text(
                    dateOnSaleFrom is DateTime
                        ? "${dateOnSaleFrom.toLocal()}".split(' ')[0]
                        : "Select Date",
                    style: Theme.of(context).textTheme.body2,
                  ),
                ),
              ),
            ),
          ),
        ],
      ));

      productPricingData.add(Row(
        children: <Widget>[
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
              child: Text(
                "Sale To Date: ",
                style: Theme.of(context).textTheme.body2,
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
              child: Center(
                child: RaisedButton(
                  onPressed: () async {
                    FocusScope.of(context).requestFocus(FocusNode());
                    final DateTime picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2015, 8),
                      lastDate: DateTime(2101),
                    );
                    if (picked != dateOnSaleTo)
                      setState(() {
                        dateOnSaleTo = picked;
                      });
                  },
                  child: Text(
                    dateOnSaleTo != null && dateOnSaleTo is DateTime
                        ? "${dateOnSaleTo.toLocal()}".split(' ')[0]
                        : "Select Date",
                    style: Theme.of(context).textTheme.body2,
                  ),
                ),
              ),
            ),
          ),
        ],
      ));

      productPricingWidget = ExpansionTile(
        title: Text(
          "Pricing",
          style: Theme.of(context).textTheme.subhead,
        ),
        initiallyExpanded: true,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20.0, 0, 20.0, 10.0),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: productPricingData),
                ),
              ),
            ],
          )
        ],
      );
    }
    return productPricingWidget;
  }

  Widget _productInventoryWidget() {
    Widget productInventoryWidget = SizedBox.shrink();
    if (isProductDataReady) {
      List<Widget> productInventoryData = [];

      productInventoryData.add(Row(
        children: <Widget>[
          Expanded(
            child: Text(
              "Stock Status",
              style: Theme.of(context).textTheme.body2,
            ),
          ),
          Expanded(
            child: Center(
              child: DropdownButton<String>(
                value: stockStatus,
                onChanged: (String newValue) {
                  FocusScope.of(context).requestFocus(FocusNode());
                  setState(() {
                    stockStatus = newValue;
                  });
                },
                items: <String>["instock", "outofstock", "onbackorder"]
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(
                      value.titleCase,
                      style: Theme.of(context).textTheme.body2,
                      textAlign: TextAlign.center,
                    ),
                  );
                }).toList(),
              ),
            ),
          )
        ],
      ));

      if (stockStatus == "instock") {
        productInventoryData.add(Row(
          children: <Widget>[
            Expanded(
              child: Text(
                "Manage Stock: ",
                style: Theme.of(context).textTheme.body2,
              ),
            ),
            Expanded(
              child: Center(
                child: Switch(
                    value: manageStock,
                    onChanged: (bool newManageStock) {
                      setState(() {
                        manageStock = newManageStock;
                      }); //
                    }),
              ),
            )
          ],
        ));
      }

      if (stockStatus == "outofstock") {
        manageStock = false;
      }

      if (stockStatus == "instock" && manageStock) {
        productInventoryData.add(TextFormField(
          initialValue: stockQuantity is int ? "$stockQuantity" : "",
          style: Theme.of(context).textTheme.body2,
          keyboardType: TextInputType.number,
          inputFormatters: [WhitelistingTextInputFormatter.digitsOnly],
          decoration: InputDecoration(labelText: "Stock Quantity"),
          onChanged: (value) {
            try {
              setState(() {
                stockQuantity = int.parse(value);
              });
            } catch (e) {}
          },
        ));
      }

      productInventoryWidget = ExpansionTile(
        title: Text(
          "Inventory",
          style: Theme.of(context).textTheme.subhead,
        ),
        initiallyExpanded: true,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20.0, 0, 20.0, 10.0),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: productInventoryData),
                ),
              ),
            ],
          )
        ],
      );
    }
    return productInventoryWidget;
  }

  Widget _productShippingWidget() {
    Widget productShippingWidget = SizedBox.shrink();
    if (isProductDataReady) {
      List<Widget> productWidgetData = [];

      productWidgetData.add(TextFormField(
        initialValue: weight is String ? weight : "",
        style: Theme.of(context).textTheme.body2,
        keyboardType: TextInputType.number,
        inputFormatters: [
          WhitelistingTextInputFormatter(RegExp(r"^\d*\.?\d*"))
        ],
        decoration: InputDecoration(labelText: "Weight"),
        onChanged: (value) {
          setState(() {
            weight = value;
          });
        },
      ));

      productWidgetData.add(Row(
        children: <Widget>[
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(0, 0, 10, 0),
              child: TextFormField(
                  initialValue: length is String ? length : "",
                  style: Theme.of(context).textTheme.body2,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    WhitelistingTextInputFormatter(RegExp(r"^\d*\.?\d*"))
                  ],
                  decoration: InputDecoration(labelText: "L"),
                  onChanged: (value) {
                    setState(() {
                      length = value;
                    });
                  }),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
              child: TextFormField(
                  initialValue: width is String ? width : "",
                  style: Theme.of(context).textTheme.body2,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    WhitelistingTextInputFormatter(RegExp(r"^\d*\.?\d*"))
                  ],
                  decoration: InputDecoration(labelText: "W"),
                  onChanged: (value) {
                    setState(() {
                      width = value;
                    });
                  }),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
              child: TextFormField(
                  initialValue: height is String ? height : "",
                  style: Theme.of(context).textTheme.body2,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    WhitelistingTextInputFormatter(RegExp(r"^\d*\.?\d*"))
                  ],
                  decoration: InputDecoration(labelText: "H"),
                  onChanged: (value) {
                    setState(() {
                      height = value;
                    });
                  }),
            ),
          ),
        ],
      ));

      productShippingWidget = ExpansionTile(
        title: Text(
          "Shipping",
          style: Theme.of(context).textTheme.subhead,
        ),
        initiallyExpanded: true,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: productWidgetData),
                ),
              ),
            ],
          )
        ],
      );
    }
    return productShippingWidget;
  }

  //  Widget _productCategoriesWidget() {
  //   Widget productCategoriesWidget = SizedBox.shrink();
  //   if (isProductDataReady) {
  //     List<Widget> productCategoriesWidget = [];

  //     productCategoriesWidget.add(

  //     );

  //     productCategoriesWidget = ExpansionTile(
  //       title: Text(
  //         "Categories",
  //         style: Theme.of(context).textTheme.subhead,
  //       ),
  //       initiallyExpanded: true,
  //       children: <Widget>[
  //         Row(
  //           children: <Widget>[
  //             Expanded(
  //               child: Padding(
  //                 padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
  //                 child: Column(
  //                     crossAxisAlignment: CrossAxisAlignment.start,
  //                     children: productWidgetData),
  //               ),
  //             ),
  //           ],
  //         )
  //       ],
  //     );
  //   }
  //   return productCategoriesWidget;
  // }

  Widget _submitButtonWidget() {
    Widget submitButtonWidget = SizedBox.shrink();
    if (isProductDataReady) {
      submitButtonWidget = Row(
        children: <Widget>[
          Expanded(
            child: Container(
              height: 50,
              child: RaisedButton(
                color: Theme.of(context).primaryColor,
                textColor: Colors.white,
                onPressed: () {
                  updateProductData();
                },
                child: const Text("Submit"),
              ),
            ),
          ),
        ],
      );
    }
    return submitButtonWidget;
  }
}
