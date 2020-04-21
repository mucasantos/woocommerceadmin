import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:woocommerceadmin/src/common/widgets/single_select.dart';
import 'package:woocommerceadmin/src/products/models/product.dart';
import 'package:woocommerceadmin/src/products/models/products.dart';

class EditProductPricingScreen extends StatefulWidget {
  final String baseurl;
  final String username;
  final String password;
  final int id;

  EditProductPricingScreen({
    @required this.baseurl,
    @required this.username,
    @required this.password,
    @required this.id,
  });

  @override
  _EditProductPricingScreenState createState() =>
      _EditProductPricingScreenState();
}

class _EditProductPricingScreenState extends State<EditProductPricingScreen> {
  bool _isInit = true;
  bool _isLoading = false;
  bool _showSaleDates = false;

  final scaffoldKey = new GlobalKey<ScaffoldState>();
  TextEditingController _dateOnSaleFromController = TextEditingController();
  TextEditingController _dateOnSaleToController = TextEditingController();

  String regularPrice;
  String salePrice;
  DateTime dateOnSaleFrom;
  DateTime dateOnSaleTo;
  String taxStatus;
  String taxClass;

  // List productTaxClasses = [];
  // bool isProductTaxClassesReady = false;
  // bool isProductTaxClassesError = false;
  // String productTaxClassesError;

