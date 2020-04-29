import 'dart:convert';

import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:woocommerceadmin/src/orders/models/order.dart';
import 'package:woocommerceadmin/src/orders/providers/order_provider.dart';

class OrderDetailsLineItemsWidget extends StatelessWidget {
  final String baseurl;
  final String username;
  final String password;

  OrderDetailsLineItemsWidget({
    @required this.baseurl,
    @required this.username,
    @required this.password,
  });

  @override
  Widget build(BuildContext context) {
    final OrderProvider orderProvider = Provider.of<OrderProvider>(context);
    final Order orderData = orderProvider.order;

    Widget orderProductsWidget = SizedBox.shrink();
    List<Widget> orderProductsCardData = [];

    if (orderData?.lineItems is List && orderData.lineItems.isNotEmpty) {
      for (int i = 0; i < orderData.lineItems.length; i++) {
        List<Widget> orderProductsData = [];
        Widget lineItemsPrimaryImage = SizedBox(
          height: 140,
          width: 140,
        );

        if (orderData.lineItems[i]?.productId is int) {
          lineItemsPrimaryImage = LineItemsProductsImage(
            baseurl: baseurl,
            username: username,
            password: password,
            id: orderData.lineItems[i].productId,
          );
        }

        if (orderData.lineItems[i]?.name is String &&
            orderData.lineItems[i].name.isNotEmpty) {
          orderProductsData.add(Text(
            orderData.lineItems[i].name,
            style: Theme.of(context)
                .textTheme
                .body1
                .copyWith(fontWeight: FontWeight.bold),
          ));
        }

        if (orderData.lineItems[i]?.sku is String) {
          orderProductsData.add(Text("SKU: ${orderData.lineItems[i].sku}"));
        }

        if (orderData.lineItems[i]?.price is double) {
          orderProductsData.add(Text("Price: ${orderData.lineItems[i].price.toStringAsPrecision(4)}"));
        }

        if (orderData.lineItems[i]?.quantity is int) {
          orderProductsData.add(Text("Qty: ${orderData.lineItems[i].quantity}"));
        }

        if (orderData.lineItems[i]?.metaData is List &&
            orderData.lineItems[i].metaData.isNotEmpty) {
          for (int metaDataIndex = 0;
              metaDataIndex < orderData.lineItems[i].metaData.length;
              metaDataIndex++) {
            if (orderData.lineItems[i].metaData[metaDataIndex]?.key is String &&
                orderData.lineItems[i].metaData[metaDataIndex].key ==
                    "_tmcartepo_data") {
              if (orderData.lineItems[i].metaData[metaDataIndex]?.value
                      is List &&
                  orderData
                      .lineItems[i].metaData[metaDataIndex].value.isNotEmpty) {
                for (int tmcartepoDataIndex = 0;
                    tmcartepoDataIndex <
                        orderData
                            .lineItems[i].metaData[metaDataIndex].value.length;
                    tmcartepoDataIndex++) {
                  if (orderData.lineItems[i].metaData[metaDataIndex]
                          .value[tmcartepoDataIndex] is Map &&
                      orderData.lineItems[i].metaData[metaDataIndex]
                          .value[tmcartepoDataIndex]
                          .containsKey("name") &&
                      orderData.lineItems[i].metaData[metaDataIndex]
                          .value[tmcartepoDataIndex]["name"] is String &&
                      orderData.lineItems[i].metaData[metaDataIndex]
                          .value[tmcartepoDataIndex]["name"].isNotEmpty &&
                      orderData.lineItems[i].metaData[metaDataIndex]
                          .value[tmcartepoDataIndex]
                          .containsKey("value") &&
                      orderData.lineItems[i].metaData[metaDataIndex]
                          .value[tmcartepoDataIndex]["value"] is String &&
                      orderData.lineItems[i].metaData[metaDataIndex]
                          .value[tmcartepoDataIndex]["value"].isNotEmpty) {
                    orderProductsData.add(
                      Text(
                          '${orderData.lineItems[i].metaData[metaDataIndex].value[tmcartepoDataIndex]["name"]}: ${orderData.lineItems[i].metaData[metaDataIndex].value[tmcartepoDataIndex]["value"]}'),
                    );
                  }
                }
              }
              break;
            }
          }
        }

        orderProductsCardData.add(Card(
          child: InkWell(
            onTap: () {
              if (orderData.lineItems[i].productId is int) {
                // Navigator.push(
                //   context,
                //   MaterialPageRoute(
                //     builder: (context) => ProductDetailsScreen(
                //       baseurl: widget.baseurl,
                //       username: widget.username,
                //       password: widget.password,
                //       id: orderData["line_items"][i]["product_id"],
                //     ),
                //   ),
                // );
              }
            },
            child: Row(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: lineItemsPrimaryImage,
                ),
                Expanded(
                    child: Padding(
                  padding: EdgeInsets.all(10),
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: orderProductsData),
                ))
              ],
            ),
          ),
        ));
      }

      if (orderProductsCardData.isNotEmpty) {
        orderProductsWidget = ExpansionTile(
          title: Text(
            "Products",
            style: Theme.of(context).textTheme.subhead,
          ),
          initiallyExpanded: true,
          children: <Widget>[
            Row(
              children: <Widget>[
                Flexible(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(10.0, 0, 10.0, 10.0),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: orderProductsCardData),
                  ),
                ),
              ],
            )
          ],
        );
      }
    }
    return orderProductsWidget;
  }
}

