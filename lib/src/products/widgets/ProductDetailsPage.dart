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
import 'package:woocommerceadmin/src/products/widgets/EditProduct/EditProductGeneralPage.dart';
import 'package:woocommerceadmin/src/products/widgets/EditProduct/EditProductInventoryPage.dart';
import 'package:woocommerceadmin/src/products/widgets/EditProduct/EditProductPricingPage.dart';
import 'package:woocommerceadmin/src/products/widgets/EditProduct/EditProductShippingPage.dart';
import 'package:woocommerceadmin/src/products/widgets/EditProductPage.dart';

class ProductDetailsPage extends StatefulWidget {
  final String baseurl;
  final String username;
  final String password;
  final int id;
  final Map<String, dynamic> productData;
  final bool preFetch;

  ProductDetailsPage({
    Key key,
    @required this.baseurl,
    @required this.username,
    @required this.password,
    @required this.id,
    this.productData,
    this.preFetch,
  }) : super(key: key);

  @override
  _ProductDetailsPageState createState() => _ProductDetailsPageState();
}

class _ProductDetailsPageState extends State<ProductDetailsPage> {
  Map productData = Map();
  bool isProductDataReady = true;
  bool isProductDataError = false;
  String productDataError;

  final scaffoldKey = new GlobalKey<ScaffoldState>();
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      new GlobalKey<RefreshIndicatorState>();