  @override
  void didChangeDependencies() {
    if (_isInit) {
      final Product productData = Provider.of<Products>(context, listen: false)
          .findProductById(widget.id);
      regularPrice = productData?.regularPrice ?? "";
      salePrice = productData?.salePrice ?? "";
      dateOnSaleFrom = productData?.dateOnSaleFrom;
      _dateOnSaleFromController.text = productData.dateOnSaleFrom is DateTime
          ? "${dateOnSaleFrom.toLocal()}".split(' ')[0]
          : "";
      dateOnSaleTo = productData?.dateOnSaleTo;
      _dateOnSaleToController.text = dateOnSaleTo is DateTime
          ? "${dateOnSaleTo.toLocal()}".split(' ')[0]
          : "";
      if (productData.dateOnSaleFrom is DateTime ||
          productData.dateOnSaleTo is DateTime) {
        _showSaleDates = true;
      }
      taxStatus = productData.taxStatus ?? "";
      taxClass = productData.taxClass ?? "";
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
  void dispose() {
    _dateOnSaleFromController.dispose();
    _dateOnSaleToController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        title: Text("Pricing"),
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
                            Text(
                              "Price",
                              style: Theme.of(context).textTheme.subhead,
                            ),
                            TextFormField(
                              initialValue: regularPrice ?? "",
                              style: Theme.of(context).textTheme.body2,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                WhitelistingTextInputFormatter(
                                    RegExp(r"^\d*\.?\d*"))
                              ],
                              decoration: InputDecoration(
                                labelText: "Regular Price",
                              ),
                              onChanged: (value) {
                                setState(() {
                                  regularPrice = value;
                                });
                              },
                            ),
                            TextFormField(
                              initialValue: salePrice ?? "",
                              style: Theme.of(context).textTheme.body2,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                WhitelistingTextInputFormatter(
                                    RegExp(r"^\d*\.?\d*"))
                              ],
                              decoration:
                                  InputDecoration(labelText: "Sale Price"),
                              onChanged: (value) {
                                setState(() {
                                  salePrice = value;
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
                                  _showSaleDates = !_showSaleDates;
                                });
                              },
                              child: Row(
                                children: <Widget>[
                                  Expanded(
                                    child: Text(
                                      "Schedule Sale",
                                      style: Theme.of(context).textTheme.body2,
                                    ),
                                  ),
                                  Checkbox(
                                    value: _showSaleDates,
                                    onChanged: (bool value) {
                                      setState(() {
                                        _showSaleDates = value;
                                      });
                                    },
                                  )
                                ],
                              ),
                            ),
                            if (_showSaleDates)
                              Column(
                                children: <Widget>[
                                  GestureDetector(
                                    onTap: () async {
                                      FocusScope.of(context)
                                          .requestFocus(FocusNode());
                                      final DateTime picked =
                                          await showDatePicker(
                                        context: context,
                                        initialDate: dateOnSaleFrom ??
                                            DateTime.now()
                                                .subtract(Duration(days: 6)),
                                        firstDate: DateTime(2015, 8),
                                        lastDate: DateTime(2101),
                                        builder: (context, child) {
                                          return Localizations.override(
                                            context: context,
                                            delegates: [
                                              CancelButtonLocalizationDelegate(),
                                            ],
                                            child: child,
                                          );
                                        },
                                      );
                                      if (picked != dateOnSaleFrom) {
                                        setState(() {
                                          dateOnSaleFrom = picked;
                                          _dateOnSaleFromController.value =
                                              TextEditingValue(
                                                  text: dateOnSaleFrom
                                                          is DateTime
                                                      ? "${dateOnSaleFrom.toLocal()}"
                                                          .split(' ')[0]
                                                      : "");
                                        });
                                      }
                                    },
                                    child: AbsorbPointer(
                                      child: TextFormField(
                                        controller: _dateOnSaleFromController,
                                        style:
                                            Theme.of(context).textTheme.body2,
                                        keyboardType: TextInputType.datetime,
                                        decoration: InputDecoration(
                                          labelText: "From",
                                          suffixIcon:
                                              Icon(Icons.arrow_drop_down),
                                        ),
                                      ),
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () async {
                                      FocusScope.of(context)
                                          .requestFocus(FocusNode());
                                      final DateTime picked =
                                          await showDatePicker(
                                        context: context,
                                        initialDate:
                                            dateOnSaleTo ?? DateTime.now(),
                                        firstDate: DateTime(2015, 8),
                                        lastDate: DateTime(2101),
                                        builder: (context, child) {
                                          return Localizations.override(
                                            context: context,
                                            delegates: [
                                              CancelButtonLocalizationDelegate(),
                                            ],
                                            child: child,
                                          );
                                        },
                                      );
                                      if (picked != dateOnSaleTo) {
                                        setState(() {
                                          dateOnSaleTo = picked;
                                          _dateOnSaleToController.value =
                                              TextEditingValue(
                                                  text: dateOnSaleTo is DateTime
                                                      ? "${dateOnSaleTo.toLocal()}"
                                                          .split(' ')[0]
                                                      : "");
                                        });
                                      }
                                    },
                                    child: AbsorbPointer(
                                      child: TextFormField(
                                        controller: _dateOnSaleToController,
                                        style:
                                            Theme.of(context).textTheme.body2,
                                        keyboardType: TextInputType.datetime,
                                        decoration: InputDecoration(
                                          labelText: "To",
                                          suffixIcon:
                                              Icon(Icons.arrow_drop_down),
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                ],
                              ),
                            Divider(),
                            SizedBox(
                              height: 10,
                            ),
                            Text(
                              "Tax Setting",
                              style: Theme.of(context).textTheme.subhead,
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            SingleSelect(
                              labelText: "Tax Status",
                              labelTextStyle: Theme.of(context).textTheme.body2,
                              modalHeadingTextStyle:
                                  Theme.of(context).textTheme.subhead,
                              modalListTextStyle:
                                  Theme.of(context).textTheme.body1,
                              selectedKey: taxStatus,
                              options: [
                                {"slug": "taxable", "name": "Taxable"},
                                {"slug": "shipping", "name": "Shipping"},
                                {"slug": "none", "name": "None"},
                              ],
                              keyString: "slug",
                              valueString: "name",
                              onChange: (Map<String, dynamic> value) {
                                setState(() {
                                  taxStatus = value["slug"];
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
                            // final productData =
                            //     Provider.of<Products>(context, listen: false);

                            // productData.updateProductPricing(
                            //   baseurl: widget.baseurl,
                            //   username: widget.username,
                            //   password: widget.password,
                            //   id: productData.findById(widget.id).id,
                            //   regularPrice: regularPrice,
                            //   salePrice: salePrice,
                            //   dateOnSaleFrom: dateOnSaleFrom,
                            //   dateOnSaleTo: dateOnSaleTo,
                            //   taxStatus: taxStatus,
                            // );
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

  // Future<void> fetchProductTaxClasses() async {
  //   String url =
  //       "${widget.baseurl}/wp-json/wc/v3/taxes/classes?consumer_key=${widget.username}&consumer_secret=${widget.password}";
  //   setState(() {
  //     isProductTaxClassesError = false;
  //     isProductTaxClassesReady = false;
  //   });
  //   http.Response response;
  //   try {
  //     response = await http.get(url);
  //     if (response.statusCode == 200) {
  //       dynamic responseBody = json.decode(response.body);
  //       if (responseBody is List && responseBody.length > 0) {
  //         setState(() {
  //           productTaxClasses = responseBody;
  //           isProductTaxClassesReady = true;
  //           isProductTaxClassesError = false;
  //         });
  //       } else {
  //         setState(() {
  //           isProductTaxClassesReady = false;
  //           isProductTaxClassesError = true;
  //           productTaxClassesError = "Failed to fetch product tax classes";
  //         });
  //       }
  //     } else {
  //       String errorCode = "";
  //       if (json.decode(response.body) is Map &&
  //           json.decode(response.body).containsKey("code") &&
  //           json.decode(response.body)["code"] is String) {
  //         errorCode = json.decode(response.body)["code"];
  //       }
  //       setState(() {
  //         isProductTaxClassesReady = false;
  //         isProductTaxClassesError = true;
  //         productTaxClassesError =
  //             "Failed to fetch product tax classes. Error: $errorCode";
  //       });
  //     }
  //   } on SocketException catch (_) {
  //     setState(() {
  //       isProductTaxClassesReady = false;
  //       isProductTaxClassesError = true;
  //       productTaxClassesError =
  //           "Failed to fetch product tax classes. Error: Network not reachable";
  //     });
  //   } catch (e) {
  //     setState(() {
  //       isProductTaxClassesReady = false;
  //       isProductTaxClassesError = true;
  //       productTaxClassesError =
  //           "Failed to fetch product tax classes. Error: $e";
  //     });
  //   }
  // }

  Future<void> updateProductData() async {
    Map<String, dynamic> updatedProductData = {};

    if (regularPrice is String) {
      updatedProductData["regular_price"] = regularPrice;
    }

    if (salePrice is String) {
      updatedProductData["sale_price"] = salePrice;
    }

    if (_showSaleDates) {
      if (dateOnSaleFrom == null) {
        updatedProductData["date_on_sale_from"] = "";
      } else if (dateOnSaleFrom is DateTime) {
        updatedProductData["date_on_sale_from"] =
            DateFormat("yyyy-MM-dd").format(dateOnSaleFrom);
      }

      if (dateOnSaleTo == null) {
        updatedProductData["date_on_sale_to"] = "";
      } else if (dateOnSaleTo is DateTime) {
        updatedProductData["date_on_sale_to"] =
            DateFormat("yyyy-MM-dd").format(dateOnSaleTo);
      }
    } else {
      updatedProductData["date_on_sale_from"] = "";
      updatedProductData["date_on_sale_to"] = "";
    }

    if (taxStatus is String && taxStatus.isNotEmpty) {
      updatedProductData["tax_status"] = taxStatus;
    }

    Products productsListData = Provider.of<Products>(context, listen: false);
    int productIndex = productsListData.getProductIndexById(widget.id);
    if (productIndex >= 0) {
      String url =
          "${widget.baseurl}/wp-json/wc/v3/products/${widget.id}?consumer_key=${widget.username}&consumer_secret=${widget.password}";
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
            Product newProduct = Product.fromJson(responseBody);
            productsListData.replaceProductById(widget.id, newProduct);
            Navigator.pop(
                context, "Product pricing details updated successfully...");
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
              content: Text(
                  "Failed to update product, try again. Error: $errorCode"),
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
    } else {
      scaffoldKey.currentState.showSnackBar(
        SnackBar(
          content:
              Text("Failed to update product, try again. Error: Can't find product index"),
          duration: Duration(seconds: 3),
        ),
      );
    }
  }
}

//For Custom Cancel Button in DatePicker
class CancelButtonLocalizationDelegate
    extends LocalizationsDelegate<MaterialLocalizations> {
  const CancelButtonLocalizationDelegate();

  @override
  bool isSupported(Locale locale) => locale.languageCode == 'en';

  @override
  Future<MaterialLocalizations> load(Locale locale) =>
      Future.value(CancelButtonLocalization());

  @override
  bool shouldReload(CancelButtonLocalizationDelegate old) => false;
}

class CancelButtonLocalization extends DefaultMaterialLocalizations {
  const CancelButtonLocalization();

  @override
  String get cancelButtonLabel => "Clear";
}