class LineItemsProductsImage extends StatefulWidget {
  final String baseurl;
  final String username;
  final String password;
  final int id;

  LineItemsProductsImage(
      {Key key,
      @required this.baseurl,
      @required this.username,
      @required this.password,
      @required this.id})
      : super(key: key);

  @override
  _LineItemsProductsImageState createState() => _LineItemsProductsImageState();
}

class _LineItemsProductsImageState extends State<LineItemsProductsImage> {
  bool isProductDataReady = false;
  Map productData = {};
  bool isProductDataError = false;

  @override
  void initState() {
    super.initState();
    fetchLineItemsDetails(widget.id);
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  Widget build(BuildContext context) {
    return isProductDataError
        ? SizedBox(
            height: 140,
            width: 140,
          )
        : (isProductDataReady &&
                productData.containsKey("images") &&
                productData["images"] is List &&
                productData["images"].isNotEmpty &&
                productData["images"][0] is Map &&
                productData["images"][0].containsKey("src") &&
                productData["images"][0]["src"] is String)
            ? ExtendedImage.network(
                productData["images"][0]["src"],
                height: 140,
                width: 140,
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
              )
            : Container(
                height: 140,
                width: 140,
                child: Center(
                  child: SpinKitPulse(
                    color: Theme.of(context).primaryColor,
                    size: 50,
                  ),
                ),
              );
  }

  Future<Null> fetchLineItemsDetails(int productId) async {
    String url =
        "${widget.baseurl}/wp-json/wc/v3/products/$productId?consumer_key=${widget.username}&consumer_secret=${widget.password}";
    setState(() {
      isProductDataError = false;
      isProductDataReady = false;
    });
    try {
      final http.Response response = await http.get(url);
      if (response.statusCode == 200) {
        dynamic responseBody = json.decode(response.body);
        if (responseBody is Map &&
            responseBody.containsKey("id")) {
          setState(() {
            productData = responseBody;
            isProductDataReady = true;
            isProductDataError = false;
          });
        } else {
          setState(() {
            isProductDataReady = false;
            isProductDataError = true;
          });
        }
      } else {
        setState(() {
          isProductDataReady = false;
          isProductDataError = true;
        });
      }
    } catch (e) {
      setState(() {
        isProductDataReady = false;
        isProductDataError = true;
      });
    }
  }
}