  @override
  void initState() {
    if (widget.preFetch ?? true) {
      fetchProductDetails();
    } else {
      if (widget.productData is Map &&
          widget.productData.containsKey("id") &&
          widget.productData["id"] is int) {
        productData = widget.productData;
      } else {
        fetchProductDetails();
      }
    }
    super.initState();
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
                          scaffoldKey.currentState.showSnackBar(
                            SnackBar(
                              content: Text(result.toString()),
                              duration: Duration(seconds: 3),
                            ),
                          );
                          fetchProductDetails();
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
        productData.containsKey("images") &&
        productData["images"] is List &&
        productData["images"].length > 0) {
      List<String> imagesSrcList = [];
      for (int i = 0; i < productData["images"].length; i++) {
        imagesSrcList.add(productData["images"][i]["src"]);
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
                      ),
                    ),
                  );
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
        productData.containsKey("name") &&
        productData["name"] is String) {
      productHeadlineWidget = Container(
        child: Row(
          children: <Widget>[
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 10.0),
                child: Column(
                  children: <Widget>[
                    Text(
                      productData["name"],
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
                          Scaffold.of(context).showSnackBar(SnackBar(
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
      {bool isTappable = false, Function onTap}) {
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
                if (isTappable)
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

      if (productData.containsKey("id") && productData["id"] is int) {
        productGeneralWidgetData.add(
          _getItemRow("Id: ", "${productData["id"]}"),
        );
      }

      if (productData.containsKey("slug") &&
          productData["slug"] is String &&
          productData["slug"].isNotEmpty) {
        productGeneralWidgetData.add(
          _getItemRow("Slug: ", "${productData["slug"]}"),
        );
      }

      if (productData.containsKey("permalink") &&
          productData["permalink"] is String &&
          productData["permalink"].isNotEmpty) {
        productGeneralWidgetData.add(
          _getItemRow("Permalink: ", "${productData["permalink"]}",
              linkify: true),
        );
      }

      if (productData.containsKey("type") &&
          productData["type"] is String &&
          productData["type"].isNotEmpty) {
        productGeneralWidgetData.add(
          _getItemRow("Type: ", "${productData["type"]}"),
        );
      }

      if (productData.containsKey("status") &&
          productData["status"] is String &&
          productData["status"].isNotEmpty) {
        productGeneralWidgetData.add(_getItemRow(
            "Status: ", productData["status"].toString().titleCase));
      }

      if (productData.containsKey("catalog_visibility") &&
          productData["catalog_visibility"] is String &&
          productData["catalog_visibility"].isNotEmpty) {
        productGeneralWidgetData.add(_getItemRow("Catalog visibility: ",
            productData["catalog_visibility"].toString().titleCase));
      }

      if (productData.containsKey("purchasable") &&
          productData["purchasable"] is bool) {
        productGeneralWidgetData.add(_getItemRow(
            "Purchasable: ", productData["purchasable"] ? "Yes" : "No"));
      }

      if (productData.containsKey("featured") &&
          productData["featured"] is bool) {
        productGeneralWidgetData.add(
          _getItemRow("Featured: ", productData["featured"] ? "Yes" : "No"),
        );
      }

      if (productData.containsKey("on_sale") &&
          productData["on_sale"] is bool) {
        productGeneralWidgetData.add(
          _getItemRow("On Sale: ", productData["on_sale"] ? "Yes" : "No"),
        );
      }

      if (productData.containsKey("virtual") &&
          productData["virtual"] is bool) {
        productGeneralWidgetData.add(
          _getItemRow("Virtual: ", productData["virtual"] ? "Yes" : "No"),
        );
      }

      if (productData.containsKey("downloadable") &&
          productData["downloadable"] is bool) {
        productGeneralWidgetData.add(
          _getItemRow(
              "Downloadable: ", productData["downloadable"] ? "Yes" : "No"),
        );
      }

      if (productData.containsKey("total_sales") &&
          productData["total_sales"] is String &&
          productData["total_sales"].isNotEmpty) {
        productGeneralWidgetData.add(
          _getItemRow("Total ordered: ", "${productData["total_sales"]}"),
        );
      }

      if (productData.containsKey("backordered") &&
          productData["backordered"] is bool) {
        productGeneralWidgetData.add(
          _getItemRow(
              "Backordered: ", productData["backordered"] ? "Yes" : "No"),
        );
      }

      if (productGeneralWidgetData.isNotEmpty) {
        productGeneralWidget = _getExpansionTile(
          "General",
          productGeneralWidgetData,
          isTappable: true,
          onTap: () {
            String slug;
            if (productData.containsKey("slug") &&
                productData["slug"] is String &&
                productData["slug"].isNotEmpty) {
              slug = productData["slug"];
            }

            String type;
            if (productData.containsKey("type") &&
                productData["type"] is String &&
                productData["type"].isNotEmpty) {
              type = productData["type"];
            }

            String status;
            if (productData.containsKey("status") &&
                productData["status"] is String &&
                productData["status"].isNotEmpty) {
              status = productData["status"];
            }

            String catalogVisibility;
            if (productData.containsKey("catalog_visibility") &&
                productData["catalog_visibility"] is String &&
                productData["catalog_visibility"].isNotEmpty) {
              catalogVisibility = productData["catalog_visibility"];
            }

            bool featured = false;
            if (productData.containsKey("featured") &&
                productData["featured"] is bool) {
              featured = productData["featured"];
            }

            bool virtual = false;
            if (productData.containsKey("virtual") &&
                productData["virtual"] is bool) {
              virtual = productData["virtual"];
            }

            bool downloadable = false;
            if (productData.containsKey("downloadable") &&
                productData["downloadable"] is bool) {
              downloadable = productData["downloadable"];
            }

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => EditProductGeneralPage(
                  slug: slug,
                  type: type,
                  status: status,
                  catalogVisibility: catalogVisibility,
                  featured: featured,
                  virtual: virtual,
                  downloadable: downloadable,
                ),
              ),
            );
          },
        );
      }
    }
    return productGeneralWidget;
  }

  Widget _productPriceWidget() {
    Widget productPriceWidget = SizedBox.shrink();

    if (isProductDataReady) {
      List<Widget> pricePriceWidgetData = [];

      if (productData.containsKey("regular_price") &&
          productData["regular_price"] is String &&
          productData["regular_price"].isNotEmpty) {
        pricePriceWidgetData.add(
          _getItemRow("Regular price: ", productData["regular_price"]),
        );
      }

      if (productData.containsKey("sale_price") &&
          productData["sale_price"] is String &&
          productData["sale_price"].isNotEmpty) {
        pricePriceWidgetData.add(
          _getItemRow("Sale price: ", productData["sale_price"]),
        );
      }

      if (productData.containsKey("date_on_sale_from") &&
          productData["date_on_sale_from"] is String &&
          productData["date_on_sale_from"].isNotEmpty) {
        pricePriceWidgetData.add(
          _getItemRow(
            "Sale Price from: ",
            DateFormat("EEEE, dd/MM/yyyy")
                .format(DateTime.parse(productData["date_on_sale_from"])),
          ),
        );
      }

      if (productData.containsKey("date_on_sale_to") &&
          productData["date_on_sale_to"] is String &&
          productData["date_on_sale_to"].isNotEmpty) {
        pricePriceWidgetData.add(
          _getItemRow(
            "Sale Price to: ",
            DateFormat("EEEE, dd/MM/yyyy")
                .format(DateTime.parse(productData["date_on_sale_to"])),
          ),
        );
      }

      if (productData.containsKey("tax_status") &&
          productData["tax_status"] is String &&
          productData["tax_status"].isNotEmpty) {
        pricePriceWidgetData.add(
          _getItemRow(
              "Tax status: ", productData["tax_status"].toString().titleCase),
        );
      }

      if (productData.containsKey("tax_class") &&
          productData["tax_class"] is String &&
          productData["tax_class"].isNotEmpty) {
        pricePriceWidgetData.add(
          _getItemRow("Tax class: ", productData["tax_class"]),
        );
      }

      if (pricePriceWidgetData.isNotEmpty) {
        productPriceWidget = _getExpansionTile(
          "Pricing",
          pricePriceWidgetData,
          isTappable: true,
          onTap: () async {
            String regularPrice;
            if (productData.containsKey("regular_price") &&
                productData["regular_price"] is String &&
                productData["regular_price"].isNotEmpty) {
              regularPrice = productData["regular_price"];
            }

            String salePrice;
            if (productData.containsKey("sale_price") &&
                productData["sale_price"] is String &&
                productData["sale_price"].isNotEmpty) {
              salePrice = productData["sale_price"];
            }

            DateTime dateOnSaleFrom;
            if (productData.containsKey("date_on_sale_from")) {
              dateOnSaleFrom = toDate(productData["date_on_sale_from"]);
            }

            DateTime dateOnSaleTo;
            if (productData.containsKey("date_on_sale_to")) {
              dateOnSaleTo = toDate(productData["date_on_sale_to"]);
            }

            String taxStatus;
            if (productData.containsKey("tax_status") &&
                productData["tax_status"] is String &&
                productData["tax_status"].isNotEmpty) {
              taxStatus = productData["tax_status"];
            }

            String taxClass;
            if (productData.containsKey("tax_class") &&
                productData["tax_class"] is String &&
                productData["tax_class"].isNotEmpty) {
              taxClass = productData["tax_class"];
            }

            String result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => EditProductPricingPage(
                  baseurl: widget.baseurl,
                  username: widget.username,
                  password: widget.password,
                  id: widget.id,
                  regularPrice: regularPrice,
                  salePrice: salePrice,
                  dateOnSaleFrom: dateOnSaleFrom,
                  dateOnSaleTo: dateOnSaleTo,
                  taxStatus: taxStatus,
                  taxClass: taxClass,
                ),
              ),
            );

            if (result is String) {
              scaffoldKey.currentState.showSnackBar(
                SnackBar(
                  content: Text(result.toString()),
                  duration: Duration(seconds: 3),
                ),
              );
              fetchProductDetails();
            }
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

      if (productData.containsKey("sku") &&
          productData["sku"] is String &&
          productData["sku"].isNotEmpty) {
        productInventoryWidgetData.add(
          _getItemRow("Sku: ", "${productData["sku"]}"),
        );
      }

      if (productData.containsKey("stock_status") &&
          productData["stock_status"] is String &&
          productData["stock_status"].isNotEmpty) {
        productInventoryWidgetData.add(
          _getItemRow("Stock status: ",
              productData["stock_status"].toString().titleCase),
        );
      }

      if (productData.containsKey("manage_stock") &&
          productData["manage_stock"] is bool) {
        productInventoryWidgetData.add(
          _getItemRow(
              "Manage stock: ", (productData["manage_stock"] ? "Yes" : "No")),
        );
      }

      if (productData.containsKey("stock_quantity") &&
          productData["stock_quantity"] is int) {
        productInventoryWidgetData.add(
          _getItemRow("Stock qty: ", "${productData["stock_quantity"]}"),
        );
      }

      if (productData.containsKey("backorders_allowed") &&
          productData["backorders_allowed"] is bool) {
        productInventoryWidgetData.add(
          _getItemRow("Backorders allowed: ",
              productData["backorders_allowed"] ? "Yes" : "No"),
        );
      }

      if (productData.containsKey("backorders") &&
          productData["backorders"] is String &&
          productData["backorders"].isNotEmpty) {
        productInventoryWidgetData.add(
          _getItemRow(
              "Backorders: ", productData["backorders"].toString().titleCase),
        );
      }

      if (productData.containsKey("sold_individually") &&
          productData["sold_individually"] is bool) {
        productInventoryWidgetData.add(
          _getItemRow("Sold individually: ",
              productData["sold_individually"] ? "Yes" : "No"),
        );
      }

      if (productInventoryWidgetData.isNotEmpty) {
        productInventoryWidget = _getExpansionTile(
          "Inventory",
          productInventoryWidgetData,
          isTappable: true,
          onTap: () async {
            String sku;
            if (productData.containsKey("sku") &&
                productData["sku"] is String &&
                productData["sku"].isNotEmpty) {
              sku = productData["sku"];
            }

            String stockStatus;
            if (productData.containsKey("stock_status") &&
                productData["stock_status"] is String &&
                productData["stock_status"].isNotEmpty) {
              stockStatus = productData["stock_status"];
            }

            bool manageStock = false;
            if (productData.containsKey("manage_stock") &&
                productData["manage_stock"] is bool) {
              manageStock = productData["manage_stock"];
            }

            int stockQuantity;
            if (productData.containsKey("stock_quantity") &&
                productData["stock_quantity"] is int) {
              stockQuantity = productData["stock_quantity"];
            }

            String backorders;
            if (productData.containsKey("backorders") &&
                productData["backorders"] is String &&
                productData["backorders"].isNotEmpty) {
              backorders = productData["backorders"];
            }

            String result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => EditProductInventoryPage(
                  baseurl: widget.baseurl,
                  username: widget.username,
                  password: widget.password,
                  id: widget.id,
                  sku: sku,
                  stockStatus: stockStatus,
                  manageStock: manageStock,
                  stockQuantity: stockQuantity,
                  backorders: backorders,
                ),
              ),
            );
            if (result is String) {
              scaffoldKey.currentState.showSnackBar(
                SnackBar(
                  content: Text(result.toString()),
                  duration: Duration(seconds: 3),
                ),
              );
              fetchProductDetails();
            }
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

      if (productData.containsKey("weight") &&
          productData["weight"] is String &&
          productData["weight"].isNotEmpty) {
        productShippingWidgetData.add(
          _getItemRow("Weight: ", productData["weight"]),
        );
      }

      if (productData.containsKey("dimensions") &&
          productData["dimensions"] is Map) {
        if (productData["dimensions"].containsKey("length") &&
            productData["dimensions"]["length"] is String &&
            productData["dimensions"]["length"].isNotEmpty) {
          productShippingWidgetData.add(
            _getItemRow("Length: ", productData["dimensions"]["length"]),
          );
        }

        if (productData["dimensions"].containsKey("width") &&
            productData["dimensions"]["width"] is String &&
            productData["dimensions"]["width"].isNotEmpty) {
          productShippingWidgetData.add(
            _getItemRow("Width: ", productData["dimensions"]["width"]),
          );
        }

        if (productData["dimensions"].containsKey("height") &&
            productData["dimensions"]["height"] is String &&
            productData["dimensions"]["height"].isNotEmpty) {
          productShippingWidgetData.add(
            _getItemRow("Height: ", productData["dimensions"]["height"]),
          );
        }
      }

      if (productData.containsKey("shipping_required") &&
          productData["shipping_required"] is bool) {
        productShippingWidgetData.add(
          _getItemRow("Shipping required: ",
              productData["shipping_required"] ? "Yes" : "No"),
        );
      }

      if (productData.containsKey("shipping_taxable") &&
          productData["shipping_taxable"] is bool) {
        productShippingWidgetData.add(
          _getItemRow("Shipping taxable: ",
              productData["shipping_taxable"] ? "Yes" : "No"),
        );
      }

      if (productData.containsKey("shipping_class") &&
          productData["shipping_class"] is String &&
          productData["shipping_class"].isNotEmpty) {
        productShippingWidgetData.add(
          _getItemRow(
              "Shipping class: ", productData["shipping_class"] ? "Yes" : "No"),
        );
      }

      if (productShippingWidgetData.isNotEmpty) {
        productShippingWidget = _getExpansionTile(
          "Shipping",
          productShippingWidgetData,
          isTappable: true,
          onTap: () async {
            String weight;
            if (productData is Map &&
                productData.containsKey("weight") &&
                productData["weight"] is String &&
                productData["weight"].isNotEmpty) {
              weight = productData["weight"];
            }

            String length;
            String width;
            String height;
            if (productData.containsKey("dimensions") &&
                productData["dimensions"] is Map) {
              if (productData["dimensions"].containsKey("length") &&
                  productData["dimensions"]["length"] is String &&
                  productData["dimensions"]["length"].isNotEmpty) {
                length = productData["dimensions"]["length"];
              }

              if (productData["dimensions"].containsKey("width") &&
                  productData["dimensions"]["width"] is String &&
                  productData["dimensions"]["width"].isNotEmpty) {
                width = productData["dimensions"]["width"];
              }

              if (productData["dimensions"].containsKey("height") &&
                  productData["dimensions"]["height"] is String &&
                  productData["dimensions"]["height"].isNotEmpty) {
                height = productData["dimensions"]["height"];
              }
            }

            String shippingClass;
            if (productData.containsKey("shipping_class") &&
                productData["shipping_class"] is String &&
                productData["shipping_class"].isNotEmpty) {
              shippingClass = productData["shipping_class"];
            }

            String result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => EditProductShippingPage(
                  baseurl: widget.baseurl,
                  username: widget.username,
                  password: widget.password,
                  id: widget.id,
                  weight: weight,
                  length: length,
                  width: width,
                  height: height,
                  shippingClass: shippingClass,
                ),
              ),
            );
            if (result is String) {
              scaffoldKey.currentState.showSnackBar(
                SnackBar(
                  content: Text(result.toString()),
                  duration: Duration(seconds: 3),
                ),
              );
              fetchProductDetails();
            }
          },
        );
      }
    }
    return productShippingWidget;
  }

  Widget _productReviewsWidget() {
    Widget productReviewsWidget = SizedBox.shrink();

    if (isProductDataReady) {
      List<Widget> productReviewsWidgetData = [];

      if (productData.containsKey("reviews_allowed") &&
          productData["reviews_allowed"] is bool) {
        productReviewsWidgetData.add(
          _getItemRow("Reviews allowed: ",
              (productData["reviews_allowed"] ? "Yes" : "No")),
        );
      }

      if (productData.containsKey("average_rating") &&
          productData["average_rating"] is String &&
          productData["average_rating"].isNotEmpty) {
        productReviewsWidgetData.add(
          _getItemRow("Average rating: ", productData["average_rating"]),
        );
      }

      if (productData.containsKey("rating_count") &&
          productData["rating_count"] is int) {
        productReviewsWidgetData.add(
          _getItemRow("Rating count: ", "${productData["rating_count"]}"),
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
        productData.containsKey("categories") &&
        productData["categories"] is List &&
        productData["categories"].isNotEmpty) {
      List<Widget> productCategoriesWidgetData = [
        Wrap(
          spacing: 5,
          children: <Widget>[
            for (var i = 0; i < productData["categories"].length; i++)
              if (productData["categories"][i].containsKey("name") &&
                  productData["categories"][i]["name"] is String &&
                  productData["categories"][i]["name"].isNotEmpty)
                Container(
                  height: 40,
                  child: Chip(
                    label: Text(
                      productData["categories"][i]["name"],
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
        productData.containsKey("attributes") &&
        productData["attributes"] is List &&
        productData["attributes"].isNotEmpty) {
      for (int i = 0; i < productData["attributes"].length; i++) {
        if (productData["attributes"][i] is Map &&
            productData["attributes"][i].containsKey("name") &&
            productData["attributes"][i]["name"] is String &&
            productData["attributes"][i]["name"].isNotEmpty) {
          String attributeName = "${productData["attributes"][i]["name"]}: ";
          String attributeOptions = "";

          if (productData["attributes"][i].containsKey("options") &&
              productData["attributes"][i]["options"] is List &&
              productData["attributes"][i]["options"].isNotEmpty) {
            for (int j = 0;
                j < productData["attributes"][i]["options"].length;
                j++) {
              if (productData["attributes"][i]["options"][j] is String &&
                  productData["attributes"][i]["options"][j].isNotEmpty) {
                attributeOptions +=
                    (j == productData["attributes"][i]["options"].length - 1
                        ? productData["attributes"][i]["options"][j]
                        : "${productData["attributes"][i]["options"][j]}, ");
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
