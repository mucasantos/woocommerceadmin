import 'dart:convert';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart' as http;
import 'package:recase/recase.dart';
import 'package:unicorndial/unicorndial.dart';
import 'package:woocommerceadmin/src/common/widgets/ImageViewer.dart';
import 'package:woocommerceadmin/src/products/widgets/EditProductPage.dart';
import 'package:flutter_offline/flutter_offline.dart';

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
  bool isError = false;

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
      appBar: AppBar(
        title: Text("Product Details"),
      ),
      body: OfflineBuilder(
          connectivityBuilder: (
            BuildContext context,
            ConnectivityResult connectivity,
            Widget child,
          ) {
            final bool connected = connectivity != ConnectivityResult.none;
            return Column(
              children: [
                AnimatedSwitcher(
                    duration: const Duration(milliseconds: 350),
                    child: connected
                        ? Container(
                            color: Colors.lightGreenAccent[400],
                            height: 25,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Text(
                                  'ONLINE',
                                  style: TextStyle(color: Colors.black),
                                ),
                              ],
                            ))
                        : Container(
                            color: Colors.red,
                            height: 25,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Text(
                                  'OFFLINE',
                                  style: TextStyle(color: Colors.white),
                                ),
                                SizedBox(width: 8.0),
                                SizedBox(
                                  width: 12.0,
                                  height: 12.0,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.0,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white),
                                  ),
                                ),
                              ],
                            ),
                          )),
                Expanded(child: child),
              ],
            );
          },
          child: !isProductDataReady
              ? !isError ? _mainLoadingWidget() : Text("Error Fetching Data")
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
                        ]),
                  ),
                )),
      floatingActionButton: isProductDataReady
          ? UnicornDialer(
              backgroundColor: Color.fromRGBO(100, 100, 100, 0.7),
              parentButtonBackground:
                  Theme.of(context).floatingActionButtonTheme.backgroundColor,
              orientation: UnicornOrientation.VERTICAL,
              parentButton: Icon(Icons.add),
              childButtons: <UnicornButton>[
                UnicornButton(
                    hasLabel: true,
                    labelText: "Edit",
                    currentButton: FloatingActionButton(
                      heroTag: "edit",
                      backgroundColor: Colors.purple,
                      mini: true,
                      child: Icon(Icons.edit),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => EditProductPage(
                                    baseurl: widget.baseurl,
                                    username: widget.username,
                                    password: widget.password,
                                    id: widget.id,
                                  )),
                        );
                      },
                    )),
                UnicornButton(
                    hasLabel: true,
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
      isError = false;
      isProductDataReady = false;
    });
    dynamic response;
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
            isError = false;
          });
        } else {
          setState(() {
            isProductDataReady = false;
            isError = true;
          });
        }
      } else {
        setState(() {
          isProductDataReady = false;
          isError = true;
        });
      }
    } catch (e) {
      setState(() {
        isProductDataReady = false;
        isError = true;
      });
    }
  }

  Widget _mainLoadingWidget() {
    Widget mainLoadingWidget = SizedBox.shrink();
    if (!isProductDataReady && !isError) {
      mainLoadingWidget = Container(
        child: Center(
          child: SpinKitFadingCube(
            color: Theme.of(context).primaryColor,
            size: 30.0,
          ),
        ),
      );
    }
    return mainLoadingWidget;
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
        height: 150.0,
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
              }),
        ),
      );
    }
    return productImagesWidget;
  }

  Widget _productHeadlineWidget() {
    Widget productHeadlineWidget = SizedBox.shrink();
    if (isProductDataReady &&
        productDetails.containsKey("name") &&
        productDetails["name"] != null) {
      productHeadlineWidget = Container(
        child: Row(children: <Widget>[
          Flexible(
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
          )
        ]),
        padding: const EdgeInsets.all(0.0),
        alignment: Alignment.center,
      );
    }
    return productHeadlineWidget;
  }

  Widget _productGeneralWidget() {
    Widget productGeneralWidget = SizedBox.shrink();
    if (isProductDataReady &&
        (productDetails.containsKey("sku") ||
            productDetails.containsKey("slug") ||
            productDetails.containsKey("status") ||
            productDetails.containsKey("featured") ||
            productDetails.containsKey("total_sales"))) {
      List<Widget> productGeneralData = [];
      if (productDetails.containsKey("sku")) {
        productGeneralData.add(
          Text(
            "Sku: ${productDetails["sku"]}",
            style: Theme.of(context).textTheme.body1,
          ),
        );
      }
      if (productDetails.containsKey("slug")) {
        productGeneralData.add(Text(
          "Slug: ${productDetails["slug"]}",
          style: Theme.of(context).textTheme.body1,
        ));
      }
      if (productDetails.containsKey("status")) {
        productGeneralData.add(Text(
          "Status: " + productDetails["status"].toString().titleCase,
          style: Theme.of(context).textTheme.body1,
        ));
      }
      if (productDetails.containsKey("featured") &&
          productDetails["featured"] is bool) {
        productGeneralData.add(Text(
          "Featured: " + (productDetails["featured"] ? "Yes" : "No"),
          style: Theme.of(context).textTheme.body1,
        ));
      }
      if (productDetails.containsKey("total_sales")) {
        productGeneralData.add(Text(
          "Total Ordered: ${productDetails["total_sales"]}",
          style: Theme.of(context).textTheme.body1,
        ));
      }
      productGeneralWidget = ExpansionTile(
        title: Text(
          "General",
          style: Theme.of(context).textTheme.subhead,
        ),
        initiallyExpanded: true,
        children: <Widget>[
          Row(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.fromLTRB(20.0, 0, 20.0, 10.0),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: productGeneralData),
              ),
            ],
          )
        ],
      );
    }
    return productGeneralWidget;
  }

  Widget _productPriceWidget() {
    Widget productPriceWidget = SizedBox.shrink();
    if (isProductDataReady &&
        (productDetails.containsKey("regular_price") ||
            productDetails.containsKey("sale_price"))) {
      List<Widget> pricePriceData = [];
      if (productDetails.containsKey("regular_price")) {
        pricePriceData.add(
          Text(
            "Regular Price: ${productDetails["regular_price"]}",
            style: Theme.of(context).textTheme.body1,
          ),
        );
      }
      if (productDetails.containsKey("sale_price")) {
        pricePriceData.add(Text(
          "Sale Price: ${productDetails["sale_price"]}",
          style: Theme.of(context).textTheme.body1,
        ));
      }
      productPriceWidget = ExpansionTile(
        title: Text(
          "Pricing",
          style: Theme.of(context).textTheme.subhead,
        ),
        initiallyExpanded: true,
        children: <Widget>[
          Row(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.fromLTRB(20.0, 0, 20.0, 10.0),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: pricePriceData),
              ),
            ],
          )
        ],
      );
    }
    return productPriceWidget;
  }

  Widget _productInventoryWidget() {
    Widget productInventoryWidget = SizedBox.shrink();
    if (isProductDataReady &&
        (productDetails.containsKey("stock_status") ||
            productDetails.containsKey("manage_stock") ||
            productDetails.containsKey("stock_quantity"))) {
      List<Widget> productPriceData = [];
      if (productDetails.containsKey("stock_status")) {
        productPriceData.add(
          Text(
            "Stock Status: " +
                productDetails["stock_status"].toString().titleCase,
            style: Theme.of(context).textTheme.body1,
          ),
        );
      }
      if (productDetails.containsKey("manage_stock") &&
          productDetails["manage_stock"] is bool) {
        productPriceData.add(Text(
          "Manage Stock: " + (productDetails["manage_stock"] ? "Yes" : "No"),
          style: Theme.of(context).textTheme.body1,
        ));
      }
      if (productDetails.containsKey("stock_quantity") &&
          productDetails["stock_quantity"] is String) {
        productPriceData.add(Text(
          "Stock Qty: ${productDetails["stock_quantity"]}",
          style: Theme.of(context).textTheme.body1,
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
              Padding(
                padding: const EdgeInsets.fromLTRB(20.0, 0, 20.0, 10.0),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: productPriceData),
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
    if (isProductDataReady &&
        ((productDetails.containsKey("weight") &&
                productDetails["weight"] is String &&
                productDetails["weight"].isNotEmpty) ||
            (productDetails.containsKey("dimensions") &&
                    productDetails["dimensions"] is Map) &&
                ((productDetails["dimensions"].containsKey("length") &&
                        productDetails["dimensions"]["length"] is String &&
                        productDetails["dimensions"]["length"].isNotEmpty) ||
                    (productDetails["dimensions"].containsKey("width") &&
                        productDetails["dimensions"]["width"] is String &&
                        productDetails["dimensions"]["width"].isNotEmpty) ||
                    (productDetails["dimensions"].containsKey("height") &&
                        productDetails["dimensions"]["height"] is String &&
                        productDetails["dimensions"]["height"].isNotEmpty)))) {
      List<Widget> productShippingData = [];
      if (productDetails.containsKey("weight") &&
          productDetails["weight"] is String &&
          productDetails["weight"].isNotEmpty) {
        productShippingData.add(
          Text(
            "Weight: " + productDetails["weight"].toString(),
            style: Theme.of(context).textTheme.body1,
          ),
        );
      }

      if (productDetails.containsKey("dimensions") &&
          productDetails["dimensions"] is Map) {
        if (productDetails["dimensions"].containsKey("length") &&
            productDetails["dimensions"]["length"] is String &&
            productDetails["dimensions"]["length"].isNotEmpty) {
          productShippingData.add(Text(
            "Length: " + productDetails["dimensions"]["length"],
            style: Theme.of(context).textTheme.body1,
          ));
        }

        if (productDetails["dimensions"].containsKey("width") &&
            productDetails["dimensions"]["width"] is String &&
            productDetails["dimensions"]["width"].isNotEmpty) {
          productShippingData.add(Text(
            "Width: " + productDetails["dimensions"]["width"],
            style: Theme.of(context).textTheme.body1,
          ));
        }

        if (productDetails["dimensions"].containsKey("height") &&
            productDetails["dimensions"]["height"] is String &&
            productDetails["dimensions"]["height"].isNotEmpty) {
          productShippingData.add(Text(
            "Height: " + productDetails["dimensions"]["height"],
            style: Theme.of(context).textTheme.body1,
          ));
        }
      }

      productShippingWidget = ExpansionTile(
        title: Text(
          "Shipping",
          style: Theme.of(context).textTheme.subhead,
        ),
        initiallyExpanded: true,
        children: <Widget>[
          Row(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.fromLTRB(20.0, 0, 20.0, 10.0),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: productShippingData),
              ),
            ],
          )
        ],
      );
    }
    return productShippingWidget;
  }
}
