import 'dart:convert';
import 'dart:io';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:recase/recase.dart';
import 'package:unicorndial/unicorndial.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:validators/sanitizers.dart';
import 'package:woocommerceadmin/src/common/widgets/ImageViewer.dart';
import 'package:woocommerceadmin/src/products/widgets/EditProductInventoryPage.dart';
import 'package:woocommerceadmin/src/products/widgets/EditProductPage.dart';
import 'package:woocommerceadmin/src/products/widgets/EditProductPricingPage.dart';

class ProductDetailsPage extends StatefulWidget {
  final String baseurl;
  final String username;
  final String password;
  final int id;
  ProductDetailsPage(
      {Key key,
      @required this.baseurl,
      @required this.username,
      @required this.password,
      @required this.id})
      : super(key: key);

  @override
  _ProductDetailsPageState createState() => _ProductDetailsPageState();
}

class _ProductDetailsPageState extends State<ProductDetailsPage> {
  Map productDetails = Map();
  bool isProductDataReady = false;
  bool isProductDataError = false;
  String productDataError;

  final scaffoldKey = new GlobalKey<ScaffoldState>();
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      new GlobalKey<RefreshIndicatorState>();

  @override
  void initState() {
    super.initState();
    fetchProductDetails();
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
        title: Text("Product Details"),
      ),
      body: !isProductDataReady
          ? !isProductDataError
              ? _mainLoadingWidget()
              : _productDataErrorWidget()
          : RefreshIndicator(
              key: _refreshIndicatorKey,
              onRefresh: fetchProductDetails,
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                padding: const EdgeInsets.all(0.0),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      _productHeadlineWidget(),
                      _productImagesWidget(),
                      _productGeneralWidget(),
                      _productPriceWidget(),
                      _productInventoryWidget(),
                      _productShippingWidget(),
                      _productReviewsWidget(),
                      _productCategoriesWidget(),
                      _productAttributesWidget(),
                    ]),
              ),
            ),
      floatingActionButton: isProductDataReady
          ? UnicornDialer(
              backgroundColor: Color.fromRGBO(100, 100, 100, 0.7),
              parentButtonBackground:
                  Theme.of(context).floatingActionButtonTheme.backgroundColor,
              orientation: UnicornOrientation.VERTICAL,
              parentButton: Icon(Icons.add),
              childButtons: <UnicornButton>[
                UnicornButton(
                    hasLabel: false,
                    labelText: "  Edit  ",
                    currentButton: FloatingActionButton(
                      heroTag: "edit",
                      backgroundColor: Colors.purple,
                      mini: true,
                      child: Icon(Icons.edit),
                      onPressed: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => EditProductPage(
                                    baseurl: widget.baseurl,
                                    username: widget.username,
                                    password: widget.password,
                                    id: widget.id,
                                  )),
                        );
                        if (result is String) {
                          fetchProductDetails();
                          scaffoldKey.currentState.showSnackBar(SnackBar(
                            content: Text(result.toString()),
                            duration: Duration(seconds: 3),
                          ));
                        }
                      },
                    )),
                UnicornButton(
                    hasLabel: false,
                    labelText: "Delete",
                    currentButton: FloatingActionButton(
                      heroTag: "delete",
                      backgroundColor: Colors.redAccent,
                      mini: true,
                      child: Icon(Icons.delete),
                      onPressed: () {},
                    )),
              ],
            )
          : SizedBox.shrink(),
    );
  }

  Future<Null> fetchProductDetails() async {
    String url =
        "${widget.baseurl}/wp-json/wc/v3/products/${widget.id}?consumer_key=${widget.username}&consumer_secret=${widget.password}";
    setState(() {
      isProductDataError = false;
      isProductDataReady = false;
    });
    http.Response response;
    try {
      response = await http.get(url);
      if (response.statusCode == 200) {
        dynamic responseBody = json.decode(response.body);
        if (responseBody is Map &&
            responseBody.containsKey("id") &&
            responseBody["id"] != null) {
          setState(() {
            productDetails = responseBody;
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

  Widget _productImagesWidget() {
    Widget productImagesWidget = SizedBox.shrink();
    if (isProductDataReady &&
        productDetails.containsKey("images") &&
        productDetails["images"] is List &&
        productDetails["images"].length > 0) {
      List<String> imagesSrcList = [];
      for (int i = 0; i < productDetails["images"].length; i++) {
        imagesSrcList.add(productDetails["images"][i]["src"]);
      }
      productImagesWidget = Container(
        height: 150,
        child: Padding(
          padding: const EdgeInsets.all(5.0),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: imagesSrcList.length,
            itemBuilder: (context, index) {
              return InkWell(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ImageViewer(
                                imagesData: imagesSrcList,
                                index: index,
                                isNetworkList: true,
                              )));
                },
                child: ExtendedImage.network(
                  imagesSrcList[index],
                  height: 150.0,
                  width: 150.0,
                  fit: BoxFit.contain,
                  cache: true,
                  enableLoadState: true,
                  loadStateChanged: (ExtendedImageState state) {
                    if (state.extendedImageLoadState == LoadState.loading) {
                      return SpinKitPulse(
                        color: Theme.of(context).primaryColor,
                        size: 50,
                      );
                    }
                    return null;
                  },
                ),
              );
            },
          ),
        ),
      );
    }
    return productImagesWidget;
  }

  Widget _productHeadlineWidget() {
    Widget productHeadlineWidget = SizedBox.shrink();
    if (isProductDataReady &&
        productDetails.containsKey("name") &&
        productDetails["name"] is String) {
      productHeadlineWidget = Container(
        child: Row(
          children: <Widget>[
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 10.0),
                child: Column(
                  children: <Widget>[
                    Text(
                      productDetails["name"],
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.headline,
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
        padding: const EdgeInsets.all(0.0),
        alignment: Alignment.center,
      );
    }
    return productHeadlineWidget;
  }

  Widget _getItemRow(String item1, String item2, {bool linkify = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          item1,
          style: Theme.of(context).textTheme.body1.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        Flexible(
          child: linkify
              ? Text.rich(
                  TextSpan(
                    text: item2,
                    style: TextStyle(color: Colors.blue),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () async {
                        if (await canLaunch(item2)) {
                          await launch(item2);
                        } else {
                          scaffoldKey.currentState.showSnackBar(SnackBar(
                            content: Text("Could not open url"),
                            duration: Duration(seconds: 3),
                          ));
                        }
                      },
                  ),
                )
              : Text(
                  item2,
                  style: Theme.of(context).textTheme.body1,
                ),
        ),
      ],
    );
  }

  ExpansionTile _getExpansionTile(String title, List<Widget> itemWidgetsList,
      {Function onTap}) {
    return ExpansionTile(
      title: Text(
        title,
        style: Theme.of(context).textTheme.subhead,
      ),
      initiallyExpanded: true,
      children: <Widget>[
        InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(25, 0, 15, 10),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: itemWidgetsList),
                ),
                Center(
                  child: Icon(Icons.arrow_right),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _productGeneralWidget() {
    Widget productGeneralWidget = SizedBox.shrink();

    if (isProductDataReady) {
      List<Widget> productGeneralWidgetData = [];

      if (productDetails.containsKey("id") && productDetails["id"] is int) {
        productGeneralWidgetData.add(
          _getItemRow("Id: ", "${productDetails["id"]}"),
        );
      }

      if (productDetails.containsKey("slug") &&
          productDetails["slug"] is String &&
          productDetails["slug"].isNotEmpty) {
        productGeneralWidgetData.add(
          _getItemRow("Slug: ", "${productDetails["slug"]}"),
        );
      }

      if (productDetails.containsKey("permalink") &&
          productDetails["permalink"] is String &&
          productDetails["permalink"].isNotEmpty) {
        productGeneralWidgetData.add(
          _getItemRow("Permalink: ", "${productDetails["permalink"]}",
              linkify: true),
        );
      }

      if (productDetails.containsKey("type") &&
          productDetails["type"] is String &&
          productDetails["type"].isNotEmpty) {
        productGeneralWidgetData.add(
          _getItemRow("Type: ", "${productDetails["type"]}"),
        );
      }

      if (productDetails.containsKey("sku") &&
          productDetails["sku"] is String &&
          productDetails["sku"].isNotEmpty) {
        productGeneralWidgetData.add(
          _getItemRow("Sku: ", "${productDetails["sku"]}"),
        );
      }

      if (productDetails.containsKey("status") &&
          productDetails["status"] is String &&
          productDetails["status"].isNotEmpty) {
        productGeneralWidgetData.add(_getItemRow(
            "Status: ", productDetails["status"].toString().titleCase));
      }

      if (productDetails.containsKey("catalog_visibility") &&
          productDetails["catalog_visibility"] is String &&
          productDetails["catalog_visibility"].isNotEmpty) {
        productGeneralWidgetData.add(_getItemRow("Catalog visibility: ",
            productDetails["catalog_visibility"].toString().titleCase));
      }

      if (productDetails.containsKey("purchasable") &&
          productDetails["purchasable"] is bool) {
        productGeneralWidgetData.add(_getItemRow(
            "Purchasable: ", productDetails["purchasable"] ? "Yes" : "No"));
      }

      if (productDetails.containsKey("featured") &&
          productDetails["featured"] is bool) {
        productGeneralWidgetData.add(
          _getItemRow("Featured: ", productDetails["featured"] ? "Yes" : "No"),
        );
      }

      if (productDetails.containsKey("on_sale") &&
          productDetails["on_sale"] is bool) {
        productGeneralWidgetData.add(
          _getItemRow("On Sale: ", productDetails["on_sale"] ? "Yes" : "No"),
        );
      }

      if (productDetails.containsKey("virtual") &&
          productDetails["virtual"] is bool) {
        productGeneralWidgetData.add(
          _getItemRow("Virtual: ", productDetails["virtual"] ? "Yes" : "No"),
        );
      }

      if (productDetails.containsKey("downloadable") &&
          productDetails["downloadable"] is bool) {
        productGeneralWidgetData.add(
          _getItemRow(
              "Downloadable: ", productDetails["downloadable"] ? "Yes" : "No"),
        );
      }

      if (productDetails.containsKey("total_sales") &&
          productDetails["total_sales"] is String &&
          productDetails["total_sales"].isNotEmpty) {
        productGeneralWidgetData.add(
          _getItemRow("Total ordered: ", "${productDetails["total_sales"]}"),
        );
      }

      if (productDetails.containsKey("backordered") &&
          productDetails["backordered"] is bool) {
        productGeneralWidgetData.add(
          _getItemRow(
              "Backordered: ", productDetails["backordered"] ? "Yes" : "No"),
        );
      }

      if (productGeneralWidgetData.isNotEmpty) {
        productGeneralWidget = _getExpansionTile(
          "General",
          productGeneralWidgetData,
        );
      }
    }
    return productGeneralWidget;
  }

  Widget _productPriceWidget() {
    Widget productPriceWidget = SizedBox.shrink();

    if (isProductDataReady) {
      List<Widget> pricePriceWidgetData = [];

      if (productDetails.containsKey("regular_price") &&
          productDetails["regular_price"] is String &&
          productDetails["regular_price"].isNotEmpty) {
        pricePriceWidgetData.add(
          _getItemRow("Regular price: ", productDetails["regular_price"]),
        );
      }

      if (productDetails.containsKey("sale_price") &&
          productDetails["sale_price"] is String &&
          productDetails["sale_price"].isNotEmpty) {
        pricePriceWidgetData.add(
          _getItemRow("Sale price: ", productDetails["sale_price"]),
        );
      }

      if (productDetails.containsKey("date_on_sale_from") &&
          productDetails["date_on_sale_from"] is String &&
          productDetails["date_on_sale_from"].isNotEmpty) {
        pricePriceWidgetData.add(
          _getItemRow(
            "Sale Price from: ",
            DateFormat("EEEE, dd/MM/yyyy")
                .format(DateTime.parse(productDetails["date_on_sale_from"])),
          ),
        );
      }

      if (productDetails.containsKey("date_on_sale_to") &&
          productDetails["date_on_sale_to"] is String &&
          productDetails["date_on_sale_to"].isNotEmpty) {
        pricePriceWidgetData.add(
          _getItemRow(
            "Sale Price to: ",
            DateFormat("EEEE, dd/MM/yyyy")
                .format(DateTime.parse(productDetails["date_on_sale_to"])),
          ),
        );
      }

      if (productDetails.containsKey("tax_status") &&
          productDetails["tax_status"] is String &&
          productDetails["tax_status"].isNotEmpty) {
        pricePriceWidgetData.add(
          _getItemRow("Tax status: ",
              productDetails["tax_status"].toString().titleCase),
        );
      }

      if (productDetails.containsKey("tax_class") &&
          productDetails["tax_class"] is String &&
          productDetails["tax_class"].isNotEmpty) {
        pricePriceWidgetData.add(
          _getItemRow("Tax class: ", productDetails["tax_class"]),
        );
      }

      if (pricePriceWidgetData.isNotEmpty) {
        productPriceWidget = _getExpansionTile(
          "Pricing",
          pricePriceWidgetData,
          onTap: () {
            String regularPrice = "";
            if (productDetails is Map &&
                productDetails.containsKey("regular_price") &&
                productDetails["regular_price"] is String &&
                productDetails["regular_price"].isNotEmpty) {
              regularPrice = productDetails["regular_price"];
            }

            String salePrice = "";
            if (productDetails is Map &&
                productDetails.containsKey("sale_price") &&
                productDetails["sale_price"] is String &&
                productDetails["sale_price"].isNotEmpty) {
              salePrice = productDetails["sale_price"];
            }

            DateTime dateOnSaleFrom;
            if (productDetails is Map &&
                productDetails.containsKey("date_on_sale_from")) {
              dateOnSaleFrom = toDate(productDetails["date_on_sale_from"]);
            }

            DateTime dateOnSaleTo;
            if (productDetails is Map &&
                productDetails.containsKey("date_on_sale_to")) {
              dateOnSaleTo = toDate(productDetails["date_on_sale_to"]);
            }

            String taxStatus = "";
            if (productDetails is Map &&
                productDetails.containsKey("tax_status") &&
                productDetails["tax_status"] is String &&
                productDetails["tax_status"].isNotEmpty) {
              taxStatus = productDetails["tax_status"];
            }

            String taxClass = "";
            if (productDetails is Map &&
                productDetails.containsKey("tax_class") &&
                productDetails["tax_class"] is String &&
                productDetails["tax_class"].isNotEmpty) {
              taxClass = productDetails["tax_class"];
            }

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => EditProductPricingPage(
                  baseurl: widget.baseurl,
                  username: widget.username,
                  password: widget.password,
                  regularPrice: regularPrice,
                  salePrice: salePrice,
                  dateOnSaleFrom: dateOnSaleFrom,
                  dateOnSaleTo: dateOnSaleTo,
                  taxStatus: taxStatus,
                  taxClass: taxClass,
                ),
              ),
            );
          },
        );
      }
    }
    return productPriceWidget;
  }

  Widget _productInventoryWidget() {
    Widget productInventoryWidget = SizedBox.shrink();
    if (isProductDataReady) {
      List<Widget> productInventoryWidgetData = [];

      if (productDetails.containsKey("stock_status") &&
          productDetails["stock_status"] is String &&
          productDetails["stock_status"].isNotEmpty) {
        productInventoryWidgetData.add(
          _getItemRow("Stock status: ",
              productDetails["stock_status"].toString().titleCase),
        );
      }

      if (productDetails.containsKey("manage_stock") &&
          productDetails["manage_stock"] is bool) {
        productInventoryWidgetData.add(
          _getItemRow("Manage stock: ",
              (productDetails["manage_stock"] ? "Yes" : "No")),
        );
      }

      if (productDetails.containsKey("stock_quantity") &&
          productDetails["stock_quantity"] is int) {
        productInventoryWidgetData.add(
          _getItemRow("Stock qty: ", "${productDetails["stock_quantity"]}"),
        );
      }

      if (productDetails.containsKey("backorders_allowed") &&
          productDetails["backorders_allowed"] is bool) {
        productInventoryWidgetData.add(
          _getItemRow("Backorders allowed: ",
              productDetails["backorders_allowed"] ? "Yes" : "No"),
        );
      }

      if (productDetails.containsKey("backorders") &&
          productDetails["backorders"] is String &&
          productDetails["backorders"].isNotEmpty) {
        productInventoryWidgetData.add(
          _getItemRow("Backorders: ",
              productDetails["backorders"].toString().titleCase),
        );
      }

      if (productDetails.containsKey("sold_individually") &&
          productDetails["sold_individually"] is bool) {
        productInventoryWidgetData.add(
          _getItemRow("Sold individually: ",
              productDetails["sold_individually"] ? "Yes" : "No"),
        );
      }

      if (productInventoryWidgetData.isNotEmpty) {
        productInventoryWidget = _getExpansionTile(
          "Inventory",
          productInventoryWidgetData,
          onTap: () {
            String stockStatus = "";
            if (productDetails is Map &&
                productDetails.containsKey("stock_status") &&
                productDetails["stock_status"] is String &&
                productDetails["stock_status"].isNotEmpty) {
              stockStatus = productDetails["stock_status"];
            }

            bool manageStock = false;
            if (productDetails is Map &&
                productDetails.containsKey("manage_stock") &&
                productDetails["manage_stock"] is bool) {
              manageStock = productDetails["manage_stock"];
            }

            int stockQuantity;
            if (productDetails is Map &&
                productDetails.containsKey("stock_quantity") &&
                productDetails["stock_quantity"] is int) {
              stockQuantity = productDetails["stock_quantity"];
            }

            bool backordersAllowed = false;
            if (productDetails is Map &&
                productDetails.containsKey("backorders_allowed") &&
                productDetails["backorders_allowed"] is bool) {
              backordersAllowed = productDetails["backorders_allowed"];
            }

            String backorders = "";
            if (productDetails is Map &&
                productDetails.containsKey("backorders") &&
                productDetails["backorders"] is String &&
                productDetails["backorders"].isNotEmpty) {
              backorders = productDetails["backorders"];
            }

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => EditProductInventoryPage(
                  stockStatus: stockStatus,
                  manageStock: manageStock,
                  stockQuantity: stockQuantity,
                  backordersAllowed: backordersAllowed,
                  backorders: backorders,
                ),
              ),
            );
          },
        );
      }
    }
    return productInventoryWidget;
  }

  Widget _productShippingWidget() {
    Widget productShippingWidget = SizedBox.shrink();

    if (isProductDataReady) {
      List<Widget> productShippingWidgetData = [];

      if (productDetails.containsKey("weight") &&
          productDetails["weight"] is String &&
          productDetails["weight"].isNotEmpty) {
        productShippingWidgetData.add(
          _getItemRow("Weight: ", productDetails["weight"]),
        );
      }

      if (productDetails.containsKey("dimensions") &&
          productDetails["dimensions"] is Map) {
        if (productDetails["dimensions"].containsKey("length") &&
            productDetails["dimensions"]["length"] is String &&
            productDetails["dimensions"]["length"].isNotEmpty) {
          productShippingWidgetData.add(
            _getItemRow("Length: ", productDetails["dimensions"]["length"]),
          );
        }

        if (productDetails["dimensions"].containsKey("width") &&
            productDetails["dimensions"]["width"] is String &&
            productDetails["dimensions"]["width"].isNotEmpty) {
          productShippingWidgetData.add(
            _getItemRow("Width: ", productDetails["dimensions"]["width"]),
          );
        }

        if (productDetails["dimensions"].containsKey("height") &&
            productDetails["dimensions"]["height"] is String &&
            productDetails["dimensions"]["height"].isNotEmpty) {
          productShippingWidgetData.add(
            _getItemRow("Height: ", productDetails["dimensions"]["height"]),
          );
        }
      }

      if (productDetails.containsKey("shipping_required") &&
          productDetails["shipping_required"] is bool) {
        productShippingWidgetData.add(
          _getItemRow("Shipping required: ",
              productDetails["shipping_required"] ? "Yes" : "No"),
        );
      }

      if (productDetails.containsKey("shipping_taxable") &&
          productDetails["shipping_taxable"] is bool) {
        productShippingWidgetData.add(
          _getItemRow("Shipping taxable: ",
              productDetails["shipping_taxable"] ? "Yes" : "No"),
        );
      }

      if (productDetails.containsKey("shipping_class") &&
          productDetails["shipping_class"] is String &&
          productDetails["shipping_class"].isNotEmpty) {
        productShippingWidgetData.add(
          _getItemRow("Shipping class: ",
              productDetails["shipping_class"] ? "Yes" : "No"),
        );
      }

      if (productShippingWidgetData.isNotEmpty) {
        productShippingWidget =
            _getExpansionTile("Shipping", productShippingWidgetData);
      }
    }
    return productShippingWidget;
  }

  Widget _productReviewsWidget() {
    Widget productReviewsWidget = SizedBox.shrink();

    if (isProductDataReady) {
      List<Widget> productReviewsWidgetData = [];

      if (productDetails.containsKey("reviews_allowed") &&
          productDetails["reviews_allowed"] is bool) {
        productReviewsWidgetData.add(
          _getItemRow("Reviews allowed: ",
              (productDetails["reviews_allowed"] ? "Yes" : "No")),
        );
      }

      if (productDetails.containsKey("average_rating") &&
          productDetails["average_rating"] is String &&
          productDetails["average_rating"].isNotEmpty) {
        productReviewsWidgetData.add(
          _getItemRow("Average rating: ", productDetails["average_rating"]),
        );
      }

      if (productDetails.containsKey("rating_count") &&
          productDetails["rating_count"] is int) {
        productReviewsWidgetData.add(
          _getItemRow("Rating count: ", "${productDetails["rating_count"]}"),
        );
      }

      if (productReviewsWidgetData.isNotEmpty) {
        productReviewsWidget =
            _getExpansionTile("Reviews", productReviewsWidgetData);
      }
    }
    return productReviewsWidget;
  }

  Widget _productCategoriesWidget() {
    Widget productCategoriesWidget = SizedBox.shrink();

    if (isProductDataReady &&
        productDetails.containsKey("categories") &&
        productDetails["categories"] is List &&
        productDetails["categories"].isNotEmpty) {
      List<Widget> productCategoriesWidgetData = [
        Wrap(
          spacing: 5,
          children: <Widget>[
            for (var i = 0; i < productDetails["categories"].length; i++)
              if (productDetails["categories"][i].containsKey("name") &&
                  productDetails["categories"][i]["name"] is String &&
                  productDetails["categories"][i]["name"].isNotEmpty)
                Container(
                  height: 40,
                  child: Chip(
                    label: Text(
                      productDetails["categories"][i]["name"],
                      style: Theme.of(context).textTheme.body1,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    // backgroundColor: Color(0xffededed),
                  ),
                ),
          ],
        )
      ];

      if (productCategoriesWidgetData.isNotEmpty) {
        productCategoriesWidget =
            _getExpansionTile("Categories", productCategoriesWidgetData);
      }
    }
    return productCategoriesWidget;
  }

  Widget _productAttributesWidget() {
    Widget productAttributesWidget = SizedBox.shrink();
    List<Widget> productAttributesWidgetData = [];

    if (isProductDataReady &&
        productDetails.containsKey("attributes") &&
        productDetails["attributes"] is List &&
        productDetails["attributes"].isNotEmpty) {
      for (int i = 0; i < productDetails["attributes"].length; i++) {
        if (productDetails["attributes"][i] is Map &&
            productDetails["attributes"][i].containsKey("name") &&
            productDetails["attributes"][i]["name"] is String &&
            productDetails["attributes"][i]["name"].isNotEmpty) {
          String attributeName = "${productDetails["attributes"][i]["name"]}: ";
          String attributeOptions = "";

          if (productDetails["attributes"][i].containsKey("options") &&
              productDetails["attributes"][i]["options"] is List &&
              productDetails["attributes"][i]["options"].isNotEmpty) {
            for (int j = 0;
                j < productDetails["attributes"][i]["options"].length;
                j++) {
              if (productDetails["attributes"][i]["options"][j] is String &&
                  productDetails["attributes"][i]["options"][j].isNotEmpty) {
                attributeOptions +=
                    (j == productDetails["attributes"][i]["options"].length - 1
                        ? productDetails["attributes"][i]["options"][j]
                        : "${productDetails["attributes"][i]["options"][j]}, ");
              }
            }
          }
          productAttributesWidgetData.add(
            _getItemRow(attributeName, attributeOptions),
          );
        }
      }
      if (productAttributesWidgetData.isNotEmpty) {
        productAttributesWidget =
            _getExpansionTile("Attributes", productAttributesWidgetData);
      }
    }
    return productAttributesWidget;
  }
}
