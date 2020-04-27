import 'package:flutter/material.dart';
import 'package:woocommerceadmin/src/products/components/product_details/widgets/product_details_attributes_widget.dart';
import 'package:woocommerceadmin/src/products/components/product_details/widgets/product_details_categories_widget.dart';
import 'package:woocommerceadmin/src/products/components/product_details/widgets/product_details_general_widget.dart';
import 'package:woocommerceadmin/src/products/components/product_details/widgets/product_details_headline_widget.dart';
import 'package:woocommerceadmin/src/products/components/product_details/widgets/product_details_images_widget.dart';
import 'package:woocommerceadmin/src/products/components/product_details/widgets/product_details_inventory_widget.dart';
import 'package:woocommerceadmin/src/products/components/product_details/widgets/product_details_pricing_widget.dart';
import 'package:woocommerceadmin/src/products/components/product_details/widgets/product_details_reviews_widget.dart';
import 'package:woocommerceadmin/src/products/components/product_details/widgets/product_details_shipping_widget.dart';

class ProductDetailsScreen extends StatefulWidget {
  static const routeName = '/product-details';

  final String baseurl;
  final String username;
  final String password;
  final int id;

  ProductDetailsScreen({
    Key key,
    @required this.baseurl,
    @required this.username,
    @required this.password,
    @required this.id,
  }) : super(key: key);

  @override
  _ProductDetailsScreenState createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  Map productData = {};
  bool isProductDataReady = true;
  bool isProductDataError = false;
  String productDataError;

  final scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  void initState() {
    // if (widget.preFetch ?? true) {
    // fetchProductDetails();
    // } else {
    //   if (widget.productData is Map &&
    //       widget.productData.containsKey("id") &&
    //       widget.productData["id"] is int) {
    //     productData = widget.productData;
    //   } else {
    //     // fetchProductDetails();
    //   }
    // }
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
      body:
          // !isProductDataReady
          //     ? !isProductDataError
          //         ? _mainLoadingWidget()
          //         : _productDataErrorWidget()
          //     :
          RefreshIndicator(
        // onRefresh: fetchProductDetails,
        onRefresh: () async {},
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          padding: const EdgeInsets.all(0.0),
          child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                ProductDetailsHeadlineWidget(),
                ProductDetailsImages(),
                ProductDetailsGeneralWidget(
                  baseurl: widget.baseurl,
                  username: widget.username,
                  password: widget.password,
                ),
                ProductDetailsPricingWidget(
                  baseurl: widget.baseurl,
                  username: widget.username,
                  password: widget.password,
                ),
                ProductDetailsInventoryWidget(
                  baseurl: widget.baseurl,
                  username: widget.username,
                  password: widget.password,
                ),
                ProductDetailsShippingWidget(
                  baseurl: widget.baseurl,
                  username: widget.username,
                  password: widget.password,
                ),
                ProductDetailsReviewsWidget(
                  baseurl: widget.baseurl,
                  username: widget.username,
                  password: widget.password,
                ),
                ProductDetailsCategoriesWidget(
                  baseurl: widget.baseurl,
                  username: widget.username,
                  password: widget.password,
                ),
                ProductDetailsAttributesWidget(
                  baseurl: widget.baseurl,
                  username: widget.username,
                  password: widget.password,
                ),
              ]),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.delete),
        backgroundColor: Colors.red,
        mini: true,
        onPressed: () {},
      ),
    );
  }

  // Future<Null> fetchProductDetails() async {
  //   String url =
  //       "${widget.baseurl}/wp-json/wc/v3/products/${widget.id}?consumer_key=${widget.username}&consumer_secret=${widget.password}";
  //   setState(() {
  //     isProductDataError = false;
  //     isProductDataReady = false;
  //   });
  //   http.Response response;
  //   try {
  //     response = await http.get(url);
  //     if (response.statusCode == 200) {
  //       dynamic responseBody = json.decode(response.body);
  //       if (responseBody is Map &&
  //           responseBody.containsKey("id") &&
  //           responseBody["id"] != null) {
  //         setState(() {
  //           productData = responseBody;
  //           isProductDataReady = true;
  //           isProductDataError = false;
  //         });
  //       } else {
  //         setState(() {
  //           isProductDataReady = false;
  //           isProductDataError = true;
  //           productDataError = "Failed to fetch product details";
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
  //         isProductDataReady = false;
  //         isProductDataError = true;
  //         productDataError =
  //             "Failed to fetch product details. Error: $errorCode";
  //       });
  //     }
  //   } on SocketException catch (_) {
  //     setState(() {
  //       isProductDataReady = false;
  //       isProductDataError = true;
  //       productDataError =
  //           "Failed to fetch product details. Error: Network not reachable";
  //     });
  //   } catch (e) {
  //     setState(() {
  //       isProductDataReady = false;
  //       isProductDataError = true;
  //       productDataError = "Failed to fetch product details. Error: $e";
  //     });
  //   }
  // }

  // Widget _mainLoadingWidget() {
  //   Widget mainLoadingWidget = SizedBox.shrink();
  //   if (!isProductDataReady && !isProductDataError) {
  //     mainLoadingWidget = Container(
  //       child: Center(
  //         child: SpinKitPulse(
  //           color: Theme.of(context).primaryColor,
  //           size: 70,
  //         ),
  //       ),
  //     );
  //   }
  //   return mainLoadingWidget;
  // }

  // Widget _productDataErrorWidget() {
  //   Widget productDataErrorWidget = SizedBox.shrink();
  //   if (isProductDataError &&
  //       !isProductDataReady &&
  //       productDataError is String &&
  //       productDataError.isNotEmpty) {
  //     productDataErrorWidget = Container(
  //       padding: EdgeInsets.all(10),
  //       child: Center(
  //         child: Text(productDataError),
  //       ),
  //     );
  //   }
  //   return productDataErrorWidget;
  // }
}
